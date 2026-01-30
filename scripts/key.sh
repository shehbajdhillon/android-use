#!/bin/bash
# Press a key on the Android device
# Usage: key.sh [-s <serial>] <keyname>
#   -s <serial>  Target specific device by serial number

set -e

# Parse arguments
SERIAL=""
ADB_CMD="adb"

while getopts "s:" opt; do
    case $opt in
        s) SERIAL="$OPTARG" ;;
        *) echo "Usage: key.sh [-s <serial>] <keyname>"; exit 1 ;;
    esac
done
shift $((OPTIND - 1))

# Build ADB command with optional serial
if [ -n "$SERIAL" ]; then
    ADB_CMD="adb -s $SERIAL"
fi

if [ $# -ne 1 ]; then
    echo "Usage: key.sh [-s <serial>] <keyname>"
    echo "Keys: home, back, enter, recent, menu, search, power, volume_up, volume_down, tab, delete"
    echo "Example: key.sh home"
    echo "Example: key.sh -s 1A051FDF6007PA back"
    exit 1
fi

keyname="$1"

# Map key names to Android keycodes
case "$keyname" in
    home)
        keycode=3
        ;;
    back)
        keycode=4
        ;;
    enter|return)
        keycode=66
        ;;
    recent|recents|overview)
        keycode=187
        ;;
    menu)
        keycode=82
        ;;
    search)
        keycode=84
        ;;
    power)
        keycode=26
        ;;
    volume_up|vol_up)
        keycode=24
        ;;
    volume_down|vol_down)
        keycode=25
        ;;
    tab)
        keycode=61
        ;;
    delete|del|backspace)
        keycode=67
        ;;
    space)
        keycode=62
        ;;
    escape|esc)
        keycode=111
        ;;
    dpad_up)
        keycode=19
        ;;
    dpad_down)
        keycode=20
        ;;
    dpad_left)
        keycode=21
        ;;
    dpad_right)
        keycode=22
        ;;
    dpad_center)
        keycode=23
        ;;
    *)
        # Check if it's a numeric keycode
        if [[ "$keyname" =~ ^[0-9]+$ ]]; then
            keycode=$keyname
        else
            echo "Error: Unknown key '$keyname'"
            echo "Available keys: home, back, enter, recent, menu, search, power, volume_up, volume_down, tab, delete, space, escape"
            echo "Or use numeric keycode directly"
            exit 1
        fi
        ;;
esac

$ADB_CMD shell input keyevent "$keycode"

echo "Pressed $keyname (keycode $keycode)"
