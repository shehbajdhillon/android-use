#!/bin/bash
# Press a key on the Android device

set -e

if [ $# -ne 1 ]; then
    echo "Usage: key.sh <keyname>"
    echo "Keys: home, back, enter, recent, menu, search, power, volume_up, volume_down, tab, delete"
    echo "Example: key.sh home"
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

adb shell input keyevent "$keycode"

echo "Pressed $keyname (keycode $keycode)"
