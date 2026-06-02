#!/bin/bash
set -e

ACTION="$1"
SOURCE_USB="$2"
TARGET_USB="$3"

BASE_SOURCE="/mnt"
BASE_TARGET="/mnt"

log() {
    echo "[virtual_usb] $1"
}

validate_source() {
    case "$1" in
        usb1|usb2|usb3|usb4)
            ;;
        *)
            echo "ERROR: invalid source usb: $1"
            exit 1
            ;;
    esac
}

validate_target() {
    case "$1" in
        usb5|usb6|usb7|usb8)
            ;;
        *)
            echo "ERROR: invalid target usb: $1"
            exit 1
            ;;
    esac
}

insert_usb() {

    validate_source "$SOURCE_USB"
    validate_target "$TARGET_USB"

    SOURCE_PATH="${BASE_SOURCE}/${SOURCE_USB}"
    TARGET_PATH="${BASE_TARGET}/${TARGET_USB}"

    log "insert start: ${SOURCE_PATH} -> ${TARGET_PATH}"

    if [ ! -d "$SOURCE_PATH" ]; then
        echo "ERROR: source path not found: $SOURCE_PATH"
        exit 1
    fi

    if [ ! -d "$TARGET_PATH" ]; then
        echo "ERROR: target path not found: $TARGET_PATH"
        exit 1
    fi

    if mountpoint -q "$TARGET_PATH"; then
        log "already mounted. unmount first"
        sudo umount "$TARGET_PATH"
    fi

    sudo mount --bind "$SOURCE_PATH" "$TARGET_PATH"

    log "insert success"
}

remove_usb() {

    validate_target "$TARGET_USB"

    TARGET_PATH="${BASE_TARGET}/${TARGET_USB}"

    log "remove start: ${TARGET_PATH}"

    if mountpoint -q "$TARGET_PATH"; then
        sudo umount "$TARGET_PATH"
        log "remove success"
    else
        log "not mounted"
    fi
}

status_usb() {

    for usb in usb5 usb6 usb7 usb8
    do
        TARGET_PATH="${BASE_TARGET}/${usb}"

        echo "--------------------------------"

        if mountpoint -q "$TARGET_PATH"; then
            echo "${usb}: mounted"
            findmnt "$TARGET_PATH"
        else
            echo "${usb}: not mounted"
        fi
    done
}

case "$ACTION" in

    insert)
        insert_usb
        ;;

    remove)
        remove_usb
        ;;

    status)
        status_usb
        ;;

    *)
        echo "Usage:"
        echo "$0 insert usb1 usb5"
        echo "$0 insert usb2 usb6"
        echo "$0 remove usb5"
        echo "$0 status"
        exit 1
        ;;
esac