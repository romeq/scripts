#!/bin/sh

interface="wlan0" # replace your interface here
operstate="$(cat /sys/class/net/$interface/operstate)"

if [ "$operstate" != "up" ]; then 
    echo "睊 Off"
else
    echo "  Wi-Fi"
fi

