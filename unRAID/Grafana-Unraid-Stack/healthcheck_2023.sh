#!/bin/bash

## No healthcheck if healthcheck-disable is set ##
if [[ -f "/config/healthcheck-disable" ]]
then
    touch /config/healthcheck-disable
else    
    # Block concurrent runs #
    touch /config/healthcheck-disable

    # Autoheal #
    crashed=0

    pidlist=$(pidof influxd)
    if [ -z "$pidlist" ]
    then
        if [[ -f "/config/healthcheck-no-error" ]]
        then
            touch /config/healthcheck-no-error
        else
            crashed=$(( $crashed + 1 ))
            touch "/config/healthcheck-failure-influxd-at-$(date "+%d.%m.%Y_%T")"
        fi
        echo "[info] Run influxdb as service on port $INFLUXDB_HTTP_PORT"
        service influxdb start
    fi

    pidlist=$(pidof loki)
    if [ -z "$pidlist" ]
    then
        if [[ -f "/config/healthcheck-no-error" ]]
        then
            touch /config/healthcheck-no-error
        else
            crashed=$(( $crashed + 1 ))
            touch "/config/healthcheck-failure-loki-at-$(date "+%d.%m.%Y_%T")"
        fi
        echo "[info] Run loki as daemon on port $LOKI_PORT"
        start-stop-daemon --start -b --exec /usr/sbin/loki -- -config.file=/config/loki/loki-local-config.yaml
    fi

    if [[ $USE_HDDTEMP =~ "yes" ]]
    then
        pidlist=$(pidof hddtemp)
        if [ -z "$pidlist" ]
        then
            if [[ -f "/config/healthcheck-no-error" ]]
            then
                touch /config/healthcheck-no-error
            else
                crashed=$(( $crashed + 1 ))
                touch "/config/healthcheck-failure-hddtemp-at-$(date "+%d.%m.%Y_%T")"
            fi
            echo "[info] Running hddtemp as daemon due to USE_HDDTEMP set to $USE_HDDTEMP"
            hddtemp --quiet --daemon --file=/config/hddtemp/hddtemp.db --listen='127.0.0.1' --port=7634 /rootfs/dev/disk/by-id/ata*
        fi
    fi
    
    pidlist=$(pidof telegraf)
    if [ -z "$pidlist" ]
    then
        if [[ -f "/config/healthcheck-no-error" ]]
        then
            touch /config/healthcheck-no-error
        else
            crashed=$(( $crashed + 1 ))
            touch "/config/healthcheck-failure-telegraf-at-$(date "+%d.%m.%Y_%T")"
        fi
        echo "[info] Run telegraf as service"
        service telegraf start
    fi
    
    pidlist=$(pidof promtail)
    if [ -z "$pidlist" ]
    then
        if [[ -f "/config/healthcheck-no-error" ]]
        then
            touch /config/healthcheck-no-error
        else
            crashed=$(( $crashed + 1 ))
            touch "/config/healthcheck-failure-promtail-at-$(date "+%d.%m.%Y_%T")"
        fi
        echo "[info] Run promtail as daemon on port $PROMTAIL_PORT"
        start-stop-daemon --start -b --exec /usr/sbin/promtail -- -config.file=/config/promtail/promtail.yml
    fi
    
    pidlist=$(pidof grafana-server)
    if [ -z "$pidlist" ]
    then
        if [[ -f "/config/healthcheck-no-error" ]]
        then
            touch /config/healthcheck-no-error
        else
            crashed=$(( $crashed + 1 ))
            touch "/config/healthcheck-failure-grafana-at-$(date "+%d.%m.%Y_%T")"
        fi
        echo "[info] Run grafana as service on port $GRAFANA_PORT"
        service grafana-server start
    fi
    
    # Remove blockage #
    rm -f /config/healthcheck-disable
    
    # No error if healthcheck-no-error is set #
    if [[ -f "/config/healthcheck-no-error" ]]
    then
        touch /config/healthcheck-no-error
    else
        # Return exit code for healthcheck #
        if (( $crashed > 0 ))
        then
            #touch "/config/debug-healthcheck-failure-at-$(date "+%d.%m.%Y_%T")"
            exit 1
        else
            exit 0
        fi
    fi
fi
