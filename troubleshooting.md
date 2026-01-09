# Bigme Hibreak Pro - Troubleshooting Guide

## Boot Loop / Bricked Device

✅ **Successfully recovered from boot loop on 2026-01-09** using Factory Reset via Recovery Mode.

If your device gets stuck in a boot loop (infinite loading animation), follow these steps.

### Step 1: Check ADB Connection

While the device is in the boot loop, connect via USB and check if ADB can see it:

```bash
adb devices
```

If it shows your device, proceed to Step 2. If not, try Step 3.

### Step 2: Reboot to Recovery via ADB

```bash
adb reboot recovery
```

This should bring up the recovery menu. Skip to Step 4.

### Step 3: Manual Recovery Mode (if ADB doesn't work)

1. **Power off completely** (hold power 15+ seconds if needed)
2. **Let battery drain** if it won't turn off
3. Once off, hold **Power + Volume UP** together
4. Keep holding until you see the recovery menu

### Step 4: Recovery Menu Options

You should see this menu:
```
Reboot system now
Reboot to bootloader
Enter fastboot
Apply update from ADB
Apply update from SD card
Apply update from OTG
Wipe data/factory reset
A/B OTA reset
Mount /system
View recovery logs
Run graphics test
Run locale test
Power off
```

### Step 5: Try These in Order

#### Option A: Simple Reboot (rarely works but try first)
- Select "Reboot system now"
- If it boot loops again, go back to recovery

#### Option B: Wipe Data/Factory Reset ⚠️ ERASES ALL DATA (THIS WORKED ✅)
- Select "Wipe data/factory reset"
- Confirm YES when prompted
- Wait for completion
- Optionally also run "A/B OTA reset" (resets partition slots)
- Select "Reboot system now"

**This will erase all apps, accounts, and data. You'll need to set up the phone again.**

**Note:** May need to run factory reset multiple times if first attempt doesn't work.

### Step 6: Fastboot Mode (Advanced)

If recovery doesn't work:

1. In recovery, select "Enter fastboot"
2. On your Mac, run:
```bash
fastboot devices
```

3. If device is locked (most are), you cannot erase partitions:
```bash
fastboot erase cache  # Will fail if locked
```

4. Return to recovery:
```bash
fastboot reboot recovery
```

---

## Known Issues That Can Cause Boot Loops

### 1. Custom Font Installation ⚠️ HIGH RISK
**DO NOT change the system font** via Settings → Display → Font set.

Custom fonts placed in `/sdcard/Fonts/` can cause boot loops if:
- The font file is corrupted
- The font format is incompatible
- The system font cache becomes corrupted

**If you must use custom fonts:**
- Test on a secondary device first
- Keep a backup of your data
- Be prepared to factory reset

### 2. Aggressive System Settings Changes
Some `adb shell settings put` commands can destabilize the system:
- Avoid modifying system fonts via ADB
- Avoid disabling core Google services
- Test changes one at a time

### 3. Disabling Critical System Apps
Never disable these packages:
- `com.android.systemui` (System UI)
- `com.android.settings` (Settings)
- `com.google.android.gms` (Play Services - needed for many apps)
- `com.android.providers.*` (System providers)

---

## Recovery After Factory Reset

After a factory reset, run the setup script again:

```bash
cd /path/to/bigme-dumbphone
./setup.sh
```

**Skip the font installation step (Step 13)** to avoid another boot loop.

---

## Useful ADB Commands for Diagnostics

```bash
# Check device connection
adb devices

# Get device info
adb shell getprop ro.product.model
adb shell getprop ro.build.version.release

# Check boot status
adb shell getprop sys.boot_completed

# View system logs (if device is partially booted)
adb logcat -b main -d | grep -i "font\|boot\|crash"

# List installed packages
adb shell pm list packages

# Check storage
adb shell df -h
```

---

## Contact Bigme Support

If nothing works:
- Website: https://bigmestore.com/
- Look for firmware download for Hibreak Pro
- MediaTek SP Flash Tool may be needed for complete reflash

---

## Prevention Tips

1. **Always backup** before making system changes
2. **Test changes incrementally** - don't make multiple changes at once
3. **Avoid font customization** - it's not worth the risk
4. **Keep ADB accessible** - don't disable USB debugging
5. **Document what you change** - makes troubleshooting easier

