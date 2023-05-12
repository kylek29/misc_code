#!/bin/bash

## Install dependencies ##
apt -y update \
    && apt -y install gnupg gnupg1 gnupg2 dirmngr ca-certificates apt-transport-https software-properties-common

## Install telegraf + influxdb from repo ##
curl -sL https://repos.influxdata.com/influxdata-archive_compat.key | apt-key add -

source /etc/lsb-release
echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | tee /etc/apt/sources.list.d/influxdb.list


apt -y update \
    && apt -y install telegraf influxdb
rm -rf /etc/telegraf
rm -rf /etc/influxdb
INFLUXDB_VERSION=$(influxd version | cut -d' ' -f 2 | cut -d'v' -f 2)
TELEGRAF_VERSION=$(telegraf version | cut -d' ' -f 2)
echo "$(date "+%d.%m.%Y %T") Added InfluxDB version ${INFLUXDB_VERSION}" >> /build.info
echo "$(date "+%d.%m.%Y %T") Added Telegraf version ${TELEGRAF_VERSION}" >> /build.info

## Clean up ##
apt -y autoremove \
    && apt -y autoclean \
    && apt -y clean \
    && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*
