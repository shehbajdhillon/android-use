---
name: android-use
description: Control Android devices via ADB commands - tap, swipe, type, navigate apps
compatibility: darwin, linux
---

# Android Device Control Skill

This skill enables you to control Android devices connected via ADB (Android Debug Bridge). You act as both the reasoning and execution engine - reading the device's UI state directly and deciding what actions to take.

## Prerequisites

- Android device connected via USB with USB debugging enabled
- ADB installed and accessible in PATH
- Device authorized for debugging (accepted the "Allow USB debugging?" prompt)

## Core Workflow

When given a task, follow this perception-action loop:

1. **Check device connection** - Run `scripts/check-device.sh` first
2. **Get current screen state** - Run `scripts/get-screen.sh` to dump UI hierarchy
3. **Analyze the XML** - Read the accessibility tree to understand what's on screen
4. **Decide next action** - Based on goal + current state, choose an action
5. **Execute action** - Run the appropriate script
6. **Wait briefly** - Allow UI to update (typically 500ms-1s)
7. **Repeat** - Go back to step 2 until goal is achieved

## Reading UI XML

The `get-screen.sh` script outputs Android's accessibility XML. Key attributes to look for:

```xml
<node index="0" text="Settings" resource-id="com.android.settings:id/title"
      class="android.widget.TextView" content-desc=""
      bounds="[42,234][1038,345]" clickable="true" />
```

**Important attributes:**
- `text` - Visible text on the element
- `content-desc` - Accessibility description (useful for icons)
- `resource-id` - Unique identifier for the element
- `bounds` - Screen coordinates as `[left,top][right,bottom]`
- `clickable` - Whether element responds to taps
- `scrollable` - Whether element can be scrolled
- `focused` - Whether element has input focus

**Calculating tap coordinates:**
From `bounds="[left,top][right,bottom]"`, calculate center:
- x = (left + right) / 2
- y = (top + bottom) / 2

Example: `bounds="[42,234][1038,345]"` → tap at x=540, y=289

## Available Scripts

All scripts are in the `scripts/` directory. Run them via bash:

### Device Management
| Script | Args | Description |
|--------|------|-------------|
| `check-device.sh` | none | Verify ADB connection |
| `screenshot.sh` | none | Capture screen image |

### Screen Reading
| Script | Args | Description |
|--------|------|-------------|
| `get-screen.sh` | none | Dump UI accessibility tree |

### Input Actions
| Script | Args | Description |
|--------|------|-------------|
| `tap.sh` | `x y` | Tap at coordinates |
| `type-text.sh` | `"text"` | Type text string |
| `swipe.sh` | `direction` | Swipe up/down/left/right |
| `key.sh` | `keyname` | Press key (home/back/enter/recent) |

### App Management
| Script | Args | Description |
|--------|------|-------------|
| `launch-app.sh` | `package_or_name` | Launch app by package or search by name |
| `install-apk.sh` | `path/to/file.apk` | Install APK to device |

## Action Guidelines

### When to tap
- Target clickable elements
- Always calculate center from bounds
- Prefer elements with `clickable="true"`

### When to type
- After tapping a text input field
- The field should have `focused="true"` or `class="android.widget.EditText"`
- Clear existing text first if needed (select all + delete)

### When to swipe
- To scroll lists or pages
- To navigate between screens (e.g., swipe left/right for tabs)
- Directions: `up` (scroll down), `down` (scroll up), `left`, `right`

### When to use keys
- `home` - Return to home screen
- `back` - Go back / close dialogs
- `enter` - Submit forms / confirm
- `recent` - Open recent apps

### When to take screenshots
- For visual debugging when XML doesn't capture enough info
- To verify visual state (colors, images, etc.)
- When the task requires visual confirmation

## Common Patterns

### Opening an app
```bash
# By package name (fastest)
scripts/launch-app.sh com.android.chrome

# By app name (searches installed apps)
scripts/launch-app.sh "Chrome"
```

### Tapping a button
1. Get screen: `scripts/get-screen.sh`
2. Find element with matching text/content-desc
3. Calculate center from bounds
4. Tap: `scripts/tap.sh 540 289`

### Entering text in a field
1. Tap the text field to focus it
2. Wait for keyboard
3. Type: `scripts/type-text.sh "your text here"`
4. Press enter if needed: `scripts/key.sh enter`

### Scrolling to find content
1. Get screen to check if target is visible
2. If not found, swipe: `scripts/swipe.sh up`
3. Get screen again, repeat until found or reached end

### Handling dialogs/popups
- Look for elements with text like "OK", "Allow", "Accept", "Cancel"
- Tap the appropriate button
- Or press back to dismiss: `scripts/key.sh back`

## Error Handling

### No device connected
- Check USB connection
- Verify USB debugging is enabled
- Run `adb devices` manually to troubleshoot

### Element not found
- The UI may have changed - get fresh screen dump
- Try scrolling to find the element
- Element might be in a different screen/state

### Action didn't work
- Wait longer between actions (UI might be slow)
- Verify coordinates are correct
- Check if a popup/dialog appeared

### App not responding
- Press home and reopen the app
- Or force close and restart

## Example Session

**User request:** "Open Chrome and search for weather"

```
1. scripts/check-device.sh
   → Device connected: Pixel 6a

2. scripts/launch-app.sh com.android.chrome
   → Chrome launched

3. scripts/get-screen.sh
   → [Read XML, find search/URL bar]
   → Found: bounds="[0,141][1080,228]" resource-id="com.android.chrome:id/url_bar"
   → Center: x=540, y=184

4. scripts/tap.sh 540 184
   → Tapped URL bar

5. scripts/get-screen.sh
   → [Verify keyboard appeared and field is focused]

6. scripts/type-text.sh "weather"
   → Typed "weather"

7. scripts/key.sh enter
   → Pressed enter to search

8. scripts/get-screen.sh
   → [Verify search results loaded]
   → Task complete!
```

## Tips

- **Be patient** - Android UI can be slow, wait between actions
- **Read carefully** - The XML tells you exactly what's on screen
- **Check your work** - Get screen after each action to verify state
- **Use screenshots** - When XML doesn't give enough context
- **Start simple** - Break complex tasks into small steps
