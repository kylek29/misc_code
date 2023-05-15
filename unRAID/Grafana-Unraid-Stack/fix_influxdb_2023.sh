#!/bin/bash
# This is a fix for the file located here: https://github.com/testdasi/static-ubuntu/blob/main/scripts-install/install-influxdb-telegraf.sh


## Get the current versions of InfluxDB and Telegraf
INFLUXDB_VERSION_ORIG=$(influxd version | cut -d' ' -f 2 | cut -d'v' -f 2)
TELEGRAF_VERSION_ORIG=$(telegraf version | cut -d' ' -f 2)


## Install dependencies ##
apt -y update \
    && apt -y install gnupg gnupg1 gnupg2 dirmngr ca-certificates apt-transport-https software-properties-common

## Backup the original service details.
mkdir -p /tmp/etc/init.d && cp -TR /etc/init.d/influxdb /tmp/etc/init.d/influxdb && cp -TR /etc/init.d/telegraf /tmp/etc/init.d/telegraf

## Install telegraf + influxdb from repo ##
curl -sL https://repos.influxdata.com/influxdata-archive_compat.key | apt-key add -
source /etc/lsb-release
echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | tee /etc/apt/sources.list.d/influxdb.list

apt -y update \
    && apt -y install telegraf influxdb
rm -rf /etc/telegraf
rm -rf /etc/influxdb

# Move the service configs back ..
cp -TR /tmp/etc/init.d/influxdb /etc/init.d/influxdb  && cp -TR /tmp/etc/init.d/telegraf /etc/init.d/telegraf 

# Update the build.info with the new versions.
INFLUXDB_VERSION=$(influxd version | cut -d' ' -f 2 | cut -d'v' -f 2)
TELEGRAF_VERSION=$(telegraf version | cut -d' ' -f 2)
echo "$(date "+%d.%m.%Y %T") Added InfluxDB version ${INFLUXDB_VERSION} [replaced: ${INFLUXDB_VERSION_ORIG}]" >> /build.info
echo "$(date "+%d.%m.%Y %T") Added Telegraf version ${TELEGRAF_VERSION} [replaced: ${TELEGRAF_VERSION_ORIG}]" >> /build.info


## Clean up ##
apt -y autoremove \
    && apt -y autoclean \
    && apt -y clean \
    && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*
