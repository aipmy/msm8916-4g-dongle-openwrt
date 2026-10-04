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

The heart of these dongles is a **Qualcomm Snapdragon 410 (MSM8916 SoC)** featuring a **Quad-Core 64-bit ARM Cortex-A53** processor, paired with a PM8916 PMIC and 4GB eMMC storage.

> **Key Difference Under OpenWrt**:
> - Under **Factory Android (KitKat)**, the system was artificially locked to 32-bit (`ARMv7`) and restricted to only **2 active cores** to avoid overheating.
> - Under **OpenWrt (Linux Kernel 6.12+)**, all **4 Cores are fully unlocked in native 64-bit mode (`ARMv8-A / aarch64`)** with hardware acceleration (`fp`, `asimd`, `crc32`, `cpuid`).

### Processor Information (`/proc/cpuinfo` under OpenWrt)
```text
processor       : 0
BogoMIPS        : 38.00
Features        : fp asimd evtstrm crc32 cpuid
CPU implementer : 0x41
CPU architecture: 8
CPU variant     : 0x0
CPU part        : 0xd03
CPU revision    : 0

processor       : 1
BogoMIPS        : 38.00
Features        : fp asimd evtstrm crc32 cpuid
CPU implementer : 0x41
CPU architecture: 8
CPU variant     : 0x0
CPU part        : 0xd03
CPU revision    : 0

processor       : 2
BogoMIPS        : 38.00
Features        : fp asimd evtstrm crc32 cpuid
CPU implementer : 0x41
CPU architecture: 8
CPU variant     : 0x0
CPU part        : 0xd03
CPU revision    : 0

processor       : 3
BogoMIPS        : 38.00
Features        : fp asimd evtstrm crc32 cpuid
CPU implementer : 0x41
CPU architecture: 8
CPU variant     : 0x0
CPU part        : 0xd03
CPU revision    : 0
```

### Memory Information (`/proc/meminfo` under OpenWrt)
```text
MemTotal:         391280 kB (~384 MB / 512 MB LPDDR3)
MemFree:          214544 kB (~210 MB Free)
MemAvailable:     275824 kB (~270 MB Available)
Buffers:            1044 kB
Cached:            86928 kB
SwapTotal:        195580 kB (ZRAM compressed swap)
SwapFree:         195580 kB
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
