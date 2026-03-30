# MacSlaps

A macOS menu bar app that detects when you slap your laptop and plays a sound. That's it.

Made for Mac users.

---

## What it does

MacSlaps listens to your microphone and detects sudden loud impacts — like slapping the side of your laptop. When it hears one, it plays a random audio response. Lives in your menu bar and stays out of your way.

- Menu bar icon shows when it's active
- Adjustable sensitivity slider
- Enable/disable toggle without quitting
- Rotates between 3 sounds so it doesn't get repetitive
- 0.6-second cooldown to prevent double-triggers

## Requirements

- macOS 13.0 (Ventura) or later
- Xcode 15+ (to build from source)
- Microphone access

## Build & Run

1. Open the project in Xcode:
   ```bash
   open SlapMac.xcodeproj
   ```

2. Press **Cmd+R** to build and run.

3. On first launch, grant microphone permission when prompted.

4. The app appears as an icon in your menu bar — no dock icon.

To build a release binary:
```bash
xcodebuild -scheme SlapMac -configuration Release build
```
The compiled app will be at `Build/Products/Release/SlapMac.app`.

## Launch at Login

To have MacSlaps start automatically when you log in:

1. Open **System Settings** → **General** → **Login Items**
2. Click the **+** button under "Open at Login"
3. Navigate to `SlapMac.app` and select it

After that, SlapMac will start silently in your menu bar every time you log in.

## Sensitivity

Use the slider in the menu bar to tune detection:

- **Higher** = more sensitive (picks up lighter taps)
- **Lower** = less sensitive (only hard slaps trigger it)

The default is tuned for a moderate slap on the side of the laptop body.
