# Edge Touch Fix

Magisk module for the **Motorola Edge 70 Pro (XT2607-1, `merc`)** that makes short taps in the corners and along the screen edges register immediately.

## What it does

Motorola's touch software ignores or delays short taps near the screen edges and in the lower corners, to filter out palm touches. In landscape and in games it widens that zone further, so on-screen buttons near the edges often need a long press.

Once per boot, the module turns this edge suppression off in the Goodix touch driver and locks the setting, so Motorola cannot switch it back on. It then exits; nothing keeps running in the background.

## Install

1. Download the ZIP from [Releases](https://github.com/JustMLC4real/edge-touch-fix/releases/latest).
2. **Magisk → Modules → Install from storage**.
3. Reboot.

Tap **Action** on the module in Magisk to see whether it was applied. New releases show up as an update in Magisk (from 2.2.1 on).

## Uninstall

Disable or remove the module in Magisk and reboot. Motorola's default behaviour returns.

## Good to know

- Edge suppression is off, so a hand resting on the screen edge may register as a touch. The module does not change palm rejection; in Moto Gametime that is a separate setting you can switch yourself.
- Only tested on the Edge 70 Pro with Android 17. The installer refuses other devices.
- If a future update changes the touch driver, the module does nothing and shows why under **Action**.

## How it works

### Touch stack

The Edge 70 Pro uses a Goodix GT9916P touch controller with Touch Host Processing (THP). The controller only streams raw frames to the kernel driver (`goodix_brl_thp.ko`). A userspace daemon, `odm_tsc` with Goodix's algorithm library (`libgdix_tsa_merc_csot.so`), decides what counts as a finger, a palm or a grip, and injects the resulting touches through the `gdix_input_agent` input device. Edge and corner filtering therefore happens in that algorithm, not in the hardware.

### The edge node

The driver exposes the edge configuration at `/sys/class/touchscreen/primary/edge` (`/sys/devices/virtual/touchscreen/primary/edge`). It takes `"<zone> <rotation>"` and reads back as two hex bytes:

| Input | Zone | | Input | Rotation |
|---|---|---|---|---|
| `0` | `0x00` (off) | | `0` | `0x00` |
| `1` | `0x80` | | `1` | `0x80` |
| `2` | `0x40` | | `3` | `0x40` |

Rotation `2` is rejected by the driver. Each write is confirmed in the Goodix log, for example `set edge = 00, rotation = 80`.

Motorola's touch HAL (`com.motorola.hardware.display.touch-service`, running as `system`) rewrites this node whenever the orientation or foreground app changes. After boot it holds `0x08 0x00`; in landscape games it switches to `0x40 0x40`, a wide suppression zone.

### Why rotation `0x80`

Turning the zone off is not enough on its own. The algorithm still treats the corners on the side it considers "bottom" for the reported rotation as grip area and briefly holds short taps there. With rotation `0x00` (portrait), taps in the lower corners arrived about 150–200 ms later than in the upper corners. With `0x80`, all four corners responded equally in portrait and in both landscape orientations during testing.

### Locking instead of polling

The node is `system:system 0660`. After writing, the module sets it to `0444`. The HAL runs as `system` without root, so its later writes fail and the value stays put. Root ignores file permissions, which is how the module itself can still write. Nothing runs in the background and the HAL keeps working normally.

Permissions on sysfs nodes reset at every boot, so disabling or removing the module and rebooting restores Motorola's behaviour completely.

### Boot sequence

`service.sh` waits for `sys.boot_completed` (at most 180 seconds), then checks the device (`merc`), the node and the value format. It writes `0 1`, reads the value back and only locks the node if it reads `0x00 0x80`. Any mismatch leaves the node writable for Motorola. The result goes to `status.log`, which the **Action** button shows.
