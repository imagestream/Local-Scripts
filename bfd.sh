#!/bin/bash
# Usage: bfd.sh <hostname of system> <influxdb url>

HOSTNAME=$1

timeout -s 9 20 vtysh -c "show bfd peers json"     >> /tmp/bfd_peers
timeout -s 9 20 vtysh -c "show bfd peers counters json" >> /tmp/bfd_counters


PEER=$(cat /tmp/bfd_peers |  /usr/bin/jsonfilter -a -e '@[0][*]["peer"]')
UPTIME=$(cat /tmp/bfd_peers |  /usr/bin/jsonfilter -a -e '@[0][*]["uptime"]')
#DOWNTIME=$(cat /tmp/bfd_peers |  /usr/bin/jsonfilter -a -e '@[0][*]["downtime"]')
SESSION_UP=$(cat /tmp/bfd_counters |  /usr/bin/jsonfilter -a -e '@[0][*]["session-up"]')
SESSION_DOWN=$(cat /tmp/bfd_counters |  /usr/bin/jsonfilter -a -e '@[0][*]["session-down"]')
CPACKET_IN=$(cat /tmp/bfd_counters |  /usr/bin/jsonfilter -a -e '@[0][*]["control-packet-input"]')
CPACKET_OUT=$(cat /tmp/bfd_counters |  /usr/bin/jsonfilter -a -e '@[0][*]["control-packet-output"]')

echo "bfd_uptime,Hostname=$HOSTNAME,peer=$PEER value=$UPTIME"                   >> /tmp/bfd_influx_write
#echo "bfd_downtime,Hostname=$HOSTNAME,peer=$PEER value=$DOWNTIME"              >> /tmp/bfd_influx_write
echo "session_up_count,Hostname=$HOSTNAME,peer=$PEER value=$SESSION_UP"         >> /tmp/bfd_influx_write
echo "session_down_count,Hostname=$HOSTNAME,peer=$PEER value=$SESSION_DOWN"     >> /tmp/bfd_influx_write
echo "cpacket_in,Hostname=$HOSTNAME,peer=$PEER value=$CPACKET_IN"               >> /tmp/bfd_influx_write
echo "cpacket_out,Hostname=$HOSTNAME,peer=$PEER value=$CPACKET_OUT"             >> /tmp/bfd_influx_write


# post the data to the database
POST="curl -i -XPOST \""$2\"" --data-binary @/tmp/bfd_influx_write"
eval $POST


rm /tmp/bfd_peers
rm /tmp/bfd_counters
rm /tmp/bfd_influx_write
