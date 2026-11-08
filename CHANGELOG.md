# Changelog

## 2.2.1

- Update notifications in Magisk through `updateJson`. Install this version once by hand; later releases show up in Magisk.
- Status log shows the installed version.

## 2.2

- Status log per boot and a Magisk **Action** button that shows it with the current value.
- Install-time checks: Edge 70 Pro (`merc`), Goodix touchscreen, edge node present, recognized value.
- Boot-time checks: device, node present, recognized value, read-back after writing. On any mismatch the node stays writable for Motorola.
- Respects disabling or removing the module during boot.
- Boot wait bounded to 180 seconds.

## 2.1

- Rotation `0x80` instead of `0x00`: lower corners no longer delayed in portrait (measured).

## 2.0

- One-shot at boot with a read-only lock instead of polling every 2 seconds.

## 1.0

- First version: polled every 2 seconds and reset the edge zone.
