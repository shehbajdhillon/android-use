#!/bin/bash
# Type text on the Android device
# Handles special characters by escaping them properly
# Usage: type-text.sh [-s <serial>] <text>
#   -s <serial>  Target specific device by serial number

set -e

# Parse arguments
SERIAL=""
ADB_CMD="adb"

while getopts "s:" opt; do
    case $opt in
        s) SERIAL="$OPTARG" ;;
        *) echo "Usage: type-text.sh [-s <serial>] <text>"; exit 1 ;;
    esac
done
shift $((OPTIND - 1))

# Build ADB command with optional serial
if [ -n "$SERIAL" ]; then
    ADB_CMD="adb -s $SERIAL"
fi

if [ $# -lt 1 ]; then
    echo "Usage: type-text.sh [-s <serial>] <text>"
    echo "Example: type-text.sh \"Hello World\""
    echo "Example: type-text.sh -s 1A051FDF6007PA \"Hello World\""
    exit 1
fi

text="$*"

# For simple alphanumeric text, use input text directly
# For complex text with special chars, escape them

# Check if text contains only simple characters
if [[ "$text" =~ ^[a-zA-Z0-9]+$ ]]; then
    # Simple text - use input text
    $ADB_CMD shell input text "$text"
else
    # Complex text - escape special characters for shell
    # Replace spaces with %s (ADB convention)
    escaped="${text// /%s}"

    # Escape shell special characters
    escaped="${escaped//\'/\\\'}"
    escaped="${escaped//\"/\\\"}"
    escaped="${escaped//\\/\\\\}"
    escaped="${escaped//\(/\\\(}"
    escaped="${escaped//\)/\\\)}"
    escaped="${escaped//\&/\\\&}"
    escaped="${escaped//\|/\\\|}"
    escaped="${escaped//\;/\\\;}"
    escaped="${escaped//\</\\\<}"
    escaped="${escaped//\>/\\\>}"
    escaped="${escaped//\$/\\\$}"
    escaped="${escaped//\`/\\\`}"

    $ADB_CMD shell input text "$escaped"
fi

echo "Typed: $text"
