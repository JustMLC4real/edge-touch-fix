# Edge Touch Fix

Magisk module for the **Motorola Edge 70 Pro (XT2607-1, `merc`)** that makes short taps in the corners and along the screen edges register immediately.

## What it does

Motorola's touch software ignores or delays short taps near the screen edges and in the lower corners, to filter out palm touches. In landscape and in games it widens that zone further, so on-screen buttons near the edges often need a long press.

Once per boot, the module turns this edge suppression off in the Goodix touch driver and locks the setting, so Motorola cannot switch it back on. It then exits; nothing keeps running in the background.

## Install

1. Download the ZIP from [Releases](https://github.com/JustMLC4real/edge-touch-fix/releases/latest).
2. **Magisk → Modules → Install from storage**.
3. Reboot.

Tap **Action** on the module in Magisk to see whether it was applied.

## Uninstall

Disable or remove the module in Magisk and reboot. Motorola's default behaviour returns.

## Good to know

- Edge palm protection is off, so a hand resting on the screen edge can register as a touch.
- Only tested on the Edge 70 Pro with Android 17. The installer refuses other devices.
- If a future update changes the touch driver, the module does nothing and shows why under **Action**.
