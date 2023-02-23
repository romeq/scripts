#!/bin/sh

[ -z "$FOLDER" ] && FOLDER="/home"
BACKUP_DEVICE="/dev/sda1"
MOUNT_PATH="$(mktemp -d)"
MAPPER_NAME="backups-$RANDOM"
AUTOMATIC_CONFIRM_BACKUP=0

_confirm() {
    printf "\033[32m?\033[0m Backup to '$BACKUP_DEVICE'? (y/N) > "
    read yn
    if [ "$yn" != "y" ]; then
        echo "ok then, exiting"
        exit
    fi
}

_show_plus() {
    printf "\033[35m->\033[0m $1\n"
}

_show_err() {
    printf "\033[31mError!\033[0m $1\n"
    rm -r $MOUNT_PATH
    exit 1
}

_mount_safe() {
    is_mount=$(findmnt -f -o target "$1" | tail -n 1)
    if [ "$is_mount" != "" ]; then
        export MOUNT_PATH=$is_mount
        return
    fi

    if ! mount "$1" "$MOUNT_PATH"; then
        _show_err "Failed to mount device. Check dmesg for more information."
    fi
}

_get_disk_mapping_name() {
    UUID=$(cryptsetup luksUUID "$BACKUP_DEVICE")
    UUIDSPLIT=$(echo "$UUID" | sed "s/-//g")
    FILE=$(find /dev/disk/by-id -type l -name "dm-uuid-CRYPT-LUKS2-$UUIDSPLIT-*")
    MAPPER_NAME=$(echo "$FILE" | sed "s/\/dev\/disk\/by-id\/dm-uuid-CRYPT-LUKS2-$UUIDSPLIT-//g")
    echo $MAPPER_NAME
}

_unlock_disk() {
    EXISTING_MAPPER_NAME=$(_get_disk_mapping_name)

    if [ "$EXISTING_MAPPER_NAME" = "" ]; then
        cryptsetup open "$BACKUP_DEVICE" "$MAPPER_NAME"
        if [ $? -ne 0 ]; then
            _show_err "Failed to decrypt disk!"
        fi
    else
        MAPPER_NAME="$EXISTING_MAPPER_NAME"
    fi

    _mount_safe "/dev/mapper/$MAPPER_NAME"
}

_start_backup() {
    if [ "$AUTOMATIC_CONFIRM_BACKUP" -ne 1 ]; then
        _confirm
    fi

    _show_plus "Backup confirmed, proceeding"

    if cryptsetup isLuks "$BACKUP_DEVICE"; then 
        _show_plus "Backup device appears to be encrypted. Unlocking"
        _unlock_disk
    else 
        _mount_safe "$BACKUP_DEVICE"
    fi

    _show_plus "Starting to transfer files: $FOLDER -> $MOUNT_PATH"
    if ! cp -r "$FOLDER" "$MOUNT_PATH"; then
        _show_err "Oops! Failed to copy files!"
    fi

    if ! umount "$MOUNT_PATH"; then
        _show_err "Failed to unmount backup device!"
    fi


    _show_plus "Backup was done. Remember to close your drive! :)"
}

_start_backup
