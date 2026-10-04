# msm8916-4g-dongle-openwrt

> **All-in-One Flasher, EDL 9008 Recovery, Multi-Board DTB Patching, and OpenWrt Toolkit for Qualcomm MSM8916 Chinese 4G LTE USB Dongles (UZ801 v3, JZ0145, FY Series).**

[![GitHub Stars](https://img.shields.io/github/stars/aipmy/msm8916-4g-dongle-openwrt?style=flat-square)](https://github.com/aipmy/msm8916-4g-dongle-openwrt/stargazers)
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Qualcomm%20MSM8916%20%28Snapdragon%20410%29-orange.svg?style=flat-square)]()
[![OpenWrt](https://img.shields.io/badge/OpenWrt-v25.12.5-green.svg?style=flat-square)](https://openwrt.org)

---

## Quick Links

- [Introduction](docs/Introduction.md)
- [Firmware Dump and Restore](docs/Firmware-Dump-and-Restore.md)
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

## Prerequisites & Dependencies

To communicate with the Qualcomm chip over USB EDL, the following packages are required:

### macOS
```bash
brew install libusb
python3 -m venv edl/venv
edl/venv/bin/pip install -r edl/requirements.txt
```

### Linux (Debian / Ubuntu / Raspberry Pi)
```bash
sudo apt update && sudo apt install -y python3-dev python3-pip libusb-1.0-0-dev
python3 -m venv edl/venv
edl/venv/bin/pip install -r edl/requirements.txt
```

---

## Quick Start

### 1. Interactive Menu (Recommended)
```bash
python3 flasher.py
```

### 2. One-Line Flash OpenWrt
- **For New Revision (Board JZ0145):**
  ```bash
  python3 flasher.py --flash-openwrt --board 1 --skip-backup
  ```
- **For Classic Revision (Board FY_UZ801):**
  ```bash
  python3 flasher.py --flash-openwrt --board 2
  ```

---

## Contributing

Contributions are welcome! If you have insights or modifications for other Qualcomm MSM8916 board variants, feel free to submit a pull request or open an issue.

## License

This repository is open-source software licensed under the [MIT License](LICENSE).

<p align="center">Maintained with ❤️ by <b><a href="https://github.com/aipmy">@aipmy</a></b></p>
