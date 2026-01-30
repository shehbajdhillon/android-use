#!/bin/bash
# Check if an Android device is connected via ADB
# Usage: check-device.sh [-s <serial>]
#   -s <serial>  Target specific device by serial number

set -e

# Parse arguments
SERIAL=""
while getopts "s:" opt; do
    case $opt in
        s) SERIAL="$OPTARG" ;;
        *) echo "Usage: check-device.sh [-s <serial>]"; exit 1 ;;
    esac
done

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
    echo "Multiple devices connected ($device_count):"
    echo ""

    # List all devices with details
    while IFS= read -r line; do
        dev_serial=$(echo "$line" | awk '{print $1}')
        dev_state=$(echo "$line" | awk '{print $2}')

        if [ "$dev_state" = "device" ]; then
            dev_model=$(adb -s "$dev_serial" shell getprop ro.product.model 2>/dev/null | tr -d '\r')
            dev_type=$(adb -s "$dev_serial" shell getprop ro.build.characteristics 2>/dev/null | tr -d '\r')

            # Determine if emulator or physical device
            if [[ "$dev_serial" == emulator-* ]] || [[ "$dev_type" == *"emulator"* ]]; then
                dev_label="[EMULATOR]"
            else
                dev_label="[PHYSICAL]"
            fi

            echo "  $dev_label $dev_serial - $dev_model"
        else
            echo "  [OFFLINE]  $dev_serial - state: $dev_state"
        fi
    done <<< "$devices"

    echo ""

    if [ -z "$SERIAL" ]; then
        echo "Use -s <serial> to specify which device to use."
        echo "Example: check-device.sh -s $(echo "$devices" | head -1 | awk '{print $1}')"
        exit 1
    fi
fi

# If serial specified, verify it exists
if [ -n "$SERIAL" ]; then
    if ! echo "$devices" | grep -q "^$SERIAL"; then
        echo "Error: Device '$SERIAL' not found"
        echo ""
        echo "Available devices:"
        echo "$devices" | awk '{print "  " $1}'
        exit 1
    fi
    device_serial="$SERIAL"
else
    # Use first device
    device_serial=$(echo "$devices" | head -1 | awk '{print $1}')
fi

device_state=$(echo "$devices" | grep "^$device_serial" | awk '{print $2}')

if [ "$device_state" != "device" ]; then
    echo "Error: Device '$device_serial' is in state '$device_state' (expected 'device')"
    exit 1
fi

# Get device model and info
device_model=$(adb -s "$device_serial" shell getprop ro.product.model 2>/dev/null | tr -d '\r')
android_version=$(adb -s "$device_serial" shell getprop ro.build.version.release 2>/dev/null | tr -d '\r')
dev_type=$(adb -s "$device_serial" shell getprop ro.build.characteristics 2>/dev/null | tr -d '\r')

# Determine device type
if [[ "$device_serial" == emulator-* ]] || [[ "$dev_type" == *"emulator"* ]]; then
    device_type="Emulator"
else
    device_type="Physical"
fi

echo "Device connected: $device_model"
echo "Serial: $device_serial"
echo "Type: $device_type"
echo "Android: $android_version"
echo "Status: Ready"
