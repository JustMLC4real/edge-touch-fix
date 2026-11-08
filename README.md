# Edge Touch Fix

Makes short taps in the corners and along the edges register immediately on the **Motorola Edge 70 Pro (XT2607-1, `merc`)**. Requires Magisk.

[Nederlands](#nederlands)

## What it fixes

Motorola's touch HAL widens the Goodix edge-suppression zone in landscape and in games, and in portrait the touch algorithm holds back short taps in the lower corners. Game buttons in those spots need a long press before they react.

Once per boot, the module sets the driver's edge node to **zone off, rotation `0x80`** and makes it read-only so Motorola cannot change it back. Nothing keeps running afterwards.

## Measurements on the reference phone

Android 17 `A171WMH.44-25`, Goodix GT9916P. Rotation values were alternated during the same session.

| Edge value | Lower-corner taps that arrived | Average time to arrive in the lower corners |
|---|---|---|
| `0x00 0x80` (this module) | 100 % | ~470 ms |
| `0x00 0x00` (Motorola portrait default) | 100 % | ~650 ms |

In a Mario Kart DS session, about 40 % fewer steering presses came through with Motorola's portrait default than with this module. Times include the tester's reaction time, so compare rows rather than absolute values.

## Install

1. Download the ZIP from the releases.
2. **Magisk → Modules → Install from storage**.
3. Reboot.

The installer refuses other devices, a missing touch node and unrecognized values.

Use **Action** in Magisk to view the boot status and the current value. To undo, disable or remove the module in Magisk and reboot.

## Trade-off

Edge and palm protection at the screen edges is off. A hand resting on the edge can register as a touch. Gametime's own palm rejection (large contact areas) is not affected.

## Limits

- Verified only on the Edge 70 Pro with Android 17. Other Motorola models use different touch drivers, where the same values may mean something else.
- A future OTA can change the driver. The module then does nothing and reports why under **Action**.

---

## Nederlands

Zorgt dat korte tikken in de hoeken en langs de randen meteen werken op de **Motorola Edge 70 Pro (XT2607-1, `merc`)**. Magisk is vereist.

**Wat het oplost:** Motorola zet in liggende stand en in games een brede randonderdrukking aan, en staand houdt het touch-algoritme korte tikken in de onderste hoeken tegen. Gameknoppen op die plekken reageren dan pas na lang drukken.

**Wat het doet:** bij het opstarten zet de module de randzone van de touchdriver één keer **uit, met rotatie `0x80`**, en zet die instelling op slot zodat Motorola hem niet terugzet. Daarna draait er niets meer.

**Installeren:** zip downloaden → **Magisk → Modules → Installeren vanuit opslag** → herstarten. Met **Action** in Magisk zie je de status. Ongedaan maken: module uitzetten of verwijderen in Magisk en herstarten.

**Keerzijde:** geen bescherming meer tegen per ongeluk aanraken met je hand aan de rand. De palmafwijzing van Gametime blijft werken.

**Grenzen:** alleen getest op de Edge 70 Pro met Android 17. Andere Motorola's hebben een andere touchdriver. Verandert een update de driver, dan doet de module niets en meldt hij dat onder **Action**.
