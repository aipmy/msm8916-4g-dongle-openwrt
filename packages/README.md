# Offline OpenWrt Packages (aarch64)

This directory contains standalone `.apk` packages downloaded directly for offline installation onto Qualcomm MSM8916 Snapdragon 410 dongles running OpenWrt v25.12.5.

## Included Packages
- **`luci-theme-footstrap-*.apk`**: Modern responsive Dark Theme for LuCI web dashboard with sidebar navigation.
- **`htop-3.5.1-r1.apk`** + `libncurses6-6.4-r3.apk`: Interactive process viewer and CPU/RAM/Thermal monitor.
- **`iperf3-3.20-r1.apk`** + `libiperf3-3.20-r1.apk` + `libatomic1-14.3.0-r5.apk`: Network throughput measurement tool.

## How to Install to Modem
```bash
# 1. Send all APKs to modem /tmp/
scp -O packages/*.apk root@192.168.1.1:/tmp/

# 2. SSH into modem and install
ssh root@192.168.1.1
apk add --no-network --allow-untrusted /tmp/*.apk
rm -f /tmp/*.apk
```
