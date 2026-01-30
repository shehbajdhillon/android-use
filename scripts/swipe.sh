#!/bin/bash
# Swipe in a direction on the Android device

set -e

if [ $# -ne 1 ]; then
    echo "Usage: swipe.sh <direction>"
    echo "Directions: up, down, left, right"
    echo "Example: swipe.sh up"
    exit 1
fi

direction="$1"

# Get screen dimensions
screen_size=$(adb shell wm size | grep -oE '[0-9]+x[0-9]+' | head -1)
width=$(echo "$screen_size" | cut -d'x' -f1)
height=$(echo "$screen_size" | cut -d'x' -f2)

# Calculate center and edges
center_x=$((width / 2))
center_y=$((height / 2))

# Swipe margins (20% from edges)
margin_x=$((width / 5))
margin_y=$((height / 5))

# Swipe duration in milliseconds
duration=300

case "$direction" in
    up)
        # Swipe up (scrolls content down)
        x1=$center_x
        y1=$((height - margin_y))
        x2=$center_x
        y2=$margin_y
        ;;
    down)
        # Swipe down (scrolls content up)
        x1=$center_x
        y1=$margin_y
        x2=$center_x
        y2=$((height - margin_y))
        ;;
    left)
        # Swipe left
        x1=$((width - margin_x))
        y1=$center_y
        x2=$margin_x
        y2=$center_y
        ;;
    right)
        # Swipe right
        x1=$margin_x
        y1=$center_y
        x2=$((width - margin_x))
        y2=$center_y
        ;;
    *)
        echo "Error: Unknown direction '$direction'"
        echo "Use: up, down, left, right"
        exit 1
        ;;
esac

adb shell input swipe "$x1" "$y1" "$x2" "$y2" "$duration"

echo "Swiped $direction (from $x1,$y1 to $x2,$y2)"
