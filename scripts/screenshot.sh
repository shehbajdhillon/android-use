#!/bin/bash
# Take a screenshot of the Android device
# Usage: screenshot.sh [-s <serial>]
#   -s <serial>  Target specific device by serial number

set -e

# Parse arguments
SERIAL=""
ADB_CMD="adb"

while getopts "s:" opt; do
    case $opt in
        s) SERIAL="$OPTARG" ;;
        *) echo "Usage: screenshot.sh [-s <serial>]"; exit 1 ;;
    esac
done

# Build ADB command with optional serial
if [ -n "$SERIAL" ]; then
    ADB_CMD="adb -s $SERIAL"
fi

# Paths
DEVICE_PATH="/sdcard/screen.png"
LOCAL_DIR="/tmp"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOCAL_PATH="$LOCAL_DIR/android_screenshot_$TIMESTAMP.png"

# Take screenshot on device
$ADB_CMD shell screencap -p "$DEVICE_PATH"

# Pull to local
$ADB_CMD pull "$DEVICE_PATH" "$LOCAL_PATH" > /dev/null 2>&1

# Clean up device file
$ADB_CMD shell rm -f "$DEVICE_PATH" > /dev/null 2>&1

echo "Screenshot saved: $LOCAL_PATH"
echo ""
echo "Use the Read tool to view this image."
