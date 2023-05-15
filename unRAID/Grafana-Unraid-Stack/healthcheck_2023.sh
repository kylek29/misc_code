#!/bin/bash

# Start
echo "---- $(date "+%d.%m.%Y_%T"): Healthcheck Start ----"

# Check if the ENV variable for a new Log Folder is set and replace it, otherwise use default.
logout_folder="${LOG_FOLDER:="/config"}"

# Check and create new log folder if necessary. 
if [ ! -d "$logout_folder" ]; then
  echo "Directory ${logout_folder} does not exist, creating it .."
  mkdir -p "$logout_folder"
fi



## No healthcheck if healthcheck-disable is set ##
if [[ -f "/healthcheck-disable" ]]
then
    touch ${logout_folder}/healthcheck-disable
else    
    # Block concurrent runs #
    touch ${logout_folder}/healthcheck-disable

    # Autoheal #
    crashed=0

    pidlist=$(pidof influxd)
    if [ -z "$pidlist" ]
    then
        if [[ -f "${logout_folder}/healthcheck-no-error" ]]
        then
            touch ${logout_folder}/healthcheck-no-error
        else
            crashed=$(( $crashed + 1 ))
            touch "${logout_folder}/healthcheck-failure-influxd-at-$(date "+%d.%m.%Y_%T").status"
        fi
        echo "[info] Run influxdb as service on port $INFLUXDB_HTTP_PORT"
        service influxdb start
    fi

    pidlist=$(pidof loki)
    if [ -z "$pidlist" ]
    then
        if [[ -f "${logout_folder}/healthcheck-no-error" ]]
        then
            touch ${logout_folder}/healthcheck-no-error
        else
            crashed=$(( $crashed + 1 ))
            touch "${logout_folder}/healthcheck-failure-loki-at-$(date "+%d.%m.%Y_%T").status"
        fi
        echo "[info] Run loki as daemon on port $LOKI_PORT"
        start-stop-daemon --start -b --exec /usr/sbin/loki -- -config.file=/config/loki/loki-local-config.yaml
    fi

    if [[ $USE_HDDTEMP =~ "yes" ]]
    then
        pidlist=$(pidof hddtemp)
        if [ -z "$pidlist" ]
        then
            if [[ -f "${logout_folder}/healthcheck-no-error" ]]
            then
                touch ${logout_folder}/healthcheck-no-error
            else
                crashed=$(( $crashed + 1 ))
                touch "${logout_folder}/healthcheck-failure-hddtemp-at-$(date "+%d.%m.%Y_%T").status"
            fi
            echo "[info] Running hddtemp as daemon due to USE_HDDTEMP set to $USE_HDDTEMP"
            hddtemp --quiet --daemon --file=/config/hddtemp/hddtemp.db --listen='127.0.0.1' --port=7634 /rootfs/dev/disk/by-id/ata*
        fi
    fi
    
    pidlist=$(pidof telegraf)
    if [ -z "$pidlist" ]
    then
        if [[ -f "${logout_folder}/healthcheck-no-error" ]]
        then
            touch ${logout_folder}/healthcheck-no-error
        else
            crashed=$(( $crashed + 1 ))
            touch "${logout_folder}/healthcheck-failure-telegraf-at-$(date "+%d.%m.%Y_%T").status"
        fi
        echo "[info] Run telegraf as service"
        service telegraf start
    fi
    
    pidlist=$(pidof promtail)
    if [ -z "$pidlist" ]
    then
        if [[ -f "${logout_folder}/healthcheck-no-error" ]]
        then
            touch ${logout_folder}/healthcheck-no-error
        else
            crashed=$(( $crashed + 1 ))
            touch "${logout_folder}/healthcheck-failure-promtail-at-$(date "+%d.%m.%Y_%T").status"
        fi
        echo "[info] Run promtail as daemon on port $PROMTAIL_PORT"
        start-stop-daemon --start -b --exec /usr/sbin/promtail -- -config.file=/config/promtail/promtail.yml
    fi
    
    pidlist=$(pidof grafana-server)
    if [ -z "$pidlist" ]
    then
        if [[ -f "${logout_folder}/healthcheck-no-error" ]]
        then
            touch ${logout_folder}/healthcheck-no-error
        else
            crashed=$(( $crashed + 1 ))
            touch "${logout_folder}/healthcheck-failure-grafana-at-$(date "+%d.%m.%Y_%T").status"
        fi
        echo "[info] Run grafana as service on port $GRAFANA_PORT"
        service grafana-server start
    fi
    
    # Remove blockage #
    rm -f ${logout_folder}/healthcheck-disable
    
    # No error if healthcheck-no-error is set #
    if [[ -f "${logout_folder}/healthcheck-no-error" ]]
    then
        touch ${logout_folder}/healthcheck-no-error
    else
        # Return exit code for healthcheck #
        if (( $crashed > 0 ))
        then
            #touch "${logout_folder}/debug-healthcheck-failure-at-$(date "+%d.%m.%Y_%T")"
            exit 1
        else
            exit 0
        fi
    fi
fi
