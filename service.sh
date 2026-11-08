#!/system/bin/sh
# Edge Touch Fix: runs once per boot, then exits. No background service.
#
# Motorola's touch HAL widens the Goodix edge-suppression zone in landscape
# and games (edge area 0x40), and in portrait the algorithm delays or drops
# short taps in the lower corners. This writes "zone off, rotation 0x80" once
# and makes the node read-only, so the HAL (user system) cannot change it.
#
# Driver input "zone rotation": zone 0=off 1=0x80 2=0x40 | rotation 0=0x00 1=0x80 3=0x40
# ETF_EDGE and ETF_LOG only exist for testing; Magisk never sets them.

MODDIR=${0%/*}
EDGE=${ETF_EDGE:-/sys/devices/virtual/touchscreen/primary/edge}
LOG=${ETF_LOG:-$MODDIR/status.log}
WANT="0 1"
WANT_READ="0x00 0x80"

exec > "$LOG" 2>&1
echo "Edge Touch Fix $(grep -m1 '^version=' "$MODDIR/module.prop" | cut -d= -f2) - $(date '+%Y-%m-%d %H:%M:%S')"

n=0
until [ "$(getprop sys.boot_completed)" = 1 ]; do
    if [ "$n" -ge 180 ]; then
        echo "NOT APPLIED: boot did not complete within 180 seconds."
        exit 1
    fi
    sleep 1
    n=$((n + 1))
done

# Respect disabling/removing the module while this script was waiting.
if [ -f "$MODDIR/disable" ] || [ -f "$MODDIR/remove" ]; then
    echo "Module disabled or marked for removal; nothing changed."
    exit 0
fi

if [ "$(getprop ro.product.device)" != merc ]; then
    echo "NOT APPLIED: this is not a Motorola Edge 70 Pro (merc)."
    exit 1
fi

if [ ! -e "$EDGE" ]; then
    echo "NOT APPLIED: $EDGE is missing (touch driver changed?)."
    exit 1
fi

before=$(cat "$EDGE" 2>/dev/null)
echo "Before: [$before]"
case "$before" in
    0x[0-9a-f][0-9a-f]\ 0x[0-9a-f][0-9a-f]) ;;
    *)
        echo "NOT APPLIED: unrecognized value; nothing was overwritten."
        exit 1
        ;;
esac

chmod 0660 "$EDGE"
if ! echo "$WANT" > "$EDGE"; then
    echo "FAILED: the driver rejected the write; node left writable for Motorola."
    exit 1
fi

after=$(cat "$EDGE" 2>/dev/null)
if [ "$after" != "$WANT_READ" ]; then
    echo "FAILED: read back [$after] instead of [$WANT_READ]; node left writable for Motorola."
    exit 1
fi

chmod 0444 "$EDGE"
echo "Applied: [$after], locked read-only (0444)."
