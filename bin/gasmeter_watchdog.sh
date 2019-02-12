#!/bin/bash
echo "A script executed as user loxberry."
if ps -ef | grep -v grep | grep gasmeter.py ; then
    exit 0
else
    /usr/bin/python /opt/loxberry/bin/plugins/gasmeter.py &
    logger "gasmeter.py restarted"
    exit 0
fi
