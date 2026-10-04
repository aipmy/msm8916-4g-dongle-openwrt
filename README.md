# msm8916-4g-dongle-openwrt

> **All-in-One Flasher, EDL 9008 Recovery, Multi-Board DTB Patching, and OpenWrt Toolkit for Qualcomm MSM8916 Chinese 4G LTE USB Dongles (UZ801 v3, JZ0145, FY Series).**

[![GitHub Stars](https://img.shields.io/github/stars/aipmy/msm8916-4g-dongle-openwrt?style=flat-square)](https://github.com/aipmy/msm8916-4g-dongle-openwrt/stargazers)
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Qualcomm%20MSM8916%20%28Snapdragon%20410%29-orange.svg?style=flat-square)]()
[![OpenWrt](https://img.shields.io/badge/OpenWrt-v25.12.5-green.svg?style=flat-square)](https://openwrt.org)

🌐 **Language / Bahasa:** [English](#english) | [Bahasa Indonesia](#bahasa-indonesia)

---

## Quick Links

- [English Documentation](#english)
  - [1. Introduction](#1-introduction)
  - [2. Hardware & Board Matrix](#2-hardware--board-matrix)
  - [3. Firmware Dump and Restore](#3-firmware-dump-and-restore)
  - [4. Modifications & DTB Patching](#4-modifications--dtb-patching)
  - [5. OpenWrt Flashing & Recovery](#5-openwrt-flashing--recovery)
  - [6. Troubleshooting](#6-troubleshooting)
- [Dokumentasi Bahasa Indonesia](#bahasa-indonesia)
  - [1. Pengenalan](#1-pengenalan)
  - [2. Matriks Perbedaan Board Hardware](#2-matriks-perbedaan-board-hardware)
  - [3. Dump & Restore Firmware (Backup Penuh)](#3-dump--restore-firmware-backup-penuh)
  - [4. Modifikasi Kernel DTB & Profil Seluler](#4-modifikasi-kernel-dtb--profil-seluler)
  - [5. Flashing & Pemulihan OpenWrt](#5-flashing--pemulihan-openwrt)
  - [6. Solusi Masalah (Troubleshooting)](#6-solusi-masalah-troubleshooting)

---

<a name="english"></a>
# English

## 1. Introduction
This repository provides an automated, unified Python toolkit (`flasher.py`) to manage, back up, recover, and flash **OpenWrt v25.12.5** onto Qualcomm Snapdragon 410 (MSM8916) USB 4G LTE Dongles (often sold as UZ801, UFI, or generic 4G Wi-Fi sticks).

Unlike standard builds that suffer from missing SIM cards or cellular radio failures on newer board revisions, this toolkit addresses deep hardware variances across board revisions:
- **Board FY_UZ801_V3.31 (Classic)**: Direct SIM routing, legacy baseband firmware.
- **Board JZ0145_V40_20260509 (New 2026 Revision)**: Electronic GPIO-switched SIM tray (`GPIO 52`, `22`, `23`, `1`) and required carrier profile MBN (`MCFG_SW_ROW.MBN`).

---

## 2. Hardware & Board Matrix

| Hardware Feature | JZ0145_V40_20260509 (New Rev) | FY_UZ801_V3.31 (Classic Rev) |
| :--- | :--- | :--- |
| **Baseband Generation** | Modern `MPSS.DPM.2.0.c12` (`M8936FAAAANUZM`) | Legacy `UZ801_V3.3_5733` (Sep 2015) |
| **Carrier MBN Requirement** | **Mandatory** (`MCFG_SW_ROW.MBN` in `/lib/firmware`) | Built-in baseband internal tables |
| **SIM Tray Hardware** | **GPIO-switched Multiplexer** (GPIO 52 Hotdet, GPIO 22, 23, 1) | **Direct hardwired** to PMIC |
| **Status LEDs** | Red=`GPIO 25`, Green=`GPIO 6`, Blue=`GPIO 7` | Red=`GPIO 7`, Green=`GPIO 8`, Blue=`GPIO 6` |
| **Operating Thermal** | **~48.1 °C** (Cooler, low power draw) | **~60.1 °C** (Higher idle load) |
| **System Storage & RAM** | 4GB eMMC (`H4G2a`), 384MB / 512MB LPDDR3 | 4GB eMMC (`H4G2a`), 384MB / 512MB LPDDR3 |

---

## 3. Firmware Dump and Restore

### Entering Qualcomm EDL Mode (9008)
- **Software Method (ADB):**
  ```bash
  adb reboot edl
  ```
- **Hardware Testpad Method:**
  If bricked or bootlooping, bridge **USB D+ (Data+)** to **GND** while plugging the stick into your PC/Mac USB port for 3 seconds, then release. The device will enumerate as `05c6:9008` (QHSUSB__BULK).

### Backup eMMC (Raw Binary Dump)
```bash
python3 flasher.py
# Select Option 2 -> Dumps complete 4GB eMMC as a single raw .bin image
```

### Restore eMMC (Unbrick / Full Flash)
```bash
python3 flasher.py
# Select Option 3 -> Restores complete 4GB .bin image back to eMMC storage
```

---

## 4. Modifications & DTB Patching
Why does OpenWrt fail to detect SIM cards or LTE radios on newer boards out-of-the-box?

1. **SIM Switch Multiplexer**:
   The board uses GPIO lines to select and power the active SIM card slot. In our patched DTB (`boot.img`), these lines are asserted at kernel boot:
   - `GPIO 52`: `sim_hotdet_gpio` (Card detect, asserted HIGH)
   - `GPIO 22`: `sim1_switch_gpio` (asserted HIGH)
   - `GPIO 23`: `sim2_switch_gpio` (asserted HIGH)
   - `GPIO 1`: `sim3_switch_gpio` (asserted LOW)
2. **Carrier Configuration Injection (`MCFG_SW_ROW.MBN`)**:
   Modern baseband (`MPSS.DPM.2.0.c12`) crashes with `+CME ERROR: phone failure` if the carrier MBN profile is absent. This repository pre-injects `MCFG_SW_ROW.MBN` directly into the SquashFS rootfs at `/lib/firmware/MCFG_SW.MBN`.

---

## 5. OpenWrt Flashing & Recovery

### Automated One-Line Flashing:
- **For New Revision (JZ0145):**
  ```bash
  python3 flasher.py --flash-openwrt --board 1 --skip-backup
  ```
- **For Classic Revision (FY_UZ801):**
  ```bash
  python3 flasher.py --flash-openwrt --board 2
  ```

### Default Access Credentials:
- **Default IP Gateway**: `http://192.168.1.1`
- **SSH / LuCI Web Login**: `root` (No password)

---

## 6. Troubleshooting

1. **`DeviceClass - USBError(5, 'Input/Output Error')` after flashing**:
   - **Normal behavior**: This indicates that the Qualcomm modem received the reset command and rebooted the USB bus immediately into OpenWrt.
2. **SIM Card not detected (`sim-missing` / `card error`)**:
   - Ensure you selected `--board 1` if you have the `JZ0145` board.
   - Run `qmicli -p -d /dev/wwan0qmi0 --uim-get-card-status` via SSH to confirm card detection.
3. **Modem radio stuck in `+CFUN: 7` or `phone failure`**:
   - Ensure `/lib/firmware/MCFG_SW.MBN` exists on the modem filesystem.
   - Run `echo "AT+CFUN=1" > /dev/wwan0at1` to power on the transceiver.
4. **Change IMEI via AT Command**:
   ```bash
   echo -e "AT+WRIMEI=\"864894079584406\"\r" > /dev/wwan0at1
   ```

---

<a name="bahasa-indonesia"></a>
# Bahasa Indonesia

## 1. Pengenalan
Repository ini menyediakan toolkit otomatis berbasis Python (`flasher.py`) untuk mengelola, mencadangkan (backup), memulihkan (unbrick/restore), dan melakukan flashing **OpenWrt v25.12.5** pada stik modem USB 4G LTE Qualcomm Snapdragon 410 (MSM8916) seperti UZ801, UFI, dan stik 4G sejenis.

Firmware dan flasher ini dirancang khusus untuk mengatasi masalah umum pada modem stik Tiongkok:
- **Board FY_UZ801_V3.31 (Versi Lama/Klasik)**: Jalur SIM langsung, baseband firmware lama.
- **Board JZ0145_V40_20260509 (Versi Baru 2026)**: Memiliki saklar multiplexer SIM berbasis GPIO (`GPIO 52`, `22`, `23`, `1`) serta mewajibkan profil operator `MCFG_SW_ROW.MBN` agar baseband tidak mengalami `phone failure`.

---

## 2. Matriks Perbedaan Board Hardware

| Fitur Hardware | JZ0145_V40_20260509 (Board Baru) | FY_UZ801_V3.31 (Board Lama) |
| :--- | :--- | :--- |
| **Generasi Baseband** | Modern `MPSS.DPM.2.0.c12` (`M8936FAAAANUZM`) | Legacy `UZ801_V3.3_5733` (Sep 2015) |
| **Kebutuhan File Profil Operator** | **Wajib** (`MCFG_SW_ROW.MBN` di `/lib/firmware`) | Tidak butuh (tersimpan di internal baseband) |
| **Rangkaian Slot SIM Card** | **Electronic Switch GPIO** (GPIO 52 Hotdet, GPIO 22, 23, 1) | **Direct Hardwired** ke chip PMIC |
| **Indikator LED Fisik** | Merah=`GPIO 25`, Hijau=`GPIO 6`, Biru=`GPIO 7` | Merah=`GPIO 7`, Hijau=`GPIO 8`, Biru=`GPIO 6` |
| **Suhu Operasional (Thermal)** | **~48.1 °C** (Lebih dingin & efisien) | **~60.1 °C** (Lebih panas) |
| **Penyimpanan eMMC & RAM** | 4GB eMMC (`H4G2a`), 384MB / 512MB RAM | 4GB eMMC (`H4G2a`), 384MB / 512MB RAM |

---

## 3. Dump & Restore Firmware (Backup Penuh)

### Masuk ke Mode Qualcomm EDL (9008)
- **Metode Perangkat Lunak (ADB):**
  ```bash
  adb reboot edl
  ```
- **Metode Testpad / Jumper Hardware:**
  Jika modem mati total (brick/bootloop), hubungkan pin **USB D+ (Data+)** ke **GND** saat mencolokkan modem ke port USB selama 3 detik, lalu lepas. Modem akan terdeteksi sebagai `05c6:9008` (QHSUSB__BULK).

### Backup eMMC (Raw Binary Dump 1 File)
```bash
python3 flasher.py
# Pilih Menu No. 2 -> Melakukan full dump eMMC 4GB menjadi 1 file .bin utuh
```

### Restore Balik eMMC (Unbrick / Flashing Ulang)
```bash
python3 flasher.py
# Pilih Menu No. 3 -> Menulis ulang seluruh sektor eMMC dari file backup .bin
```

---

## 4. Modifikasi Kernel DTB & Profil Seluler
Mengapa kartu SIM tidak terbaca di firmware OpenWrt standar pada board baru?

1. **Multiplexer Saklar SIM**:
   Board baru menggunakan saklar elektronik untuk menghidupkan jalur daya slot kartu SIM. Di dalam kernel DTB (`boot.img`) yang telah dimodifikasi, pin-pin berikut diaktifkan saat boot:
   - `GPIO 52`: `sim_hotdet_gpio` (Deteksi SIM, di-set HIGH)
   - `GPIO 22`: `sim1_switch_gpio` (di-set HIGH)
   - `GPIO 23`: `sim2_switch_gpio` (di-set HIGH)
   - `GPIO 1`: `sim3_switch_gpio` (di-set LOW)
2. **Injeksi Profil Operator Seluler (`MCFG_SW_ROW.MBN`)**:
   Baseband modern akan mengalami crash (`+CME ERROR: phone failure`) jika file profil operator tidak ditemukan. Repositori ini sudah menyuntikkan file `MCFG_SW_ROW.MBN` ke dalam file image SquashFS di `/lib/firmware/MCFG_SW.MBN`.

---

## 5. Flashing & Pemulihan OpenWrt

### Perintah Cepat 1 Baris:
- **Untuk Board Baru (JZ0145):**
  ```bash
  python3 flasher.py --flash-openwrt --board 1 --skip-backup
  ```
- **Untuk Board Lama (FY_UZ801):**
  ```bash
  python3 flasher.py --flash-openwrt --board 2
  ```

### Informasi Login Default:
- **IP Gateway Web UI**: `http://192.168.1.1`
- **Login SSH / Web LuCI**: `root` (tanpa password)

---

## 6. Solusi Masalah (Troubleshooting)

1. **Muncul pesan `DeviceClass - USBError(5, 'Input/Output Error')` di akhir flash**:
   - **Kondisi Normal**: Pesan ini menandakan bahwa modem Qualcomm berhasil menerima sinyal soft-reboot dan langsung memutuskan koneksi USB untuk booting ke OpenWrt.
2. **Kartu SIM tidak terbaca (`sim-missing`)**:
   - Pastikan Anda memilih `--board 1` jika menggunakan board `JZ0145`.
   - Cek status deteksi kartu via SSH: `qmicli -p -d /dev/wwan0qmi0 --uim-get-card-status`.
3. **Modem radio stuck di status `+CFUN: 7` atau `phone failure`**:
   - Pastikan file `/lib/firmware/MCFG_SW.MBN` ada di sistem.
   - Nyalakan modul radio melalui terminal: `echo "AT+CFUN=1" > /dev/wwan0at1`.
4. **Mengubah IMEI Modem via AT Command**:
   ```bash
   echo -e "AT+WRIMEI=\"864894079584406\"\r" > /dev/wwan0at1
   ```

---

## Lisensi & Kontribusi
Proyek ini dirilis di bawah lisensi MIT. Silakan ajukan Issue atau Pull Request jika Anda menemukan varian board Snapdragon 410 lainnya.
Dikembangkan oleh **[@aipmy](https://github.com/aipmy)**.
