#!/bin/sh
/usr/local/bin/peersData
python /var/run/latency/push.py
/usr/bin/curl -i -XPOST 'http://10.0.116.204:8086/write?db=endpoint_latency' --data-binary @/var/run/latency/push.data
rm /var/run/latency/push.data
