#!/bin/bash
# Check if an Android device is connected via ADB

set -e

# Check if adb is available
if ! command -v adb &> /dev/null; then
    echo "Error: adb is not installed or not in PATH"
    exit 1
fi

# Get list of connected devices
devices=$(adb devices | grep -v "List of devices" | grep -v "^$" | grep -v "offline")

if [ -z "$devices" ]; then
    echo "Error: No Android device connected"
    echo ""
    echo "Troubleshooting:"
    echo "1. Connect your device via USB"
    echo "2. Enable USB debugging in Developer Options"
    echo "3. Accept the 'Allow USB debugging?' prompt on device"
    echo "4. Run 'adb devices' to verify"
    exit 1
fi

# Count connected devices
device_count=$(echo "$devices" | wc -l | tr -d ' ')

if [ "$device_count" -gt 1 ]; then
    echo "Warning: Multiple devices connected ($device_count)"
    echo "Using first device. Set ANDROID_SERIAL to specify a device."
    echo ""
fi

# Get device info
device_serial=$(echo "$devices" | head -1 | awk '{print $1}')
device_state=$(echo "$devices" | head -1 | awk '{print $2}')

if [ "$device_state" != "device" ]; then
    echo "Error: Device '$device_serial' is in state '$device_state' (expected 'device')"
    exit 1
fi

# Get device model
device_model=$(adb -s "$device_serial" shell getprop ro.product.model 2>/dev/null | tr -d '\r')
android_version=$(adb -s "$device_serial" shell getprop ro.build.version.release 2>/dev/null | tr -d '\r')

echo "Device connected: $device_model"
echo "Serial: $device_serial"
echo "Android: $android_version"
echo "Status: Ready"
