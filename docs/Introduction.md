# Introduction

This repository provides an automated, unified Python toolkit (`flasher.py`) to manage, back up, recover, and flash **OpenWrt v25.12.5** onto Qualcomm Snapdragon 410 (MSM8916) USB 4G LTE Dongles (often marketed as UZ801, UFI, or generic 4G Wi-Fi modems).

---

## Hardware Reference Photos

Below are reference photographs of the classic dongle casing, PCB layout, Qualcomm MSM8916 SoC, PMIC, and eMMC storage:

| Outer Casing Front | Outer Casing Back |
| :---: | :---: |
| ![front](https://i.ibb.co/55fNj7D/front.jpg) | ![back](https://i.ibb.co/2s72SLL/back.jpg) |

| PCB Board (Top View) | PCB Board (Bottom View) |
| :---: | :---: |
| ![board1](https://i.ibb.co/5vZXKMQ/board1.jpg) | ![board2](https://i.ibb.co/1Z8WZq0/board2.jpg) |

| Qualcomm MSM8916 SoC | Storage eMMC / PM8916 PMIC |
| :---: | :---: |
| ![cpu](https://i.ibb.co/sbChyH9/cpu.jpg) | ![storage](https://i.ibb.co/Z8mh33d/storage.jpg) |

*(Reference images credit: AlienWolfX/UZ801-USB-MODEM analysis)*

---

## Device Specifications & Hardware Info

The heart of these dongles is a Qualcomm Snapdragon 410 (MSM8916 SoC) paired with a PM8916 PMIC and 4GB eMMC storage. In stock factory Android configurations, two CPU cores are typically disabled or restricted to prevent thermal runaway.

### Processor Information (`/proc/cpuinfo`)
```text
processor       : 0
model name      : ARMv7 Processor rev 0 (v7l)
BogoMIPS        : 38.40
Features        : swp half thumb fastmult vfp edsp neon vfpv3 tls vfpv4 idiva idivt
CPU implementer : 0x41
CPU architecture: 7
CPU variant     : 0x0
CPU part        : 0xd03
CPU revision    : 0

processor       : 1
model name      : ARMv7 Processor rev 0 (v7l)
BogoMIPS        : 38.40
Features        : swp half thumb fastmult vfp edsp neon vfpv3 tls vfpv4 idiva idivt
CPU implementer : 0x41
CPU architecture: 7
CPU variant     : 0x0
CPU part        : 0xd03
CPU revision    : 0

Hardware        : Qualcomm Technologies, Inc MSM8916
Revision        : 0000
Serial          : 0000000000000000
Processor       : ARMv7 Processor rev 0 (v7l)
```

### Memory Information (`/proc/meminfo`)
```text
MemTotal:         397808 kB (~384 MB / 512 MB LPDDR3)
MemFree:           36072 kB
Buffers:            7876 kB
Cached:           115924 kB
SwapTotal:        196604 kB
SwapFree:         193548 kB
```

---

## Enabling ADB (Android Debug Bridge)

Some devices ship with ADB disabled out-of-the-box. To unlock ADB access before flashing or sending EDL commands:

1. Connect to the dongle's Wi-Fi network or plug it into your computer.
2. Open this URL in your web browser:
   ```text
   http://192.168.100.1/usbdebug.html
   ```
   *(For some firmware variants, try `http://192.168.0.1/usbdebug.html` or `http://192.168.43.1/usbdebug.html`)*
3. Click the toggle/button to enable USB Debugging.
4. Verify from your terminal:
   ```bash
   adb devices
   ```
   Once detected, you can directly reboot the modem into Qualcomm EDL mode using:
   ```bash
   adb reboot edl
   ```

---

## The Problem
Many users acquire Snapdragon 410 dongles expecting them to behave identically. However, manufacturers frequently revise PCB layouts and baseband firmware while keeping the same outer plastic shell.

The most notable difference is between:
1. **Classic Revision (FY_UZ801_V3.31)**:
   - Direct hardwired SIM lines.
   - Older baseband firmware (`UZ801_V3.3_5733`) with embedded carrier tables.
2. **New 2026 Revision (JZ0145_V40_20260509)**:
   - Electronic GPIO-multiplexed SIM card slot.
   - Modern baseband firmware (`MPSS.DPM.2.0.c12`) requiring dedicated carrier configuration files (`MCFG_SW_ROW.MBN`).
   - Flashing standard community OpenWrt onto this board results in `sim-missing` or `+CME ERROR: phone failure`.

---

## Key Features
- **Auto Device Detection**: Automatically scans USB bus for ADB or Qualcomm EDL 9008 mode.
- **One-Command Flasher**: Automatically writes GPT, bootloader partitions, kernel boot image, and rootfs.
- **NVRAM & IMEI Protection**: Automatic partition backup before flashing and restore after flashing.
- **Pre-injected Carrier Profile**: Embeds `MCFG_SW_ROW.MBN` directly into rootfs for plug-and-play LTE connection.
- **Kernel DTB Fix**: Patches Linux device tree to power SIM tray multiplexers on boot.
