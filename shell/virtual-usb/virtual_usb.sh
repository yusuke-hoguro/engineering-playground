#!/bin/bash
set -e

SOURCE_USB="/mnt/usb1"
TARGET_USB="/mnt/usb5"

ACTION="$1"

log() {
  echo "[virtual_usb] $1"
}

insert_usb() {
  log "insert start: ${SOURCE_USB} -> ${TARGET_USB}"

  if [ ! -d "$SOURCE_USB" ]; then
    echo "ERROR: source path not found: $SOURCE_USB"
    exit 1
  fi

  if [ ! -d "$TARGET_USB" ]; then
    echo "ERROR: target path not found: $TARGET_USB"
    exit 1
  fi

  # すでにマウント済みなら一度解除
  if mountpoint -q "$TARGET_USB"; then
    log "target already mounted. unmount: $TARGET_USB"
    sudo umount "$TARGET_USB"
  fi

  # USB1をUSB5として見せる
  sudo mount --bind "$SOURCE_USB" "$TARGET_USB"

  log "insert success: ${SOURCE_USB} -> ${TARGET_USB}"
}

remove_usb() {
  log "remove start: $TARGET_USB"

  if mountpoint -q "$TARGET_USB"; then
    sudo umount "$TARGET_USB"
    log "remove success: $TARGET_USB"
  else
    log "target is not mounted: $TARGET_USB"
  fi
}

status_usb() {
  log "status"

  echo "source: $SOURCE_USB"
  echo "target: $TARGET_USB"

  if mountpoint -q "$TARGET_USB"; then
    echo "mounted: yes"
    findmnt "$TARGET_USB"
  else
    echo "mounted: no"
  fi
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
    echo "Usage: $0 {insert|remove|status}"
    exit 1
    ;;
esac