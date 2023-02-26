#!/bin/sh

[ -z "$DISK" ] && DISK="/dev/sda1"
[ -z "$MOUNTPATH" ] && MOUNTPATH="/mnt"
[ -z "$SCRIPTMODE" ] && SCRIPTMODE=0

friendly_echo() {
    [ "$SCRIPTMODE" = 0 ] && printf "\033[32mfriendly\033[0m: $1\n"
}

angry_echo() {
    printf "\033[31mangry\033[0m: $1\n"
}

close_disk() {
    mapping="$(get_existing_mapping)"
    [ -z "$mapping" ] && exit 0
    friendly_echo "closing mapping: '\033[93m$mapping\033[0m'"

    if ! umount "/dev/mapper/$mapping"; then
        angry_echo "failed to unmount: $DISK"
        exit 1
    fi

    if ! cryptsetup close "$mapping"; then
        angry_echo "failed to close mapping: $DISK"
        exit 1
    fi
}

get_existing_mapping() {
    UUID=$(cryptsetup luksUUID "$DISK" 2>/dev/null)
    UUIDSPLIT=$(echo "$UUID" | sed "s/-//g" 2>/dev/null)
    FILE=$(find /dev/disk/by-id -type l -name "dm-uuid-CRYPT-LUKS2-$UUIDSPLIT-*" 2>/dev/null)
    echo "$FILE" | sed "s/\/dev\/disk\/by-id\/dm-uuid-CRYPT-LUKS2-$UUIDSPLIT-//g"
}

open_new_mapping() {
    mapping_name="workflow-open-$RANDOM"
    if ! cryptsetup open "$DISK" "$mapping_name"; then
        angry_echo "failed to open: $DISK!"
        exit 1
    fi
    echo $mapping_name
}

# $1 == Disk to be mounted
angryfriendly_mount() {
    disk_name_sum="$(echo $1 | sha1sum | awk '{print $1}')"

    mid_file="$HOME/.cache/.mount-$disk_name_sum"

    if [ -e "$mid_file" ]; then
        mid=$(cat $mid_file)
        if ! findmnt -f $mid >/dev/null; then
            m=1
        else
            friendly_echo "already mount at \033[35m$mid\033[0m"
        fi
        mountpath="$mid"
    else
        mountpath="$MOUNTPATH/mount-$RANDOM"
        echo "$mountpath" >"$mid_file"
        m=1
    fi

    if [ "$m" = "1" ]; then
        friendly_echo "Mounting to: \033[35m$mountpath\033[0m"
        if ! mount --mkdir "$1" "$mountpath"; then
            angry_echo "you screwed up, fool."
            angry_echo "mount failed."
            exit 1
        fi
    fi

    if [ "$SCRIPTMODE" = "1" ]; then
        echo "$mountpath"
    fi
}

open_encrypted_disk() {
    existing_mapping_name="$(get_existing_mapping)"
    if [ -z "$existing_mapping_name" ]; then
        mapping_name="$(open_new_mapping)"
    else
        mapping_name="$existing_mapping_name"
    fi

    friendly_echo "Mounting from: \033[35m/dev/mapper/$mapping_name\033[0m"
    angryfriendly_mount "/dev/mapper/$mapping_name"
}

if [ "$#" -ne 1 ]; then
    echo "usage: $0 <[-o: open] [-c: close]>" >/dev/stderr
    exit 1
fi

if [ "$1" = "-o" ]; then
    # check perms
    if [ ! -b "$DISK" ] || [ ! -r "$DISK" ] || [ ! -w "$DISK" ]; then
        angry_echo "Not enough permissions to access disk"
        exit 1
    fi

    if cryptsetup isLuks "$DISK"; then
        open_encrypted_disk
    else
        angryfriendly_mount "$DISK"
    fi
elif [ "$1" = "-c" ]; then
    close_disk
else
    echo "flag $1 not found"
fi
