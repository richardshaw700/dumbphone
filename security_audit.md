# Bigme Hibreak Pro Security Audit

## Executive Summary

This document outlines the privacy vulnerabilities present in a stock Bigme Hibreak Pro Android phone and the comprehensive hardening measures implemented to transform it into a privacy-respecting "dumb phone" with minimal attack surface.

---

## Part 1: Stock Bigme Phone - Privacy Breaches

### The Problem

A stock Bigme Hibreak Pro, like most Android phones, comes with numerous privacy-invasive apps and services that continuously collect, transmit, and store user data. Here's what a stock device exposes:

### 1.1 Google Services (Always Running)

| Service                  | What It Collects                           | Frequency         |
| ------------------------ | ------------------------------------------ | ----------------- |
| Google Play Services     | Location, app usage, device info, contacts | Continuous        |
| Google Location History  | GPS coordinates, places visited            | Every few minutes |
| Google Backup            | Photos, messages, app data, settings       | Daily             |
| Google Analytics         | App behavior, crashes, usage patterns      | Continuous        |
| Advertising ID           | Cross-app tracking for targeted ads        | Continuous        |
| SafetyNet/Play Integrity | Device fingerprint, installed apps         | Periodic          |

### 1.2 Stock Keyboard (Gboard or Sogou)

| Risk                     | Impact                                              |
| ------------------------ | --------------------------------------------------- |
| Keystroke logging        | Every password, message, search query sent to cloud |
| Predictive text training | Your writing patterns stored on servers             |
| Voice typing             | Audio recordings processed remotely                 |
| Clipboard access         | Copied passwords, sensitive data accessible         |

### 1.3 Bigme/XRZ Bloatware

The Bigme Hibreak Pro comes pre-installed with 17+ manufacturer apps:

| App                   | Privacy Risk                             |
| --------------------- | ---------------------------------------- |
| Bigme Cloud           | File sync to Chinese servers             |
| Bigme AI              | Voice/text processing on remote servers  |
| Bigme App Store       | Alternative app source, unknown vetting  |
| Bigme Browser         | Browsing history, no privacy controls    |
| Various readers/tools | Unnecessary permissions, data collection |

### 1.4 Default App Choices

| Stock App       | Privacy Issue                              |
| --------------- | ------------------------------------------ |
| Google Contacts | Synced to Google Cloud                     |
| Google Photos   | All photos uploaded to Google              |
| Chrome          | Browsing history, cookies synced to Google |
| Gmail           | All emails accessible to Google            |
| Google Maps     | Complete location history                  |

### 1.5 Network-Level Exposure

| Vector              | What's Exposed                              |
| ------------------- | ------------------------------------------- |
| DNS queries         | ISP sees every domain you visit             |
| HTTP connections    | Unencrypted traffic visible to network      |
| Telemetry endpoints | Device constantly phoning home              |
| All traffic         | ISP can monitor/log all connection metadata |

---

## Part 2: Hardening Plan

### 2.1 Philosophy

Transform the phone into a minimal, privacy-respecting device by:

1. **Eliminating unnecessary apps** - Remove all bloatware
2. **Replacing invasive apps** - Swap Google/cloud apps for local-only alternatives
3. **Restricting system services** - Limit Play Services permissions
4. **Blocking tracking at network level** - Use encrypted DNS with tracker blocking
5. **Disabling telemetry** - Turn off all usage reporting
6. **Encrypting all traffic** - Always-on VPN to hide from ISP

### 2.2 App Replacement Strategy

| Category    | Remove           | Replace With     | Why                       |
| ----------- | ---------------- | ---------------- | ------------------------- |
| Keyboard    | Gboard/Sogou     | HeliBoard        | 100% offline, open source |
| Contacts    | Google Contacts  | Fossify Contacts | Local only, no sync       |
| Email       | Gmail/Spark      | FairEmail        | Direct IMAP, no middleman |
| Photos      | Google Photos    | Fossify Gallery  | Local only, no cloud      |
| Doc Scanner | Adobe Scan       | FairScan         | 100% offline, no network  |
| Maps        | Google Maps only | + Organic Maps   | Offline, no tracking      |
| Messages    | Google only      | + Signal         | End-to-end encrypted      |

### 2.3 System Hardening

| Action                 | Method                     |
| ---------------------- | -------------------------- |
| Delete Advertising ID  | ADB settings command       |
| Disable telemetry      | ADB settings commands      |
| Disable Google backup  | ADB settings command       |
| Block tracker DNS      | NextDNS private DNS        |
| Restrict Play Services | ADB appops permissions     |
| Remove bloatware       | ADB uninstall commands     |
| Encrypt all traffic    | Mullvad VPN (always-on)    |
| Block ISP monitoring   | VPN kill switch enabled    |

### 2.4 Apps Removed

**Bigme Bloatware (17 apps):**

- Bigme AI, App Store, Cloud, Book Mall, Bookshelf, Translate, Dictionary
- E-Book Reader, E-Book Launcher, Hover Ball, Music, Doc Scanner
- Sound Recorder, Voice to Text, X Reader, Browser, WiFi Transfer

**Google Apps (12 apps):**

- YouTube, YouTube Music, Google Docs, Google Meet, Google Keep
- Google TV, Digital Wellbeing, Gmail, Google Photos, Google Search
- Google Assistant, Google Calendar

**Other Bloatware (11 apps):**

- Sogou Keyboard, dictionaries, debug apps, MediaTek voice tools

---

## Part 3: Final Security Audit

After implementing all hardening measures, here is the security posture of the device:

### 3.1 Fully Secured (No Cloud, No Tracking)

| App              | Privacy Status | Notes                                    |
| ---------------- | -------------- | ---------------------------------------- |
| HeliBoard        | ✅ Perfect     | Offline keyboard, no keystroke logging   |
| Fossify Contacts | ✅ Perfect     | Local only, no sync                      |
| Fossify Gallery  | ✅ Perfect     | Local only, no cloud                     |
| FairScan         | ✅ Perfect     | 100% offline, no network permission      |
| FairEmail        | ✅ Perfect     | Direct IMAP, no middleman reading emails |
| Organic Maps     | ✅ Perfect     | Offline, no tracking                     |
| Signal           | ✅ Excellent   | E2E encrypted, minimal metadata          |
| Calculator       | ✅ Perfect     | Local computation                        |
| Camera           | ✅ Perfect     | Local storage                            |
| NextDNS          | ✅ Excellent   | Blocks trackers at network level         |
| Mullvad VPN      | ✅ Excellent   | All traffic encrypted, ISP blind         |

### 3.2 Acceptable Risk (Necessary Trade-offs)

| App             | What They See        | Why It's Acceptable                          |
| --------------- | -------------------- | -------------------------------------------- |
| Google Wallet   | Transaction data     | Emergency use only, needed for NFC           |
| Google Maps     | Searches when used   | Organic Maps available as alternative        |
| Google Messages | SMS content          | Carrier sees it anyway; Signal for sensitive |
| WhatsApp        | Metadata (who/when)  | Content encrypted; Signal for sensitive      |
| Google Dialer   | Call logs            | Carrier already has this data                |
| Play Services   | Device exists        | Heavily restricted permissions               |
| SimpleWeather   | Location for weather | Ad-free, minimal app                         |
| TD/Scotiabank   | Financial data       | You trust your bank                          |

### 3.3 Remaining Exposure (Can't Easily Fix)

| App            | Who Sees What                             | Risk Level  |
| -------------- | ----------------------------------------- | ----------- |
| ChatGPT        | All conversations, questions, topics      | Medium      |
| Otter.ai       | Meeting transcripts, voice recordings     | Medium      |
| Kasa (TP-Link) | Home network, device schedules, occupancy | Medium-High |
| Ecobee         | Home occupancy patterns, schedules        | Medium      |
| Quo/OpenPhone  | Business calls, voicemails, texts         | Low-Medium  |

### 3.4 Before vs After Comparison

| Attack Vector      | Before                   | After                            |
| ------------------ | ------------------------ | -------------------------------- |
| Keystroke logging  | ❌ Exposed               | ✅ Blocked (HeliBoard)           |
| Contact harvesting | ❌ Google Cloud          | ✅ Local only (Fossify)          |
| Email surveillance | ❌ Third-party reads all | ✅ Direct IMAP (FairEmail)       |
| Document scanning  | ❌ Adobe Cloud           | ✅ Local only (OSS Scanner)      |
| Location tracking  | ❌ Google only           | ✅ Private option (Organic Maps) |
| Photo backup       | ❌ Google Photos         | ✅ Local only (Fossify Gallery)  |
| Advertising ID     | ❌ Tracking enabled      | ✅ Deleted                       |
| Telemetry          | ❌ Sending data          | ✅ Disabled                      |
| DNS queries        | ❌ ISP sees all          | ✅ Encrypted + blocking          |
| ISP surveillance   | ❌ All traffic visible   | ✅ VPN encrypted (Mullvad)       |
| Play Services      | ❌ Full access           | 🟡 Heavily restricted            |
| Google backup      | ❌ All data synced       | ✅ Disabled                      |
| Clipboard spying   | ❌ Play Services access  | ✅ Blocked                       |
| Bloatware          | ❌ 40+ unnecessary apps  | ✅ All removed                   |

### 3.5 Privacy Score Card

| Category           | Score | Notes                                 |
| ------------------ | ----- | ------------------------------------- |
| Core Communication | 9/10  | Signal + FairEmail = excellent        |
| Data Storage       | 10/10 | All local (Fossify apps, OSS Scanner) |
| Input Privacy      | 10/10 | HeliBoard = no keystroke logging      |
| Navigation         | 9/10  | Organic Maps option available         |
| System Telemetry   | 9/10  | Disabled + NextDNS blocking           |
| Network Privacy    | 10/10 | Mullvad VPN + NextDNS = ISP blind     |
| Smart Home         | 3/10  | Cloud-dependent, can't fix easily     |
| AI Services        | 4/10  | Cloud by design                       |

**Overall Score: 8.5/10**

Excellent for a phone that maintains Google Wallet functionality and smart home integration. VPN provides additional layer of ISP protection.

---

## Part 4: Remaining Attack Vectors

If a determined attacker targeted this device, their priority targets would be:

### Priority 1: Smart Home (Kasa + Ecobee)

**Risk:** Medium-High

These apps reveal:

- When you're home/away
- Your daily schedule patterns
- When the house is empty
- Home network topology

**Note:** TP-Link (Kasa) is a Chinese company with data residency concerns.

**Mitigation:** No easy fix without removing smart home functionality. Consider using a dedicated tablet at home instead.

### Priority 2: ChatGPT

**Risk:** Medium

If compromised, reveals:

- Your interests, concerns, problems
- Potentially sensitive questions
- Code, business ideas
- Personal dilemmas discussed

**Mitigation:** Avoid sharing truly sensitive personal/financial information. Consider local LLM in future.

### Priority 3: Otter.ai

**Risk:** Medium

Full audio and transcripts of business meetings stored on Otter's servers.

**Mitigation:** Avoid recording highly confidential discussions. Consider local recording alternative.

### Priority 4: Google Wallet

**Risk:** Low-Medium

Google sees:

- Where you make purchases
- When you make purchases
- Transaction amounts
- Merchant information

**Mitigation:** Use for emergencies only as planned. Physical cards for regular use.

---

## Part 5: What Would Achieve 10/10 Privacy

To achieve perfect privacy, the following additional steps would be required:

1. **Remove smart home apps** - Use dedicated tablet at home instead
2. **Run local LLM** - Replace ChatGPT with on-device AI
3. **Local meeting recorder** - Replace Otter.ai with offline solution
4. **Remove Google Wallet** - Use physical cards exclusively
5. **Custom ROM** - Install GrapheneOS (would require Pixel device)

However, for practical daily use with NFC payments and smart home control, **the current configuration achieves the best possible privacy without major lifestyle changes.**

---

## Appendix: Technical Implementation

### ADB Commands Applied

```bash
# Disable telemetry
adb shell settings put global upload_apk_enable 0
adb shell settings put secure send_action_app_error 0
adb shell settings put global dropbox_max_files 0

# Delete advertising ID
adb shell settings put secure advertising_id null
adb shell settings put secure limit_ad_tracking 1

# Private DNS (NextDNS)
adb shell settings put global private_dns_mode hostname
adb shell settings put global private_dns_specifier dns.nextdns.io

# Disable Google backup
adb shell settings put secure backup_enabled 0
adb shell settings put secure backup_auto_restore 0

# Restrict Play Services
adb shell appops set com.google.android.gms READ_CLIPBOARD deny
adb shell appops set com.google.android.gms WRITE_CLIPBOARD deny
adb shell appops set com.google.android.gms READ_CONTACTS deny
adb shell appops set com.google.android.gms READ_CALENDAR deny
adb shell appops set com.google.android.gms READ_CALL_LOG deny
adb shell appops set com.google.android.gms READ_SMS deny
```

### Apps Installed from F-Droid

| App              | Package ID           | Purpose             |
| ---------------- | -------------------- | ------------------- |
| HeliBoard        | helium314.keyboard   | Privacy keyboard    |
| Fossify Contacts | org.fossify.contacts | Local contacts      |
| FairEmail        | eu.faircode.email    | Direct IMAP email   |
| FairScan         | org.fairscan.app     | Offline PDF scanner |
| F-Droid          | org.fdroid.fdroid    | Privacy app store   |

### Final Launcher App List

1. Phone (Google Dialer)
2. Messages (Unencrypted / Semi-encrypted / Encrypted)
3. AI Chat (ChatGPT)
4. Wallet (Google Wallet)
5. Maps (Unencrypted / Encrypted)
6. Settings
7. Weather (SimpleWeather)
8. Calculator
9. Camera
10. Photos (Fossify Gallery)
11. Email (FairEmail)
12. Doc Scanner (FairScan)
13. AI Note Taker (Otter.ai)
14. TD Bank
15. Scotiabank
16. Smart Devices (Kasa)
17. Contacts (Fossify Contacts)
18. Thermostat (Ecobee)
19. Quo (OpenPhone)

---

_Document generated: January 2026_
_Device: Bigme Hibreak Pro_
_Android Version: Stock (hardened)_
