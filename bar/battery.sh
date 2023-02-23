#!/bin/sh
battery="BAT0" # replace your battery here
battery_capacity="$(cat /sys/class/power_supply/$battery/capacity)"
battery_status="$(cat /sys/class/power_supply/$battery/status)"

emoji=""
if [ ! "$battery_capacity" ]; then
    emoji=""
elif [ "$battery_status" != "Charging" ]; then
    if [ "$battery_capacity" -lt 10 ]; then
        emoji=""
    elif [ "$battery_capacity" -lt 20 ]; then
        emoji=""
    elif [ "$battery_capacity" -lt 30 ]; then
        emoji=""
    elif [ "$battery_capacity" -lt 40 ]; then
        emoji=""
    elif [ "$battery_capacity" -lt 50 ]; then
        emoji=""
    elif [ "$battery_capacity" -lt 60 ]; then
        emoji=""
    elif [ "$battery_capacity" -lt 70 ]; then
        emoji=""
    elif [ "$battery_capacity" -lt 80 ]; then
        emoji=""
    elif [ "$battery_capacity" -lt 90 ]; then
        emoji=""
    elif [ "$battery_capacity" -lt 100 ]; then
        emoji=""
    fi
else
    emoji=""
fi

if [ "$battery_status" != "Unknown" ]; then
    echo "$emoji $battery_capacity% ($battery_status)"
else
    echo "$emoji $battery_capacity%"
fi
