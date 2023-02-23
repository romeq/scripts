#!/bin/sh

# scripts to get specific information
volume="$HOME/scripts/bar/volume.sh"
wifi="$HOME/scripts/bar/wifi.sh"
vpn="$HOME/scripts/bar/vpn.sh"
mem="$HOME/scripts/bar/mem.sh"
weather="$HOME/scripts/bar/weather.sh"
battery="$HOME/scripts/bar/battery.sh"
brightness="$HOME/scripts/bar/brightness.sh"
clock="$HOME/scripts/bar/date.sh"
song="$HOME/scripts/bar/song.sh"
bar_scripts="$volume $wifi $vpn $mem $battery $brightness $clock $song"

# update interval
interval=2
seperator="/ "

print_bar_output() {
    output_string=""
    for script in $bar_scripts; do
        output_string+="$($script 2> /dev/null) $seperator"
    done
    echo "$output_string"
}

print_bar_output
while true; do
    print_bar_output
    sleep $interval
done
