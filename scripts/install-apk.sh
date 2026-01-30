#!/bin/bash
# Install an APK file to the Android device
# Usage: install-apk.sh [-s <serial>] <path_to_apk>
#   -s <serial>  Target specific device by serial number

set -e

# Parse arguments
SERIAL=""
ADB_CMD="adb"

while getopts "s:" opt; do
    case $opt in
        s) SERIAL="$OPTARG" ;;
        *) echo "Usage: install-apk.sh [-s <serial>] <path_to_apk>"; exit 1 ;;
    esac
done
shift $((OPTIND - 1))

# Build ADB command with optional serial
if [ -n "$SERIAL" ]; then
    ADB_CMD="adb -s $SERIAL"
fi

if [ $# -ne 1 ]; then
    echo "Usage: install-apk.sh [-s <serial>] <path_to_apk>"
    echo "Example: install-apk.sh /path/to/app.apk"
    echo "Example: install-apk.sh -s emulator-5554 /path/to/app.apk"
    exit 1
fi

apk_path="$1"

# Check if file exists
if [ ! -f "$apk_path" ]; then
    echo "Error: APK file not found: $apk_path"
    exit 1
fi

# Check if it's an APK file
if [[ ! "$apk_path" == *.apk ]]; then
    echo "Warning: File does not have .apk extension"
fi

# Get file size
file_size=$(ls -lh "$apk_path" | awk '{print $5}')
echo "Installing APK: $apk_path"
echo "Size: $file_size"
echo ""

# Install the APK
# -r: replace existing application
# -t: allow test packages
# -d: allow version code downgrade
result=$($ADB_CMD install -r "$apk_path" 2>&1)

if echo "$result" | grep -q "Success"; then
    echo "Installation successful!"

    # Try to get the package name from the APK
    if command -v aapt &> /dev/null; then
        package=$(aapt dump badging "$apk_path" 2>/dev/null | grep "package:" | sed "s/.*name='//" | sed "s/'.*//")
        if [ -n "$package" ]; then
            echo "Package: $package"
        fi
    fi
else
    echo "Installation failed!"
    echo "$result"
    exit 1
fi
