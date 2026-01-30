#!/bin/bash
# Take a screenshot of the Android device

set -e

# Paths
DEVICE_PATH="/sdcard/screen.png"
LOCAL_DIR="/tmp"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOCAL_PATH="$LOCAL_DIR/android_screenshot_$TIMESTAMP.png"

# Take screenshot on device
adb shell screencap -p "$DEVICE_PATH"

# Pull to local
adb pull "$DEVICE_PATH" "$LOCAL_PATH" > /dev/null 2>&1

# Clean up device file
adb shell rm -f "$DEVICE_PATH" > /dev/null 2>&1

echo "Screenshot saved: $LOCAL_PATH"
echo ""
echo "Use the Read tool to view this image."
