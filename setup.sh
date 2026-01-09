#!/bin/bash

# Bigme Dumb Phone Setup Script
# One-shot script to configure a Bigme Hibreak Pro as a minimal phone

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LAUNCHER_APK="$SCRIPT_DIR/launcher.apk"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║          BIGME DUMB PHONE SETUP                           ║"
echo "║          Transform your phone in one shot                 ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# ============================================================
# Step 1: Check ADB and device connection
# ============================================================

echo -e "${YELLOW}[1/7] Checking device connection...${NC}"

if ! command -v adb &> /dev/null; then
    echo -e "${RED}Error: ADB not found. Please install Android SDK Platform Tools.${NC}"
    exit 1
fi

# Start ADB server
adb start-server > /dev/null 2>&1

# Check for device
DEVICE=$(adb devices | grep -v "List" | grep -v "^$" | head -n1 | awk '{print $1}')
if [ -z "$DEVICE" ]; then
    echo -e "${RED}No device found!${NC}"
    echo ""
    echo "Please ensure:"
    echo "  1. USB debugging is enabled on your Bigme"
    echo "  2. Device is connected via USB"
    echo "  3. You've accepted the USB debugging prompt"
    echo ""
    exit 1
fi

echo -e "${GREEN}✓ Device connected: $DEVICE${NC}"

# ============================================================
# Step 2: Pre-setup (Play Store sign-in & NFC)
# ============================================================

echo ""
echo -e "${YELLOW}[2/7] Pre-setup configuration...${NC}"

# Open Play Store for sign-in
echo -e "${CYAN}Opening Play Store - please sign into your Google account${NC}"
adb shell am start -n com.android.vending/com.google.android.finsky.activities.MainActivity > /dev/null 2>&1
echo ""
echo "Press Enter after signing into Play Store..."
read -r

# Open NFC settings
echo -e "${CYAN}Opening NFC settings - please enable 'Use NFC'${NC}"
adb shell am start -a android.settings.NFC_SETTINGS > /dev/null 2>&1
echo ""
echo "Press Enter after enabling NFC..."
read -r

echo -e "${GREEN}✓ Pre-setup complete${NC}"

# ============================================================
# Step 3: Open Play Store for app installation
# ============================================================

echo ""
echo -e "${YELLOW}[3/7] Opening Play Store for each app...${NC}"
echo -e "${CYAN}Please install each app when the Play Store opens.${NC}"
echo ""

# Apps that need to be installed (not stock)
declare -a APPS=(
    "com.whatsapp|Semi-encrypted Chat (WhatsApp)"
    "org.thoughtcrime.securesms|Encrypted Chat (Signal)"
    "com.google.android.apps.walletnfcrel|Wallet (Google Wallet)"
    "com.thewizrd.simpleweather|Weather (SimpleWeather)"
    "com.readdle.spark|Email (Spark)"
    "com.adobe.scan.android|Doc Scanner (Adobe Scan)"
    "com.aisense.otter|AI Note Taker (Otter.ai)"
    "com.openai.chatgpt|AI Chat (ChatGPT)"
    "com.td|TD Bank (TD Canada)"
    "com.scotiabank.banking|Scotiabank"
    "com.tplink.kasa_android|Smart Devices (Kasa)"
    "com.ecobee.athenamobile|Thermostat (Ecobee)"
    "com.openphone|Quo"
    "org.fossify.gallery|Photos (Fossify Gallery)"
)

for app in "${APPS[@]}"; do
    PACKAGE=$(echo "$app" | cut -d'|' -f1)
    NAME=$(echo "$app" | cut -d'|' -f2)
    
    # Check if already installed
    if adb shell pm list packages | grep -q "package:$PACKAGE"; then
        echo -e "${GREEN}✓ $NAME already installed${NC}"
    else
        echo -e "${YELLOW}→ Opening Play Store for: $NAME${NC}"
        adb shell am start -a android.intent.action.VIEW -d "market://details?id=$PACKAGE" > /dev/null 2>&1
        
        echo -e "${CYAN}  Press Enter after installing $NAME...${NC}"
        read -r
    fi
done

echo -e "${GREEN}✓ All apps ready${NC}"

# ============================================================
# Step 3: Install custom launcher
# ============================================================

echo ""
echo -e "${YELLOW}[4/7] Installing custom launcher...${NC}"

if [ ! -f "$LAUNCHER_APK" ]; then
    echo -e "${RED}Error: launcher.apk not found at $LAUNCHER_APK${NC}"
    echo "Please build the launcher first: cd bigme-launcher && ./gradlew assembleDebug"
    exit 1
fi

adb install -r "$LAUNCHER_APK" > /dev/null 2>&1
echo -e "${GREEN}✓ Dumb Phone launcher installed${NC}"

# ============================================================
# Step 4: Set launcher as default home
# ============================================================

echo ""
echo -e "${YELLOW}[5/7] Setting launcher as default home...${NC}"

# Clear any existing home app preference
adb shell pm clear com.android.settings > /dev/null 2>&1 || true

# Open home settings so user can select the new launcher
adb shell am start -a android.settings.HOME_SETTINGS > /dev/null 2>&1

echo -e "${CYAN}The Home app settings should now be open on your phone.${NC}"
echo -e "${CYAN}Please select 'Dumb Phone' from the list.${NC}"
echo ""
echo "Press Enter after selecting 'Dumb Phone' as your home app..."
read -r

echo -e "${GREEN}✓ Launcher configured${NC}"

# ============================================================
# Step 5: Disable stock launcher and configure system
# ============================================================

echo ""
echo -e "${YELLOW}[6/7] Configuring system settings...${NC}"

# Common stock launcher package names to try
STOCK_LAUNCHERS=(
    "com.android.launcher3"
    "com.google.android.apps.nexuslauncher"
    "com.sec.android.app.launcher"
    "com.huawei.android.launcher"
    "com.oppo.launcher"
    "com.miui.home"
)

DISABLED=0
for launcher in "${STOCK_LAUNCHERS[@]}"; do
    if adb shell pm list packages | grep -q "package:$launcher"; then
        echo -e "${YELLOW}  Disabling $launcher...${NC}"
        adb shell pm disable-user --user 0 "$launcher" > /dev/null 2>&1 || true
        DISABLED=1
    fi
done

if [ $DISABLED -eq 1 ]; then
    echo -e "${GREEN}✓ Stock launcher disabled${NC}"
else
    echo -e "${YELLOW}  No known stock launcher found to disable${NC}"
fi

# Disable Bigme standby screen (shows logo instead of lock screen)
echo -e "${YELLOW}Disabling Bigme standby screen...${NC}"
adb shell pm disable-user --user 0 com.xrz.standby > /dev/null 2>&1 && \
    echo -e "${GREEN}✓ Standby screen disabled${NC}" || \
    echo -e "${YELLOW}  Standby app not found (may not be needed)${NC}"

# Disable lock screen notifications for cleaner look
echo -e "${YELLOW}Configuring lock screen settings...${NC}"
adb shell settings put secure lock_screen_show_notifications 0 > /dev/null 2>&1
adb shell settings put secure lock_screen_allow_private_notifications 0 > /dev/null 2>&1
adb shell settings put secure lock_screen_show_silent_notifications 0 > /dev/null 2>&1
adb shell settings put global heads_up_notifications_enabled 0 > /dev/null 2>&1
echo -e "${GREEN}✓ Lock screen notifications disabled${NC}"

# ============================================================
# Step 6: Generate installed apps list
# ============================================================

echo ""
echo -e "${YELLOW}[7/7] Generating installed apps list...${NC}"

APP_LIST_FILE="$SCRIPT_DIR/installed-apps-$(date +%Y%m%d-%H%M%S).txt"

{
    echo "# All Installed Apps on Bigme Hibreak Pro"
    echo "# Generated: $(date)"
    echo "# Device: $DEVICE"
    echo ""
    echo "## All Packages ($(adb shell pm list packages | wc -l | tr -d ' ') total)"
    echo ""
    adb shell pm list packages | sed 's/package://' | sort
} > "$APP_LIST_FILE"

echo -e "${GREEN}✓ App list saved to: $APP_LIST_FILE${NC}"

# ============================================================
# Done!
# ============================================================

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                    SETUP COMPLETE!                        ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Your Bigme is now a dumb phone with only your 20 apps."
echo ""
echo "Next steps:"
echo "  1. Sign into each app as needed"
echo "  2. Set up Google Wallet for tap-to-pay"
echo ""
echo -e "${CYAN}Full app list saved to:${NC}"
echo "  $APP_LIST_FILE"
echo ""
echo -e "${CYAN}To restore stock launcher later:${NC}"
echo "  adb shell pm enable com.android.launcher3"
echo ""

