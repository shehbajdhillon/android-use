#!/bin/bash
# Tap at the specified x,y coordinates on the Android device

set -e

if [ $# -ne 2 ]; then
    echo "Usage: tap.sh <x> <y>"
    echo "Example: tap.sh 540 960"
    exit 1
fi

x="$1"
y="$2"

# Validate coordinates are numbers
if ! [[ "$x" =~ ^[0-9]+$ ]] || ! [[ "$y" =~ ^[0-9]+$ ]]; then
    echo "Error: Coordinates must be positive integers"
    exit 1
fi

adb shell input tap "$x" "$y"

echo "Tapped at ($x, $y)"
