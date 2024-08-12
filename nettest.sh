#!/bin/sh

COUNT=`ping -W 1 -c 1 10.0.0.1 | grep seq | wc -l`
if [ ${COUNT} == 0 ]; then
        /etc/init.d/network restart
fi

