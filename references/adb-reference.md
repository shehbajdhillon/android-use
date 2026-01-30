# ADB Command Reference

Quick reference for Android Debug Bridge (ADB) commands used in this skill.

## Device Management

```bash
# List connected devices
adb devices

# Get device serial
adb get-serialno

# Get device state
adb get-state

# Restart ADB server
adb kill-server
adb start-server
```

## Device Properties

```bash
# Get device model
adb shell getprop ro.product.model

# Get Android version
adb shell getprop ro.build.version.release

# Get screen size
adb shell wm size

# Get screen density
adb shell wm density
```

## Input Commands

```bash
# Tap at coordinates
adb shell input tap <x> <y>

# Swipe from point to point
adb shell input swipe <x1> <y1> <x2> <y2> [duration_ms]

# Type text
adb shell input text "<text>"

# Press key
adb shell input keyevent <keycode>

# Long press
adb shell input swipe <x> <y> <x> <y> 1000
```

## Common Keycodes

| Key | Keycode |
|-----|---------|
| Home | 3 |
| Back | 4 |
| Call | 5 |
| End Call | 6 |
| Volume Up | 24 |
| Volume Down | 25 |
| Power | 26 |
| Camera | 27 |
| Menu | 82 |
| Enter | 66 |
| Delete/Backspace | 67 |
| Tab | 61 |
| Space | 62 |
| Escape | 111 |
| Recent Apps | 187 |
| Search | 84 |

### D-Pad Keys
| Key | Keycode |
|-----|---------|
| Up | 19 |
| Down | 20 |
| Left | 21 |
| Right | 22 |
| Center | 23 |

### Letter Keys (A-Z)
Keycodes 29-54 for A-Z

### Number Keys (0-9)
Keycodes 7-16 for 0-9

## UI Automation

```bash
# Dump UI hierarchy
adb shell uiautomator dump /sdcard/window_dump.xml
adb pull /sdcard/window_dump.xml

# Take screenshot
adb shell screencap -p /sdcard/screen.png
adb pull /sdcard/screen.png

# Record screen
adb shell screenrecord /sdcard/recording.mp4
# Stop with Ctrl+C, then pull the file
```

## App Management

```bash
# List installed packages
adb shell pm list packages

# List packages with names
adb shell pm list packages -f

# Search for package
adb shell pm list packages | grep <name>

# Install APK
adb install <path_to_apk>
adb install -r <path>  # Replace existing

# Uninstall app
adb uninstall <package_name>

# Clear app data
adb shell pm clear <package_name>

# Force stop app
adb shell am force-stop <package_name>
```

## Activity Manager

```bash
# Start activity
adb shell am start -n <package>/<activity>

# Start app's main activity
adb shell monkey -p <package> -c android.intent.category.LAUNCHER 1

# Start with action
adb shell am start -a android.intent.action.VIEW -d <uri>

# Broadcast intent
adb shell am broadcast -a <action>
```

## File Operations

```bash
# Push file to device
adb push <local_path> <device_path>

# Pull file from device
adb pull <device_path> <local_path>

# List files
adb shell ls <path>

# Remove file
adb shell rm <path>
```

## Shell Commands

```bash
# Open shell
adb shell

# Run command
adb shell <command>

# Run as root (if available)
adb root
adb shell
```

## Troubleshooting

### Device not found
1. Check USB connection
2. Enable USB debugging in Settings > Developer Options
3. Revoke and re-authorize USB debugging
4. Try different USB port/cable
5. Restart ADB server: `adb kill-server && adb start-server`

### Unauthorized device
1. On device, revoke USB debugging authorizations
2. Reconnect USB
3. Accept the "Allow USB debugging?" prompt

### Multiple devices
```bash
# Specify device
adb -s <serial> <command>

# Set default device
export ANDROID_SERIAL=<serial>
```

### Command not found
Ensure ADB is in your PATH:
```bash
# Check if ADB is installed
which adb

# Add to PATH if needed
export PATH=$PATH:/path/to/platform-tools
```

## Screen Coordinates

Android coordinates start at top-left (0, 0):
- X increases to the right
- Y increases downward

Example on 1080x1920 screen:
- Top-left: (0, 0)
- Top-right: (1080, 0)
- Bottom-left: (0, 1920)
- Bottom-right: (1080, 1920)
- Center: (540, 960)

## Parsing UI Bounds

The `bounds` attribute format: `[left,top][right,bottom]`

To calculate center for tapping:
```
x = (left + right) / 2
y = (top + bottom) / 2
```

Example: `bounds="[42,234][1038,345]"`
- left=42, top=234, right=1038, bottom=345
- center_x = (42 + 1038) / 2 = 540
- center_y = (234 + 345) / 2 = 289
- Tap command: `adb shell input tap 540 289`
