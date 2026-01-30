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

# Convert to lowercase for matching
app_lower=$(echo "$app" | tr '[:upper:]' '[:lower:]')

# Map common app names to package names
get_package() {
    case "$1" in
        chrome) echo "com.android.chrome" ;;
        settings) echo "com.android.settings" ;;
        phone|dialer) echo "com.android.dialer" ;;
        messages|sms) echo "com.google.android.apps.messaging" ;;
        camera) echo "com.android.camera" ;;
        photos) echo "com.google.android.apps.photos" ;;
        gmail) echo "com.google.android.gm" ;;
        maps) echo "com.google.android.apps.maps" ;;
        youtube) echo "com.google.android.youtube" ;;
        playstore|play_store) echo "com.android.vending" ;;
        calendar) echo "com.google.android.calendar" ;;
        clock) echo "com.google.android.deskclock" ;;
        calculator) echo "com.google.android.calculator" ;;
        contacts) echo "com.android.contacts" ;;
        files) echo "com.google.android.documentsui" ;;
        whatsapp) echo "com.whatsapp" ;;
        instagram) echo "com.instagram.android" ;;
        facebook) echo "com.facebook.katana" ;;
        twitter|x) echo "com.twitter.android" ;;
        spotify) echo "com.spotify.music" ;;
        netflix) echo "com.netflix.mediaclient" ;;
        telegram) echo "org.telegram.messenger" ;;
        discord) echo "com.discord" ;;
        slack) echo "com.Slack" ;;
        zoom) echo "us.zoom.videomeetings" ;;
        teams) echo "com.microsoft.teams" ;;
        outlook) echo "com.microsoft.office.outlook" ;;
        drive) echo "com.google.android.apps.docs" ;;
        keep|notes) echo "com.google.android.keep" ;;
        *) echo "" ;;
    esac
}

# Check if it's a known app name
package=$(get_package "$app_lower")

if [ -n "$package" ]; then
    echo "Resolved '$app' to package: $package"
elif [[ "$app" == *"."* ]]; then
    # Looks like a package name (contains dots)
    package="$app"
else
    # Try to find the package by searching installed apps
    echo "Searching for app: $app"

    # Get list of installed packages and their labels
    matches=$($ADB_CMD shell pm list packages 2>/dev/null | grep -i "$app" | head -5)

    if [ -z "$matches" ]; then
        echo "Error: Could not find app '$app'"
        echo ""
        echo "Try using the full package name, e.g.:"
        echo "  com.example.myapp"
        echo ""
        echo "Or use one of these common app names:"
        echo "  chrome, settings, messages, camera, photos, gmail, maps, youtube"
        echo "  instagram, whatsapp, facebook, twitter, spotify, telegram, discord"
        exit 1
    fi

    # Extract first matching package
    package=$(echo "$matches" | head -1 | sed 's/package://')

    if [ -z "$package" ]; then
        echo "Error: Could not parse package from matches"
        echo "Matches found:"
        echo "$matches"
        exit 1
    fi

    echo "Found package: $package"
fi

# Launch the app
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
