#!/bin/bash
# Dump the current UI hierarchy (accessibility tree) from the Android device

set -e

# Paths
DEVICE_PATH="/sdcard/window_dump.xml"
LOCAL_PATH="/tmp/android_ui_dump.xml"

# Dump UI hierarchy on device
adb shell uiautomator dump "$DEVICE_PATH" > /dev/null 2>&1

# Pull the file
adb pull "$DEVICE_PATH" "$LOCAL_PATH" > /dev/null 2>&1

# Clean up device file
adb shell rm -f "$DEVICE_PATH" > /dev/null 2>&1

# Output the XML content
cat "$LOCAL_PATH"
