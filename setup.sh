#!/bin/bash

# Bigme Dumb Phone Setup Script
# One-shot script to configure a Bigme Hibreak Pro as a minimal phone
#
# Usage:
#   ./setup.sh          Full setup with all interactive steps
#   ./setup.sh --quick  Quick install: just update launcher and launch

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LAUNCHER_APK="$SCRIPT_DIR/launcher.apk"
QUICK_MODE=false

# Parse arguments
if [ "$1" = "--quick" ] || [ "$1" = "-q" ]; then
    QUICK_MODE=true
fi

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "╔═══════════════════════════════════════════════════════════╗"
if [ "$QUICK_MODE" = true ]; then
echo "║          BIGME DUMB PHONE - QUICK INSTALL                 ║"
else
echo "║          BIGME DUMB PHONE SETUP                           ║"
fi
echo "║          Transform your phone in one shot                 ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# ============================================================
# Step 1: Check ADB and device connection
# ============================================================

echo -e "${YELLOW}[1/14] Checking device connection...${NC}"

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
# Quick Mode: Just install and launch
# ============================================================

if [ "$QUICK_MODE" = true ]; then
    echo ""
    echo -e "${YELLOW}Quick mode: Installing launcher...${NC}"
    
    if [ ! -f "$LAUNCHER_APK" ]; then
        echo -e "${RED}Error: launcher.apk not found at $LAUNCHER_APK${NC}"
        exit 1
    fi
    
    adb install -r "$LAUNCHER_APK" > /dev/null 2>&1
    echo -e "${GREEN}✓ Launcher installed${NC}"
    
    echo -e "${YELLOW}Launching Dumb Phone...${NC}"
    adb shell am start -n com.bigme.dumbphone/.MainActivity > /dev/null 2>&1
    echo -e "${GREEN}✓ Dumb Phone launched${NC}"
    
    echo ""
    echo -e "${GREEN}Done! Your Dumb Phone is ready.${NC}"
    exit 0
fi

# ============================================================
# Step 2: Check for system updates
# ============================================================

echo ""
echo -e "${YELLOW}[2/14] Checking for system updates...${NC}"
echo -e "${CYAN}We'll check three different update sources.${NC}"
echo ""

# 1. Open Android system update settings
echo -e "${CYAN}[1/3] Opening Android System Update settings...${NC}"
echo -e "${CYAN}Please check for and install any available Android OS updates.${NC}"
adb shell am start -a android.settings.SYSTEM_UPDATE_SETTINGS > /dev/null 2>&1
echo ""
echo "Press Enter after checking for Android updates..."
read -r

# 2. Open Google Play system update (under Security & Privacy)
echo -e "${CYAN}[2/3] Opening Google Play System Update settings...${NC}"
echo -e "${CYAN}Go to: Security & privacy > System & updates${NC}"
echo -e "${CYAN}Please check for and install any Google Play system updates.${NC}"
adb shell am start -a android.settings.SECURITY_SETTINGS > /dev/null 2>&1
echo ""
echo "Press Enter after checking for Google Play system updates..."
read -r

# 3. Open BigMe System Update settings
echo -e "${CYAN}[3/3] Opening BigMe System Update settings...${NC}"
echo -e "${CYAN}Please check for and install any BigMe OS updates.${NC}"
adb shell am start -n com.android.settings/com.xrz.settings.ui.SysUpdateActivity > /dev/null 2>&1
echo ""
echo "Press Enter after checking for BigMe firmware updates..."
read -r

echo -e "${GREEN}✓ All system updates checked${NC}"

# ============================================================
# Step 3: Pre-setup (Play Store sign-in & NFC)
# ============================================================

echo ""
echo -e "${YELLOW}[3/14] Pre-setup configuration...${NC}"

# Open Play Store for sign-in
echo -e "${CYAN}Opening Play Store - please sign into your Google account${NC}"
adb shell am start -n com.android.vending/com.google.android.finsky.activities.MainActivity > /dev/null 2>&1
echo ""
echo -e "${RED}⚠️  IMPORTANT: When prompted about backup:${NC}"
echo -e "${RED}   Select 'Don't back up' or disable backup!${NC}"
echo ""
echo -e "${YELLOW}   Why: Google Backup uploads your app data, Wi-Fi passwords,${NC}"
echo -e "${YELLOW}   call history, device settings, and SMS to Google servers.${NC}"
echo -e "${YELLOW}   This data can be accessed by Google, governments, and data purchasers.${NC}"
echo ""
echo "Press Enter after signing in (with backup DISABLED)..."
read -r

# Open NFC settings
echo -e "${CYAN}Opening NFC settings - please enable 'Use NFC'${NC}"
adb shell am start -a android.settings.NFC_SETTINGS > /dev/null 2>&1
echo ""
echo "Press Enter after enabling NFC..."
read -r

echo -e "${GREEN}✓ Pre-setup complete${NC}"

# ============================================================
# Step 4: Open Play Store for app installation
# ============================================================

echo ""
echo -e "${YELLOW}[4/14] Opening Play Store for each app...${NC}"
echo -e "${CYAN}Please install each app when the Play Store opens.${NC}"
echo ""

# Apps that need to be installed (not stock)
declare -a APPS=(
    "com.whatsapp|Semi-encrypted Chat (WhatsApp)"
    "org.thoughtcrime.securesms|Encrypted Chat (Signal)"
    "com.google.android.apps.walletnfcrel|Wallet (Google Wallet)"
    "com.thewizrd.simpleweather|Weather (SimpleWeather)"
    "com.aisense.otter|AI Note Taker (Otter.ai)"
    "com.openai.chatgpt|AI Chat (ChatGPT)"
    "com.td|TD Bank (TD Canada)"
    "com.scotiabank.banking|Scotiabank"
    "com.tplink.kasa_android|Smart Devices (Kasa)"
    "com.ecobee.athenamobile|Thermostat (Ecobee)"
    "com.openphone|Quo"
    "org.fossify.gallery|Photos (Fossify Gallery)"
    "app.organicmaps|Encrypted Maps (Organic Maps)"
)

for app in "${APPS[@]}"; do
    PACKAGE=$(echo "$app" | cut -d'|' -f1)
    NAME=$(echo "$app" | cut -d'|' -f2)
    
    # Check if already installed
    if adb shell pm list packages | grep -q "^package:$PACKAGE$"; then
        echo -e "${GREEN}✓ $NAME already installed${NC}"
    else
        echo -e "${YELLOW}→ Opening Play Store for: $NAME${NC}"
        adb shell am start -a android.intent.action.VIEW -d "market://details?id=$PACKAGE" > /dev/null 2>&1
        
        echo -e "${CYAN}  Press Enter after installing $NAME...${NC}"
        read -r
    fi
done

echo -e "${GREEN}✓ Play Store apps ready${NC}"

# ============================================================
# Step 5: Install F-Droid and privacy apps
# ============================================================

echo ""
echo -e "${YELLOW}[5/14] Installing F-Droid and privacy apps...${NC}"

# Download and install F-Droid
echo -e "${CYAN}Downloading F-Droid...${NC}"
FDROID_APK="/tmp/fdroid.apk"

if ! adb shell pm list packages | grep -q "^package:org.fdroid.fdroid$"; then
    curl -L -o "$FDROID_APK" "https://f-droid.org/F-Droid.apk" 2>/dev/null
    adb install "$FDROID_APK" > /dev/null 2>&1
    echo -e "${GREEN}✓ F-Droid installed${NC}"
    
    # Wait for F-Droid to fully register
    sleep 2
else
    echo -e "${GREEN}✓ F-Droid already installed${NC}"
fi

# Verify F-Droid is actually installed before proceeding
if ! adb shell pm list packages | grep -q "^package:org.fdroid.fdroid$"; then
    echo -e "${RED}✗ F-Droid installation failed. Please install manually from https://f-droid.org${NC}"
    echo "Press Enter to continue anyway..."
    read -r
fi

# Open F-Droid first to let it initialize and update repos
echo -e "${CYAN}Opening F-Droid to initialize...${NC}"
adb shell monkey -p org.fdroid.fdroid -c android.intent.category.LAUNCHER 1 > /dev/null 2>&1
sleep 3

echo -e "${CYAN}Please wait for F-Droid to update its repository list (first time may take a minute)${NC}"
echo ""
while true; do
    echo -e "${CYAN}Press Enter when ready, or 'r' to re-open F-Droid:${NC}"
    read -r FDROID_INPUT
    if [ "$FDROID_INPUT" = "r" ] || [ "$FDROID_INPUT" = "R" ]; then
        echo -e "${CYAN}Re-opening F-Droid...${NC}"
        adb shell monkey -p org.fdroid.fdroid -c android.intent.category.LAUNCHER 1 > /dev/null 2>&1
    else
        break
    fi
done

# F-Droid apps to install
declare -a FDROID_APPS=(
    "helium314.keyboard|HeliBoard"
    "org.fossify.contacts|Fossify Contacts"
    "eu.faircode.email|FairEmail (Private Email)"
    "org.fairscan.app|FairScan (Doc Scanner)"
)

echo ""
for app in "${FDROID_APPS[@]}"; do
    PACKAGE=$(echo "$app" | cut -d'|' -f1)
    NAME=$(echo "$app" | cut -d'|' -f2)
    
    # Check if already installed
    if adb shell pm list packages | grep -q "^package:$PACKAGE$"; then
        echo -e "${GREEN}✓ $NAME already installed${NC}"
    else
        echo -e "${YELLOW}→ Install: $NAME${NC}"
        
        # Open F-Droid app
        adb shell monkey -p org.fdroid.fdroid -c android.intent.category.LAUNCHER 1 > /dev/null 2>&1
        
        echo -e "${CYAN}  In F-Droid, search for: $NAME${NC}"
        echo -e "${CYAN}  Press Enter after installing $NAME...${NC}"
        read -r
        
        # Special handling for HeliBoard - open it and complete setup
        if [ "$PACKAGE" = "helium314.keyboard" ]; then
            echo ""
            echo -e "${CYAN}  Now open HeliBoard and complete the setup:${NC}"
            echo "    1. Tap 'Enable HeliBoard'"
            echo "    2. Toggle HeliBoard ON"
            echo "    3. Tap 'Select HeliBoard'"
            echo "    4. Choose HeliBoard as input method"
            echo ""
            echo -e "${YELLOW}  ⚠️  Android will warn: 'This app may collect all your keystrokes'${NC}"
            echo -e "${GREEN}  ✓  This is EXACTLY why we're using HeliBoard!${NC}"
            echo -e "${GREEN}     Unlike stock keyboards, HeliBoard is 100% OFFLINE.${NC}"
            echo -e "${GREEN}     It has NO network permissions - your keystrokes stay on device.${NC}"
            echo ""
            echo -e "${RED}  🔒 IMPORTANT: Disable ALL other keyboards to prevent tracking:${NC}"
            echo "     - Toggle OFF Gboard (Google keyboard)"
            echo "     - Toggle OFF Sogou (if present)"
            echo "     - Toggle OFF any other keyboards"
            echo "     Only HeliBoard should be enabled!"
            echo ""
            adb shell am start -n helium314.keyboard/.settings.SettingsActivity > /dev/null 2>&1
            echo -e "${CYAN}  Press Enter after completing HeliBoard setup...${NC}"
            read -r
        fi
    fi
done

echo -e "${GREEN}✓ F-Droid apps installed${NC}"

# ============================================================
# Step 6: Install custom launcher
# ============================================================

echo ""
echo -e "${YELLOW}[6/14] Installing custom launcher...${NC}"

if [ ! -f "$LAUNCHER_APK" ]; then
    echo -e "${RED}Error: launcher.apk not found at $LAUNCHER_APK${NC}"
    echo "Please build the launcher first: cd bigme-launcher && ./gradlew assembleDebug"
    exit 1
fi

adb install -r "$LAUNCHER_APK" > /dev/null 2>&1
echo -e "${GREEN}✓ Dumb Phone launcher installed${NC}"

# ============================================================
# Step 7: Set launcher as default home
# ============================================================

echo ""
echo -e "${YELLOW}[7/14] Setting launcher as default home...${NC}"

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
# Step 8: Disable stock launcher and configure system
# ============================================================

echo ""
echo -e "${YELLOW}[8/14] Configuring system settings...${NC}"

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
    if adb shell pm list packages | grep -q "^package:$launcher$"; then
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
# Step 9: Set white wallpaper
# ============================================================

echo ""
echo -e "${YELLOW}[9/14] Setting white wallpaper...${NC}"

WHITE_IMAGE="$SCRIPT_DIR/white.png"

if [ -f "$WHITE_IMAGE" ]; then
    # Push white image to device
    adb push "$WHITE_IMAGE" /sdcard/Pictures/white.png > /dev/null 2>&1
    
    # Trigger media scan so it appears in gallery
    adb shell am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d file:///sdcard/Pictures/white.png > /dev/null 2>&1
    
    echo -e "${GREEN}✓ White image saved to Photos${NC}"
    
    # Open wallpaper settings
    echo -e "${CYAN}Opening wallpaper settings...${NC}"
    adb shell am start -a android.intent.action.SET_WALLPAPER > /dev/null 2>&1
    
    echo ""
    echo -e "${CYAN}Please set the white image as wallpaper:${NC}"
    echo "  1. Select 'Photos' or 'Gallery'"
    echo "  2. Choose 'white.png'"
    echo "  3. Set for BOTH Home screen AND Lock screen"
    echo ""
    echo "Press Enter after setting the wallpaper..."
    read -r
    
    echo -e "${GREEN}✓ Wallpaper configured${NC}"
else
    echo -e "${YELLOW}  white.png not found, skipping wallpaper setup${NC}"
fi

# ============================================================
# Step 10: Aggressive Bloatware Removal
# ============================================================

echo ""
echo -e "${YELLOW}[10/14] Removing bloatware...${NC}"
echo -e "${CYAN}Uninstalling non-essential apps to free up resources...${NC}"
echo ""

# Bigme/XRZ Bloatware (17 apps)
BIGME_BLOATWARE=(
    "com.xrz.ai|Bigme AI"
    "com.xrz.appstore|Bigme App Store"
    "com.xrz.bigmecloud|Bigme Cloud"
    "com.xrz.bookmall|Book Mall"
    "com.xrz.bookself|Bookshelf"
    "com.xrz.btranslate|Bigme Translate"
    "com.xrz.dictapp|Dictionary"
    "com.xrz.ebook|E-Book Reader"
    "com.xrz.ebook.launcher|E-Book Launcher"
    "com.xrz.hoverballdemo|Hover Ball"
    "com.xrz.music|Music Player"
    "com.xrz.scandoc|Document Scanner"
    "com.xrz.soundrecord|Sound Recorder"
    "com.xrz.voice.text|Voice to Text"
    "com.xrz.xreaderV3|X Reader"
    "com.b300.xrz.web|Bigme Browser"
    "com.ebook.wifitransferbook|WiFi Transfer"
)

# Google Apps Not In Dumb Phone List (12 apps)
GOOGLE_BLOATWARE=(
    "com.google.android.youtube|YouTube"
    "com.google.android.apps.youtube.music|YouTube Music"
    "com.google.android.apps.docs|Google Docs"
    "com.google.android.apps.tachyon|Google Meet"
    "com.google.android.keep|Google Keep"
    "com.google.android.videos|Google TV"
    "com.google.android.apps.wellbeing|Digital Wellbeing"
    "com.google.android.gm|Gmail"
    "com.google.android.apps.photos|Google Photos"
    "com.google.android.googlequicksearchbox|Google Search"
    "com.google.android.apps.googleassistant|Google Assistant"
    "com.google.android.calendar|Google Calendar"
)

# Other Bloatware (11 apps)
OTHER_BLOATWARE=(
    "com.sohu.inputmethod.sogou.oem|Sogou Keyboard"
    "com.eusoft.eudic|Eudic Dictionary"
    "com.socialnmobile.colordict|ColorDict"
    "com.iflytek.speechcloud|iFlytek Speech"
    "com.debug.loggerui|Logger UI"
    "com.example.test|Test App"
    "com.mediatek.voicecommand|Voice Command"
    "com.mediatek.voiceunlock|Voice Unlock"
    "com.xsyt.faceregister|Face Register"
    "com.mediatek.callrecorder|Call Recorder"
    "com.mediatek.factorymode|Factory Mode"
)

DELETED_APPS=()
FAILED_APPS=()

uninstall_apps() {
    local category="$1"
    shift
    local apps=("$@")
    local found_any=false
    local category_output=""
    
    for app in "${apps[@]}"; do
        PACKAGE=$(echo "$app" | cut -d'|' -f1)
        NAME=$(echo "$app" | cut -d'|' -f2)
        
        if adb shell pm list packages 2>/dev/null | grep -q "^package:$PACKAGE$"; then
            found_any=true
            RESULT=$(adb shell pm uninstall --user 0 "$PACKAGE" 2>&1)
            if echo "$RESULT" | grep -q "Success"; then
                category_output+="    ${RED}❌${NC} $NAME (removed)\n"
                DELETED_APPS+=("$PACKAGE|$NAME")
            elif echo "$RESULT" | grep -q "not installed for 0"; then
                category_output+="    ${GREEN}✓${NC} $NAME (already removed)\n"
            else
                category_output+="    ${YELLOW}⚠️${NC} $NAME (system protected)\n"
                FAILED_APPS+=("$PACKAGE|$NAME")
            fi
        fi
    done
    
    if [ "$found_any" = true ]; then
        echo -e "${YELLOW}  $category:${NC}"
        echo -e "$category_output"
    fi
}

uninstall_apps "Bigme Bloatware" "${BIGME_BLOATWARE[@]}"
uninstall_apps "Unused Google Apps" "${GOOGLE_BLOATWARE[@]}"
uninstall_apps "Other Bloatware" "${OTHER_BLOATWARE[@]}"

echo ""
echo -e "${GREEN}✓ Removed ${#DELETED_APPS[@]} apps${NC}"

# ============================================================
# Step 11: Privacy Hardening
# ============================================================

echo ""
echo -e "${YELLOW}[11/14] Applying privacy hardening...${NC}"

# Disable telemetry
echo -e "${CYAN}Disabling telemetry...${NC}"
adb shell settings put global upload_apk_enable 0 2>/dev/null || true
adb shell settings put secure send_action_app_error 0 2>/dev/null || true
adb shell settings put global dropbox_max_files 0 2>/dev/null || true

# Delete advertising ID
echo -e "${CYAN}Deleting advertising ID...${NC}"
adb shell settings put secure advertising_id null 2>/dev/null || true
adb shell settings put secure limit_ad_tracking 1 2>/dev/null || true

# Configure Private DNS (NextDNS for tracker blocking)
echo -e "${CYAN}Configuring NextDNS for tracker blocking...${NC}"
adb shell settings put global private_dns_mode hostname 2>/dev/null || true
adb shell settings put global private_dns_specifier dns.nextdns.io 2>/dev/null || true

# Disable Google backup
echo -e "${CYAN}Disabling Google backup...${NC}"
adb shell settings put secure backup_enabled 0 2>/dev/null || true
adb shell settings put secure backup_auto_restore 0 2>/dev/null || true

# Restrict Play Services permissions
echo -e "${CYAN}Restricting Play Services permissions...${NC}"
adb shell appops set com.google.android.gms READ_CLIPBOARD deny 2>/dev/null || true
adb shell appops set com.google.android.gms WRITE_CLIPBOARD deny 2>/dev/null || true
adb shell appops set com.google.android.gms READ_CONTACTS deny 2>/dev/null || true
adb shell appops set com.google.android.gms READ_CALENDAR deny 2>/dev/null || true
adb shell appops set com.google.android.gms READ_CALL_LOG deny 2>/dev/null || true
adb shell appops set com.google.android.gms READ_SMS deny 2>/dev/null || true

# Disable Google Contacts sync (using Fossify instead)
echo -e "${CYAN}Disabling Google Contacts sync...${NC}"
adb shell pm disable-user --user 0 com.google.android.syncadapters.contacts 2>/dev/null || true

# Remove replaced apps
echo -e "${CYAN}Removing replaced apps...${NC}"
if adb shell pm uninstall --user 0 com.readdle.spark 2>/dev/null; then
    echo -e "  ${RED}❌${NC} Removed Spark (replaced by FairEmail)"
fi
if adb shell pm uninstall --user 0 com.adobe.scan.android 2>/dev/null; then
    echo -e "  ${RED}❌${NC} Removed Adobe Scan (replaced by FairScan)"
fi
if adb shell pm disable-user --user 0 com.google.android.contacts 2>/dev/null; then
    echo -e "  ${YELLOW}⚠️${NC} Disabled Google Contacts (replaced by Fossify)"
fi

echo -e "${GREEN}✓ Privacy hardening complete${NC}"

# ============================================================
# Step 12: Generate installed apps report
# ============================================================

echo ""
echo -e "${YELLOW}[12/14] Generating apps report...${NC}"

# Create reports directory if it doesn't exist
mkdir -p "$SCRIPT_DIR/reports"

APP_LIST_FILE="$SCRIPT_DIR/reports/apps-report-$(date +%Y%m%d-%H%M%S).txt"

# Get all packages
ALL_PACKAGES=$(adb shell pm list packages | sed 's/package://' | sort)
TOTAL_COUNT=$(echo "$ALL_PACKAGES" | wc -l | tr -d ' ')

{
    echo "# Bigme Hibreak Pro - Apps Report"
    echo "# Generated: $(date)"
    echo "# Device: $DEVICE"
    echo "# Packages remaining: $TOTAL_COUNT"
    echo ""
    echo "Legend: ✅ KEEP | ❌ DELETED | ⚠️ DISABLED"
    echo ""
    
    echo "================================================================================"
    echo "## DUMB PHONE LAUNCHER (Your Apps)"
    echo "================================================================================"
    echo ""
    echo "| Status | Package | App Name | Function |"
    echo "|--------|---------|----------|----------|"
    echo "| ✅ KEEP | com.bigme.dumbphone | Dumb Phone | Custom minimal launcher |"
    echo ""
    
    echo "================================================================================"
    echo "## USER-INSTALLED APPS (In Your Dumb Phone List)"
    echo "================================================================================"
    echo ""
    echo "| Status | Package | App Name | Function |"
    echo "|--------|---------|----------|----------|"
    echo "| ✅ KEEP | app.organicmaps | Organic Maps | Encrypted offline navigation |"
    echo "| ✅ KEEP | com.aisense.otter | Otter.ai | AI meeting transcription |"
    echo "| ✅ KEEP | com.ecobee.athenamobile | Ecobee | Smart thermostat control |"
    echo "| ✅ KEEP | com.openai.chatgpt | ChatGPT | AI assistant |"
    echo "| ✅ KEEP | com.openphone | Quo | Business phone/customer service |"
    echo "| ✅ KEEP | com.scotiabank.banking | Scotiabank | Banking app |"
    echo "| ✅ KEEP | com.td | TD Canada | Banking app |"
    echo "| ✅ KEEP | com.thewizrd.simpleweather | SimpleWeather | Weather app (ad-free) |"
    echo "| ✅ KEEP | com.tplink.kasa_android | Kasa | Smart home device control |"
    echo "| ✅ KEEP | com.whatsapp | WhatsApp | Semi-encrypted messaging |"
    echo "| ✅ KEEP | eu.faircode.email | FairEmail | Private direct IMAP email |"
    echo "| ✅ KEEP | org.fossify.contacts | Fossify Contacts | Local-only contacts |"
    echo "| ✅ KEEP | org.fossify.gallery | Fossify Gallery | Private photo gallery |"
    echo "| ✅ KEEP | org.thoughtcrime.securesms | Signal | Encrypted messaging |"
    echo "| ✅ KEEP | org.fairscan.app | FairScan | Offline PDF scanner |"
    echo "| ❌ DELETED | com.adobe.scan.android | Adobe Scan | Replaced by OSS Doc Scanner |"
    echo "| ❌ DELETED | com.readdle.spark | Spark | Replaced by FairEmail |"
    echo ""
    
    echo "================================================================================"
    echo "## GOOGLE SUITE (User-Facing Apps)"
    echo "================================================================================"
    echo ""
    echo "| Status | Package | App Name | Function |"
    echo "|--------|---------|----------|----------|"
    echo "| ⚠️ DISABLED | com.android.vending | Play Store | App store (hidden, auto-updates) |"
    echo "| ✅ KEEP | com.google.android.apps.maps | Google Maps | Navigation |"
    echo "| ✅ KEEP | com.google.android.apps.messaging | Google Messages | SMS/RCS messaging |"
    echo "| ✅ KEEP | com.google.android.apps.walletnfcrel | Google Wallet | Tap-to-pay & cards |"
    echo "| ✅ KEEP | com.google.android.calculator | Calculator | Calculator |"
    echo "| ⚠️ DISABLED | com.google.android.contacts | Google Contacts | Replaced by Fossify |"
    echo "| ✅ KEEP | com.google.android.dialer | Phone | Phone dialer |"
    echo "| ❌ DELETED | com.android.chrome | Chrome | Web browser |"
    echo "| ❌ DELETED | com.google.android.apps.docs | Google Docs | Document editing |"
    echo "| ❌ DELETED | com.google.android.apps.googleassistant | Google Assistant | Voice assistant |"
    echo "| ❌ DELETED | com.google.android.apps.photos | Google Photos | Replaced by Fossify |"
    echo "| ❌ DELETED | com.google.android.apps.tachyon | Google Meet | Video calling |"
    echo "| ❌ DELETED | com.google.android.apps.wellbeing | Digital Wellbeing | Screen time |"
    echo "| ❌ DELETED | com.google.android.apps.youtube.music | YouTube Music | Music streaming |"
    echo "| ❌ DELETED | com.google.android.calendar | Google Calendar | Calendar |"
    echo "| ❌ DELETED | com.google.android.gm | Gmail | Email (replaced by FairEmail) |"
    echo "| ❌ DELETED | com.google.android.googlequicksearchbox | Google Search | Search |"
    echo "| ❌ DELETED | com.google.android.keep | Google Keep | Notes |"
    echo "| ❌ DELETED | com.google.android.videos | Google TV | Video player |"
    echo "| ❌ DELETED | com.google.android.youtube | YouTube | Video streaming |"
    echo ""
    
    echo "================================================================================"
    echo "## GOOGLE SERVICES (Background/System)"
    echo "================================================================================"
    echo ""
    echo "| Status | Package | App Name | Function |"
    echo "|--------|---------|----------|----------|"
    echo "| ✅ KEEP | com.google.android.gms | Play Services | Core Google services |"
    echo "| ✅ KEEP | com.google.android.gsf | Google Services Framework | Google framework |"
    echo "| ✅ KEEP | com.google.android.webview | Android WebView | Web content rendering |"
    echo "| ✅ KEEP | com.google.android.tts | Google Text-to-Speech | Voice synthesis |"
    echo "| ✅ KEEP | com.google.android.permissioncontroller | Permission Controller | Permissions |"
    echo "| ✅ KEEP | com.google.android.packageinstaller | Package Installer | App installation |"
    echo "| ✅ KEEP | com.google.android.documentsui | Files | File manager |"
    echo "| ✅ KEEP | com.google.android.networkstack | Network Stack | Network services |"
    echo ""
    
    echo "================================================================================"
    echo "## BIGME/XRZ APPS (Manufacturer)"
    echo "================================================================================"
    echo ""
    echo "| Status | Package | App Name | Function |"
    echo "|--------|---------|----------|----------|"
    echo "| ⚠️ DISABLED | com.xrz.standby | Standby Screen | Lock screen logo |"
    echo "| ✅ KEEP | com.xrz.mutidisplay | Multi Display | E-ink display settings |"
    echo "| ✅ KEEP | com.xrz.sys.control | System Control | E-ink refresh settings |"
    echo "| ✅ KEEP | com.xrz.res.service | Resource Service | System service |"
    echo "| ❌ DELETED | com.xrz.ai | Bigme AI | AI assistant |"
    echo "| ❌ DELETED | com.xrz.appstore | Bigme App Store | Alternative app store |"
    echo "| ❌ DELETED | com.xrz.bigmecloud | Bigme Cloud | Cloud storage |"
    echo "| ❌ DELETED | com.xrz.bookmall | Book Mall | Book store |"
    echo "| ❌ DELETED | com.xrz.bookself | Bookshelf | E-book library |"
    echo "| ❌ DELETED | com.xrz.btranslate | Bigme Translate | Translation |"
    echo "| ❌ DELETED | com.xrz.dictapp | Dictionary | Dictionary app |"
    echo "| ❌ DELETED | com.xrz.ebook | E-Book Reader | E-book reader |"
    echo "| ❌ DELETED | com.xrz.ebook.launcher | E-Book Launcher | Reading launcher |"
    echo "| ❌ DELETED | com.xrz.hoverballdemo | Hover Ball | Floating shortcut |"
    echo "| ❌ DELETED | com.xrz.music | Music Player | Music player |"
    echo "| ❌ DELETED | com.xrz.scandoc | Document Scanner | Bigme doc scanner |"
    echo "| ❌ DELETED | com.xrz.soundrecord | Sound Recorder | Audio recording |"
    echo "| ❌ DELETED | com.xrz.voice.text | Voice to Text | Speech recognition |"
    echo "| ❌ DELETED | com.xrz.xreaderV3 | X Reader | PDF/document reader |"
    echo "| ❌ DELETED | com.b300.xrz.web | Bigme Browser | Web browser |"
    echo "| ❌ DELETED | com.ebook.wifitransferbook | WiFi Transfer | File transfer |"
    echo ""
    
    echo "================================================================================"
    echo "## MEDIATEK SYSTEM (Chipset/Hardware)"
    echo "================================================================================"
    echo ""
    echo "| Status | Package | App Name | Function |"
    echo "|--------|---------|----------|----------|"
    echo "| ✅ KEEP | com.mediatek.camera | Camera | Stock camera app |"
    echo "| ✅ KEEP | com.mediatek.miravision.ui | MiraVision | Display calibration |"
    echo "| ✅ KEEP | com.mediatek.batterywarning | Battery Warning | Low battery alerts |"
    echo "| ✅ KEEP | com.mediatek.ims | IMS Service | VoLTE/VoWiFi |"
    echo "| ✅ KEEP | com.mediatek.telephony | Telephony | Phone service |"
    echo "| ❌ DELETED | com.mediatek.callrecorder | Call Recorder | Call recording |"
    echo "| ❌ DELETED | com.mediatek.duraspeed | DuraSpeed | Performance optimization |"
    echo "| ❌ DELETED | com.mediatek.factorymode | Factory Mode | Hardware testing |"
    echo "| ❌ DELETED | com.mediatek.voicecommand | Voice Command | Voice control |"
    echo "| ❌ DELETED | com.mediatek.voiceunlock | Voice Unlock | Voice unlock |"
    echo ""
    
    echo "================================================================================"
    echo "## ANDROID CORE SYSTEM"
    echo "================================================================================"
    echo ""
    echo "| Status | Package | App Name | Function |"
    echo "|--------|---------|----------|----------|"
    echo "| ⚠️ DISABLED | com.android.launcher3 | Stock Launcher | Default home (replaced) |"
    echo "| ✅ KEEP | android | Android System | Core OS |"
    echo "| ✅ KEEP | com.android.systemui | System UI | Status bar, notifications |"
    echo "| ✅ KEEP | com.android.settings | Settings | System settings |"
    echo "| ✅ KEEP | com.android.phone | Phone Service | Telephony |"
    echo "| ✅ KEEP | com.android.bluetooth | Bluetooth | Bluetooth service |"
    echo "| ✅ KEEP | com.android.nfc | NFC | NFC service |"
    echo "| ✅ KEEP | com.android.deskclock | Clock | Clock & alarms |"
    echo "| ✅ KEEP | com.android.inputmethod.latin | AOSP Keyboard | Backup keyboard |"
    echo "| ✅ KEEP | com.android.providers.contacts | Contacts Provider | Contact storage |"
    echo "| ✅ KEEP | com.android.providers.downloads | Download Manager | Downloads |"
    echo "| ✅ KEEP | com.android.providers.media | Media Provider | Media database |"
    echo "| ✅ KEEP | com.android.providers.telephony | Telephony Provider | SMS/MMS storage |"
    echo "| ✅ KEEP | com.android.mms.service | MMS Service | MMS handling |"
    echo "| ✅ KEEP | com.android.shell | Shell | ADB shell |"
    echo "| ✅ KEEP | com.android.keychain | Key Chain | Certificate storage |"
    echo "| ✅ KEEP | com.android.emergency | Emergency Info | Emergency contacts |"
    echo ""
    
    echo "================================================================================"
    echo "## OTHER APPS"
    echo "================================================================================"
    echo ""
    echo "| Status | Package | App Name | Function |"
    echo "|--------|---------|----------|----------|"
    echo "| ✅ KEEP | com.trustonic.teeservice | TEE Service | Security enclave |"
    echo "| ❌ DELETED | com.sohu.inputmethod.sogou.oem | Sogou Keyboard | Chinese keyboard |"
    echo "| ❌ DELETED | com.eusoft.eudic | Eudic | Dictionary |"
    echo "| ❌ DELETED | com.socialnmobile.colordict | ColorDict | Dictionary |"
    echo "| ❌ DELETED | com.iflytek.speechcloud | iFlytek Speech | Chinese speech |"
    echo "| ❌ DELETED | com.xsyt.faceregister | Face Register | Face unlock setup |"
    echo "| ❌ DELETED | com.debug.loggerui | Logger UI | Debug logging |"
    echo ""
    
    echo "================================================================================"
    echo "## SUMMARY"
    echo "================================================================================"
    echo ""
    echo "Apps deleted in this session: ${#DELETED_APPS[@]}"
    echo ""
    echo "✅ KEEP   = Essential for dumb phone or system stability"
    echo "❌ DELETED = Uninstalled for user (can be reinstalled via Play Store or ADB)"
    echo "⚠️ DISABLED = Disabled but not uninstalled (can be re-enabled)"
    echo ""
    echo "To restore a deleted system app:"
    echo "  adb shell cmd package install-existing <package>"
    echo ""
    echo "To re-enable a disabled app:"
    echo "  adb shell pm enable <package>"
    echo ""
    
} > "$APP_LIST_FILE"

echo -e "${GREEN}✓ App list saved to: $APP_LIST_FILE${NC}"

# ============================================================
# Step 13: Install EB Garamond System Font
# ============================================================

echo ""
echo -e "${YELLOW}[13/14] Installing EB Garamond system font...${NC}"

# Create Fonts folder on device
adb shell mkdir -p /sdcard/Fonts 2>/dev/null || true

# Use bundled EB Garamond variable font (supports multiple weights)
FONT_FILE="$SCRIPT_DIR/EBGaramond-VariableFont_wght.ttf"
if [ -f "$FONT_FILE" ]; then
    adb push "$FONT_FILE" /sdcard/Fonts/ > /dev/null 2>&1
    echo -e "${GREEN}✓ EB Garamond font installed to /sdcard/Fonts/${NC}"
    
    echo ""
    echo -e "${CYAN}To apply EB Garamond as system font:${NC}"
    echo "  1. Go to Settings → Display → Font set"
    echo "  2. Tap 'My font' tab"
    echo "  3. Select 'EBGaramond-VariableFont_wght'"
    echo "  4. Tap 'Apply'"
    echo ""
    echo -e "${CYAN}Recommended: Adjust font size and weight for better readability:${NC}"
    echo "  5. Go back to Display settings"
    echo "  6. Tap 'Display size and text'"
    echo "  7. Increase 'Font size' by 2-3 steps (Garamond is smaller)"
    echo "  8. Enable 'Bold text' for better e-ink contrast"
    echo ""
    
    # Open font settings
    adb shell am start -a android.settings.DISPLAY_SETTINGS > /dev/null 2>&1
    
    echo "Press Enter after applying font, size, and bold settings..."
    read -r
    
    echo -e "${GREEN}✓ Font and display settings applied${NC}"
else
    echo -e "${YELLOW}  EBGaramond-VariableFont_wght.ttf not found in project directory${NC}"
    echo -e "${CYAN}  Download from: https://fonts.google.com/specimen/EB+Garamond${NC}"
fi

# ============================================================
# Step 14: Screen Timeout Settings
# ============================================================

echo ""
echo -e "${YELLOW}[14/14] Configuring screen timeout...${NC}"

echo ""
echo -e "${CYAN}Set your preferred screen timeout:${NC}"
echo "  - For e-ink displays, longer timeouts are recommended (5-10 min)"
echo "  - Shorter timeouts save battery but require more unlocks"
echo ""

# Open display settings
adb shell am start -a android.settings.DISPLAY_SETTINGS > /dev/null 2>&1

echo -e "${CYAN}In Display settings:${NC}"
echo "  1. Tap 'Screen timeout'"
echo "  2. Select your preferred timeout (recommended: 5 or 10 minutes)"
echo ""
echo "Press Enter after setting screen timeout..."
read -r

echo -e "${GREEN}✓ Screen timeout configured${NC}"

# ============================================================
# Done!
# ============================================================

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                    SETUP COMPLETE!                        ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Your Bigme is now a dumb phone!"
echo ""
echo "  ✅ Custom launcher installed"
echo "  ✅ ${#DELETED_APPS[@]} bloatware apps removed"
echo "  ✅ Stock launcher disabled"
echo "  ✅ Lock screen cleaned up"
echo "  ✅ Privacy hardening applied"
echo "  ✅ EB Garamond font installed"
echo "  ✅ Screen timeout configured"
echo ""
echo "Next steps:"
echo "  1. Sign into each app as needed"
echo "  2. Set up Google Wallet for tap-to-pay"
echo ""
echo -e "${CYAN}Apps report saved to:${NC}"
echo "  $APP_LIST_FILE"
echo ""
echo -e "${CYAN}To restore stock launcher later:${NC}"
echo "  adb shell pm enable com.android.launcher3"
echo ""

