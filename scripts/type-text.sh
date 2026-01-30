#!/bin/bash
# Type text on the Android device
# Handles special characters by escaping them properly

set -e

if [ $# -lt 1 ]; then
    echo "Usage: type-text.sh <text>"
    echo "Example: type-text.sh \"Hello World\""
    exit 1
fi

text="$*"

# For simple alphanumeric text, use input text directly
# For complex text with special chars, use input keyboard with base64

# Check if text contains only simple characters
if [[ "$text" =~ ^[a-zA-Z0-9]+$ ]]; then
    # Simple text - use input text
    adb shell input text "$text"
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

    adb shell input text "$escaped"
fi

echo "Typed: $text"
