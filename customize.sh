#!/system/bin/sh
# Install-time checks. Refuses to install anywhere this fix was not verified.

[ "$BOOTMODE" = true ] || abort "! Install through the Magisk app."

EDGE=/sys/devices/virtual/touchscreen/primary/edge
DEVICE=$(getprop ro.product.device)

[ "$DEVICE" = merc ] || abort "! Only for the Motorola Edge 70 Pro (merc). This device: $DEVICE"
[ -e "$EDGE" ] || abort "! Touch driver node missing: $EDGE"
grep -qi goodix /sys/class/touchscreen/primary/vendor 2>/dev/null || abort "! Not a Goodix touchscreen."

CURRENT=$(cat "$EDGE" 2>/dev/null)
case "$CURRENT" in
    0x[0-9a-f][0-9a-f]\ 0x[0-9a-f][0-9a-f]) ;;
    *) abort "! Unrecognized edge value [$CURRENT]; refusing to install." ;;
esac

ui_print "- Current edge value: [$CURRENT]"
ui_print "- After reboot: [0x00 0x80], locked read-only"
ui_print "- Trade-off: no edge/palm protection at the screen edges"
ui_print "- Disable or remove in Magisk and reboot to undo"

set_perm "$MODPATH/service.sh" 0 0 0755
set_perm "$MODPATH/action.sh" 0 0 0755
