#!/bin/bash
# Usage: temps.sh <hostname of system> <influxdb url>

HOSTNAME=$1

CPU_TEMP=$(cat /sys/kernel/debug/ieee80211/phy0/mt76/temperature)
WIFI_TEMP=$(vcgencmd measure_temp)

echo "cpu_temp,Hostname=$HOSTNAME value=$CPU_TEMP"         >> /tmp/temp_influx_write
echo "wifi_temp,Hostname=$HOSTNAME value=$WIFI_TEMP"       >> /tmp/temp_influx_write

# post the data to the database
POST="curl -i -XPOST \""$2\"" --data-binary @/tmp/temp_influx_write"
eval $POST
