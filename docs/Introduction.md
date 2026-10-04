# Introduction

This repository provides an automated, unified Python toolkit (`flasher.py`) to manage, back up, recover, and flash **OpenWrt v25.12.5** onto Qualcomm Snapdragon 410 (MSM8916) USB 4G LTE Dongles (often marketed as UZ801, UFI, or generic 4G Wi-Fi modems).

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
