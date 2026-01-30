#!/bin/bash
# Launch an app on the Android device by package name or app name
# Usage: launch-app.sh [-s <serial>] <package_name_or_app_name>
#   -s <serial>  Target specific device by serial number

set -e

# Parse arguments
SERIAL=""
ADB_CMD="adb"

while getopts "s:" opt; do
    case $opt in
        s) SERIAL="$OPTARG" ;;
        *) echo "Usage: launch-app.sh [-s <serial>] <package_name_or_app_name>"; exit 1 ;;
    esac
done
shift $((OPTIND - 1))

# Build ADB command with optional serial
if [ -n "$SERIAL" ]; then
    ADB_CMD="adb -s $SERIAL"
fi

if [ $# -lt 1 ]; then
    echo "Usage: launch-app.sh [-s <serial>] <package_name_or_app_name>"
    echo "Examples:"
    echo "  launch-app.sh com.android.chrome"
    echo "  launch-app.sh Chrome"
    echo "  launch-app.sh -s emulator-5554 settings"
    exit 1
fi

app="$1"

# Common app package mappings
declare -A common_apps=(
    ["chrome"]="com.android.chrome"
    ["settings"]="com.android.settings"
    ["phone"]="com.android.dialer"
    ["dialer"]="com.android.dialer"
    ["messages"]="com.google.android.apps.messaging"
    ["sms"]="com.google.android.apps.messaging"
    ["camera"]="com.android.camera"
    ["photos"]="com.google.android.apps.photos"
    ["gmail"]="com.google.android.gm"
    ["maps"]="com.google.android.apps.maps"
    ["youtube"]="com.google.android.youtube"
    ["play store"]="com.android.vending"
    ["playstore"]="com.android.vending"
    ["calendar"]="com.google.android.calendar"
    ["clock"]="com.google.android.deskclock"
    ["calculator"]="com.google.android.calculator"
    ["contacts"]="com.android.contacts"
    ["files"]="com.google.android.documentsui"
    ["whatsapp"]="com.whatsapp"
    ["instagram"]="com.instagram.android"
    ["facebook"]="com.facebook.katana"
    ["twitter"]="com.twitter.android"
    ["x"]="com.twitter.android"
    ["spotify"]="com.spotify.music"
    ["netflix"]="com.netflix.mediaclient"
    ["telegram"]="org.telegram.messenger"
    ["discord"]="com.discord"
    ["slack"]="com.Slack"
    ["zoom"]="us.zoom.videomeetings"
    ["teams"]="com.microsoft.teams"
    ["outlook"]="com.microsoft.office.outlook"
    ["drive"]="com.google.android.apps.docs"
    ["keep"]="com.google.android.keep"
    ["notes"]="com.google.android.keep"
)

# Convert to lowercase for matching
app_lower=$(echo "$app" | tr '[:upper:]' '[:lower:]')

# Check if it's a known app name
if [ -n "${common_apps[$app_lower]}" ]; then
    package="${common_apps[$app_lower]}"
    echo "Resolved '$app' to package: $package"
elif [[ "$app" == *"."* ]]; then
    # Looks like a package name (contains dots)
    package="$app"
else
    # Try to find the package by searching installed apps
    echo "Searching for app: $app"

    # Get list of installed packages and their labels
    matches=$($ADB_CMD shell pm list packages -f 2>/dev/null | grep -i "$app" | head -5)

    if [ -z "$matches" ]; then
        echo "Error: Could not find app '$app'"
        echo ""
        echo "Try using the full package name, e.g.:"
        echo "  com.example.myapp"
        echo ""
        echo "Or use one of these common app names:"
        echo "  chrome, settings, messages, camera, photos, gmail, maps, youtube"
        exit 1
    fi

    # Extract first matching package
    package=$(echo "$matches" | head -1 | sed 's/package://' | sed 's/=.*//' | rev | cut -d'/' -f1 | rev)

    if [ -z "$package" ]; then
        echo "Error: Could not parse package from matches"
        echo "Matches found:"
        echo "$matches"
        exit 1
    fi

    echo "Found package: $package"
fi

# Try to get the main activity using monkey
echo "Launching $package..."

# Method 1: Use monkey to launch (most reliable)
result=$($ADB_CMD shell monkey -p "$package" -c android.intent.category.LAUNCHER 1 2>&1)

if echo "$result" | grep -q "No activities found"; then
    # Method 2: Try am start with action MAIN
    echo "Trying alternative launch method..."
    $ADB_CMD shell am start -a android.intent.action.MAIN -c android.intent.category.LAUNCHER "$package" 2>/dev/null || {
        echo "Error: Failed to launch $package"
        echo "The app may not be installed or may not have a launcher activity."
        exit 1
    }
fi

echo "Launched: $package"
