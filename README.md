# msm8916-4g-dongle-openwrt

> **All-in-One Flasher, EDL 9008 Recovery, Multi-Board DTB Patching, and OpenWrt Toolkit for Qualcomm MSM8916 Chinese 4G LTE USB Dongles (UZ801 v3, JZ0145, FY Series).**

[![GitHub Stars](https://img.shields.io/github/stars/aipmy/msm8916-4g-dongle-openwrt?style=flat-square)](https://github.com/aipmy/msm8916-4g-dongle-openwrt/stargazers)
[![Build OpenWrt Firmware](https://github.com/aipmy/msm8916-4g-dongle-openwrt/actions/workflows/build-jz0145.yml/badge.svg)](https://github.com/aipmy/msm8916-4g-dongle-openwrt/actions/workflows/build-jz0145.yml)
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Qualcomm%20MSM8916%20%28Snapdragon%20410%29-orange.svg?style=flat-square)]()
[![OpenWrt](https://img.shields.io/badge/OpenWrt-v25.12.5-green.svg?style=flat-square)](https://openwrt.org)

---

## Quick Links

- [Introduction](docs/Introduction.md)
- [Firmware Dump and Restore](docs/Firmware-Dump-and-Restore.md)
- [Customizing & Building OpenWrt](docs/Build-Guide.md)
- [Modifications](docs/Modifications.md)
- [OpenWRT](docs/OpenWRT.md)
- [Recovery](docs/Recovery.md)
- [Troubleshooting](docs/Troubleshooting.md)

---

## Overview

This repository provides an automated, unified Python toolkit (`flasher.py`) to manage, back up, recover, and flash **OpenWrt v25.12.5** onto Qualcomm Snapdragon 410 (MSM8916) USB 4G LTE Dongles (often marketed as UZ801, UFI, or generic 4G Wi-Fi modems).

It includes hardware-level fixes for newer board revisions (`JZ0145_V40_20260509`):
1. **Electronic SIM switch multiplexer support** via custom patched kernel DTB.
2. **Cellular baseband fix** (`+CME ERROR: phone failure`) via pre-injected `MCFG_SW_ROW.MBN` carrier profile.
3. **Automated one-command flashing and NVRAM preservation**.

---

## Prerequisites

Ensure your system has the required USB drivers and Python 3 installed:

- **Windows**:
  1. Install [Python 3](https://www.python.org/downloads/) (Make sure to check *"Add Python to PATH"* during setup).
  2. Install [Qualcomm HS-USB QDLoader 9008 Driver](https://gsmusbdriver.com/qualcomm-hs-usb-qdloader-9008) or use **Zadig** (included in `edl/Drivers/Windows/zadig-2.8.exe`) to install `WinUSB` or `libusb-win32` driver for VID `05C6` PID `9008`.
- **macOS**:
  ```bash
  brew install libusb
  ```
- **Linux (Ubuntu / Debian / Raspberry Pi)**:
  ```bash
  sudo apt update && sudo apt install -y python3 python3-venv python3-pip libusb-1.0-0-dev
  ```

---

## Quick Start

### 1. Clone Repository & Setup
```bash
git clone https://github.com/aipmy/msm8916-4g-dongle-openwrt.git
cd msm8916-4g-dongle-openwrt
```

### 2. Setup Virtual Environment & Install Dependencies

- **On Windows (PowerShell / Command Prompt):**
  ```powershell
  python -m venv venv
  .\venv\Scripts\activate
  pip install -r edl/requirements.txt
  ```

- **On macOS / Linux:**
  ```bash
  python3 -m venv venv
  source venv/bin/activate
  pip install -r edl/requirements.txt
  ```

### 3. Run Flasher (Interactive Menu)
```bash
python flasher.py
```

### 4. One-Line Flash OpenWrt (Direct CLI)
- **For New Revision (Board JZ0145):**
  ```bash
  python3 flasher.py --flash-openwrt --board 1 --skip-backup
  ```
- **For Classic Revision (Board FY_UZ801):**
  ```bash
  python3 flasher.py --flash-openwrt --board 2
  ```

---

## Credits & Acknowledgements

Special thanks and appreciation to the open-source projects and researchers that made this toolkit possible:

- **[B. Kerler (@bkerler)](https://github.com/bkerler/edl)** - For the invaluable `edl` toolset (Qualcomm Sahara / Firehose Client).
- **[AlienWolfX (@AlienWolfX)](https://github.com/AlienWolfX/UZ801-USB-MODEM)** - For extensive hardware reverse engineering, PCB pinouts, and documentation on the UZ801 USB dongle.
- **[hkfuertes (@hkfuertes)](https://github.com/hkfuertes/msm8916-openwrt)** - For maintaining modern OpenWrt builds for Qualcomm MSM8916 devices.
- **[OpenStick Community & PostmarketOS](https://github.com/OpenStick)** - For pioneering Linux on Qualcomm 4G sticks.

---

## Contributing

Contributions are welcome! If you have insights or modifications for other Qualcomm MSM8916 board variants, feel free to submit a pull request or open an issue.

## License

This repository is open-source software licensed under the [MIT License](LICENSE).

<p align="center">Maintained with ❤️ by <b><a href="https://github.com/aipmy">@aipmy</a></b></p>
