#!/bin/bash
# Wake up the Android device and dismiss lock screen
# Usage: wake.sh [-s <serial>]
#   -s <serial>  Target specific device by serial number

set -e

# Parse arguments
SERIAL=""
ADB_CMD="adb"

while getopts "s:" opt; do
    case $opt in
        s) SERIAL="$OPTARG" ;;
        *) echo "Usage: wake.sh [-s <serial>]"; exit 1 ;;
    esac
done

# Build ADB command with optional serial
if [ -n "$SERIAL" ]; then
    ADB_CMD="adb -s $SERIAL"
fi

# Check if screen is on or off
# mScreenState=ON or mScreenState=OFF (varies by Android version)
screen_state=$($ADB_CMD shell "dumpsys display | grep -E 'mScreenState|Display Power: state'" 2>/dev/null | head -1)

is_screen_on() {
    if echo "$screen_state" | grep -qiE "ON|BRIGHT"; then
        return 0
    else
        return 1
    fi
}

if is_screen_on; then
    echo "Screen already on"
else
    echo "Screen is off, waking device..."

    # Send WAKEUP keyevent (224)
    $ADB_CMD shell input keyevent 224

    # Brief wait for screen to turn on
    sleep 0.5

    # Get screen dimensions for swipe
    size=$($ADB_CMD shell wm size | grep -oE '[0-9]+x[0-9]+' | tail -1)
    width=$(echo "$size" | cut -d'x' -f1)
    height=$(echo "$size" | cut -d'x' -f2)

    # Calculate swipe coordinates (bottom center to middle)
    center_x=$((width / 2))
    start_y=$((height * 4 / 5))
    end_y=$((height / 3))

    # Swipe up to dismiss lock screen (works for swipe-to-unlock)
    # Won't bypass PIN/pattern/password - user must handle that
    $ADB_CMD shell input swipe $center_x $start_y $center_x $end_y 300

    sleep 0.3

    echo "Woke device and dismissed lock screen"
fi

# Verify final state
final_state=$($ADB_CMD shell "dumpsys display | grep -E 'mScreenState|Display Power: state'" 2>/dev/null | head -1)
if echo "$final_state" | grep -qiE "ON|BRIGHT"; then
    echo "Status: Screen is now on"
else
    echo "Status: Screen may still be off (check for PIN/pattern lock)"
fi
