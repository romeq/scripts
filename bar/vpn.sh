#!/bin/sh
tun0_dir="/sys/class/net/nordlynx/"

if [ -e "$tun0_dir" ]; then
    echo " VPN"
else
    echo " Off"
fi
