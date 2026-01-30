#!/bin/bash
# Tap at the specified x,y coordinates on the Android device
# Usage: tap.sh [-s <serial>] <x> <y>
#   -s <serial>  Target specific device by serial number

set -e

# Parse arguments
SERIAL=""
ADB_CMD="adb"

while getopts "s:" opt; do
    case $opt in
        s) SERIAL="$OPTARG" ;;
        *) echo "Usage: tap.sh [-s <serial>] <x> <y>"; exit 1 ;;
    esac
done
shift $((OPTIND - 1))

# Build ADB command with optional serial
if [ -n "$SERIAL" ]; then
    ADB_CMD="adb -s $SERIAL"
fi

if [ $# -ne 2 ]; then
    echo "Usage: tap.sh [-s <serial>] <x> <y>"
    echo "Example: tap.sh 540 960"
    echo "Example: tap.sh -s emulator-5554 540 960"
    exit 1
fi

x="$1"
y="$2"

# Validate coordinates are numbers
if ! [[ "$x" =~ ^[0-9]+$ ]] || ! [[ "$y" =~ ^[0-9]+$ ]]; then
    echo "Error: Coordinates must be positive integers"
    exit 1
fi

$ADB_CMD shell input tap "$x" "$y"

echo "Tapped at ($x, $y)"
