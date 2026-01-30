#!/bin/bash
# Install an APK file to the Android device

set -e

if [ $# -ne 1 ]; then
    echo "Usage: install-apk.sh <path_to_apk>"
    echo "Example: install-apk.sh /path/to/app.apk"
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
result=$(adb install -r "$apk_path" 2>&1)

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
