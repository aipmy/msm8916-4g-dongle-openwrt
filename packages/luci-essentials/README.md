# Offline LuCI & Modem Packages (aarch64)

Koleksi lengkap 50 paket APK essential LuCI Web UI dan Modem Management untuk Qualcomm MSM8916 Snapdragon 410 (OpenWrt v25.12.5).

## Paket Utama yang Termasuk:
- **LuCI Web Dashboard**: `luci`, `luci-base`, `luci-mod-admin-full`, `luci-mod-status`, `luci-mod-network`, `luci-mod-system`, `luci-app-package-manager`, `luci-app-firewall`.
- **Modem & Cellular Tools**: `modemmanager`, `qmi-utils`, `libqmi`, `libmbim`, `libqrtr-glib`, `luci-proto-modemmanager`, `luci-proto-ppp`.
- **Utilities**: `bash`, `nano`, `coreutils`, `mtools`, `dbus`, `glib2`.

## Cara Pasang Offline ke Modem:
```bash
# 1. Kirim semua file APK ke /tmp/ modem
scp -O packages/luci-essentials/*.apk root@192.168.1.1:/tmp/

# 2. Pasang via SSH
ssh root@192.168.1.1
apk add --allow-untrusted /tmp/*.apk
rm -f /tmp/*.apk /tmp/luci-indexcache
/etc/init.d/rpcd restart
/etc/init.d/uhttpd restart
```
