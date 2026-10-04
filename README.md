# msm8916-4g-dongle-openwrt

> **All-in-One Flasher, EDL 9008 Recovery, Multi-Board DTB Patching, and OpenWrt Toolkit for Qualcomm MSM8916 Chinese 4G LTE USB Dongles (UZ801 v3, JZ0145, FY Series).**

[![OpenWrt](https://img.shields.io/badge/OpenWrt-25.12.5-blue?logo=openwrt)](https://openwrt.org)
[![Qualcomm](https://img.shields.io/badge/SoC-Qualcomm%20MSM8916-red)](https://www.qualcomm.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## Fitur Utama

- **Auto EDL 9008 Transition**: Otomatis mendeteksi perangkat normal (Android/ADB) dan mengirim perintah `adb reboot edl` tanpa perlu jumper fisik.
- **Multi-Board Architecture Support**:
  - **`JZ0145_V40_20260509` (Board Baru - Rev 2026)**:
    - *Hardware SIM Switch Patch*: Otomatis mengaktifkan GPIO multiplexer (`GPIO 52` hotdet, `GPIO 22/23` SIM switch) di level kernel device-tree agar kartu SIM terbaca normal.
    - *Pre-injected Carrier Profile*: File `MCFG_SW_ROW.MBN` sudah diinjeksi langsung ke RootFS squashfs (mencegah error `DeviceNotReady` / `phone failure`).
    - *Hardware LED Calibration*: Disesuaikan dengan pin LED fisik asli (`Red=GPIO25`, `Green=GPIO6`, `Blue=GPIO7`).
  - **`FY_UZ801_V3.31` (Board Lama - FY Classic)**:
    - Dukungan native firmware UZ801v3 standar (`Red=GPIO7`, `Green=GPIO8`, `Blue=GPIO6`).
- **Precision Progress Bar**: Indikator progres flashing/dumping eMMC hingga 3 desimal (`xx.xxx%`) di 1 baris terminal tanpa wrap spam.
- **Safety NVRAM / IMEI Isolation**: Mencegah bentrok IMEI atau kerusakan kalibrasi RF saat melakukan backup/restore antar-board.
- **Zero-Dependency CLI Tool**: Ditulis murni dalam Python 3 terintegrasi langsung dengan `bkerler/edl`.

---

## Struktur Direktori

```text
msm8916-4g-dongle-openwrt/
├── flasher.py                    # Script CLI utama (Probe, Backup, Restore, Flash)
├── firmware/
│   ├── JZ0145_V40_20260509/      # Firmware OpenWrt (Kernel DTB patched + RootFS pre-injected)
│   └── FY_UZ801_V3.31/           # Firmware OpenWrt untuk board FY standar
├── backups/
│   ├── JZ0145_V40_20260509/      # Direktori arsip eMMC & NVRAM board baru
│   └── FY_UZ801_V3.31/           # Direktori arsip eMMC & NVRAM board lama
├── edl/                          # Qualcomm Sahara/Firehose client & loader
└── README.md
```

---

## Cara Penggunaan

### 1. Mode Menu Interaktif (Direkomendasikan)
Jalankan script di terminal:
```bash
python3 flasher.py
```
Menu operasi yang tersedia:
```text
[ MENU OPERASI BACKUP, RESTORE & EDL ]
  1. Reboot modem ke Mode Qualcomm EDL 9008 (adb reboot edl)
  2. Backup Full eMMC (1 File Biner 4GB - edl rf) [PILIHAN 1 FILE]
  3. Restore Full eMMC (Flash Balik 1 File Biner 4GB - edl wf)
  4. Backup Seluruh Partisi eMMC per File + XML (edl rl --genxml)
  5. Backup Partisi Kritis NVRAM & IMEI saja (fsc, fsg, modemst1/2)
  6. Flash OpenWrt v25.12.5 ke UZ801 (Auto-Flash + Restore IMEI)
  7. Restart / Reboot Modem dari Mode EDL ke Normal (edl reset)
  8. Cek Tabel Partisi eMMC (edl printgpt)
  0. Keluar
```

### 2. Flashing OpenWrt Otomatis (1 Perintah)

- **Untuk Board Baru (JZ0145):**
  ```bash
  python3 flasher.py --flash-openwrt --board 1 --skip-backup
  ```
- **Untuk Board Lama (FY_UZ801):**
  ```bash
  python3 flasher.py --flash-openwrt --board 2
  ```

*Script akan otomatis mendeteksi apakah modem sedang menyala di Android (otomatis kirim `adb reboot edl`) atau sudah di mode EDL 9008.*

---

## Akses OpenWrt Pasca-Flashing

- **IP Default**: `http://192.168.1.1`
- **Username**: `root`
- **Password**: *(kosong)*
- **Mode USB Gadget**: Otomatis terdeteksi sebagai Ethernet NCM/RNDIS di Linux/macOS/Windows.

---

## Catatan Teknis Hardware & Troubleshooting

### Mengapa Board JZ0145 Butuh Patch Khusus?
Modem 4G stik keluaran baru revisi Mei 2026 (`JZ0145_V40`) menggunakan modem baseband firmware generasi baru (`MPSS.DPM.2.0.c12`) dan chip switch elektronik slot kartu SIM:
1. **Saklar Hardware SIM**: Slot SIM dikontrol oleh GPIO. Jika `GPIO 52 (sim_hotdet)` tidak disetel `HIGH`, chip PMIC Qualcomm menganggap tidak ada kartu SIM yang dimasukkan (`Card state: absent`).
2. **Kebutuhan MCFG MBN**: Baseband baru mewajibkan file profil operator seluler (`/lib/firmware/MCFG_SW.MBN`). Tanpa file ini, modem akan menolak mengaktifkan radio pemancar (`+CFUN: 7` / `+CME ERROR: phone failure`).

Repository ini sudah mem-patch kedua kendala tersebut langsung di dalam image firmware, sehingga instalasi berjalan plug-and-play.

---

## Lisensi & Kredit

- OpenWrt build by [@hkfuertes](https://github.com/hkfuertes/msm8916-openwrt)
- Qualcomm EDL Client by [@bkerler](https://github.com/bkerler/edl)
- Toolkit & Hardware Patching by **Ariep ([@aipmy](https://github.com/aipmy))**
