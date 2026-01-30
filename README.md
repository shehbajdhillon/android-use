# android-use

A Claude Code skill for controlling Android devices via ADB. Uses Claude as the reasoning engine to read UI state and execute actions.

## Installation

```bash
npx skills add https://github.com/shehbajdhillon/android-use
```

Or just link this repo to your agent and let it figure it out.

## Prerequisites

- **ADB** installed and in your PATH ([Android SDK Platform Tools](https://developer.android.com/tools/releases/platform-tools))
- **Android device** with USB debugging enabled
- Device authorized for debugging (accept the "Allow USB debugging?" prompt)

## Usage

Once installed, invoke the skill with `/android-use`:

```
/android-use open Chrome and search for weather
/android-use take a screenshot
/android-use open Settings and enable dark mode
```

The skill uses a perception-action loop:
1. Dumps the UI accessibility tree
2. Claude reads the XML to understand screen state
3. Decides and executes the next action (tap, swipe, type, etc.)
4. Repeats until the task is complete

## Multi-Device Support

All scripts support targeting specific devices with `-s <serial>`. When multiple devices are connected (e.g., physical phone + emulator), the agent will:

- Identify devices as `[PHYSICAL]` or `[EMULATOR]`
- Match user intent ("my phone" → physical device)
- Ask for clarification if unclear

## Available Scripts

| Script | Description |
|--------|-------------|
| `check-device.sh` | List connected devices / verify connection |
| `wake.sh` | Wake device and dismiss lock screen |
| `get-screen.sh` | Dump UI accessibility tree (XML) |
| `tap.sh` | Tap at x,y coordinates |
| `type-text.sh` | Type text string |
| `swipe.sh` | Swipe in direction (up/down/left/right) |
| `key.sh` | Press key (home/back/enter/recent) |
| `screenshot.sh` | Capture screen image |
| `launch-app.sh` | Launch app by package name or search |
| `install-apk.sh` | Install APK file to device |

## How It Works

Unlike traditional Android automation that requires a separate LLM or parser, this skill leverages Claude's ability to directly read and understand Android's accessibility XML. Claude acts as both the reasoning and execution engine.

Example XML that Claude parses:
```xml
<node text="Settings" bounds="[42,234][1038,345]" clickable="true" />
```

Claude calculates tap coordinates from bounds and decides actions based on the current UI state and user goal.

## License

MIT
