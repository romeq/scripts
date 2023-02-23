#!/bin/sh

sink="$(pactl list sinks short | grep RUNNING | sed -e 's,^\([0-9][0-9]*\)[^0-9].*,\1,')"
volume="$(pactl list sinks | grep '^[[:space:]]Volume:' | \
    head -n $(( $sink + 1 )) | tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,')"

echo "  $volume%"
