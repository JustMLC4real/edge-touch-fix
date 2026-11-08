#!/system/bin/sh
# Magisk "Action" button: shows the boot status and the current value. Changes nothing.

MODDIR=${0%/*}
EDGE=/sys/devices/virtual/touchscreen/primary/edge

echo "== Edge Touch Fix =="
if [ -f "$MODDIR/status.log" ]; then
    cat "$MODDIR/status.log"
else
    echo "No status log yet: reboot after installing."
fi
echo
echo "Current value: [$(cat "$EDGE" 2>/dev/null)]  permissions: $(stat -c %a "$EDGE" 2>/dev/null)"
echo "Expected:      [0x00 0x80]  permissions: 444"
