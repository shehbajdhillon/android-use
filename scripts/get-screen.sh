#!/bin/bash
# Dump the current UI hierarchy (accessibility tree) from the Android device
# Usage: get-screen.sh [-s <serial>]
#   -s <serial>  Target specific device by serial number

set -e

# Parse arguments
SERIAL=""
ADB_CMD="adb"

while getopts "s:" opt; do
    case $opt in
        s) SERIAL="$OPTARG" ;;
        *) echo "Usage: get-screen.sh [-s <serial>]"; exit 1 ;;
    esac
done

# Build ADB command with optional serial
if [ -n "$SERIAL" ]; then
    ADB_CMD="adb -s $SERIAL"
fi

# Paths
DEVICE_PATH="/sdcard/window_dump.xml"
LOCAL_PATH="/tmp/android_ui_dump.xml"

# Dump UI hierarchy on device
$ADB_CMD shell uiautomator dump "$DEVICE_PATH" > /dev/null 2>&1

# Pull the file
$ADB_CMD pull "$DEVICE_PATH" "$LOCAL_PATH" > /dev/null 2>&1

# Clean up device file
$ADB_CMD shell rm -f "$DEVICE_PATH" > /dev/null 2>&1

# Output the XML content
cat "$LOCAL_PATH"
