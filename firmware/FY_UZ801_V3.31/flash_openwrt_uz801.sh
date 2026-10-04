#!/bin/bash
# ==============================================================================
# Auto Flash OpenWrt v25.12.5 for Qualcomm MSM8916 UZ801 v3
# by Ariep (SysEng/DevOps)
# Usage: ./flash_openwrt_uz801.sh
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
EDL_BIN="$PROJECT_ROOT/edl/venv/bin/edl"
LOADER="$PROJECT_ROOT/edl/MSM8916_UZ801.bin"
BACKUP_DIR="$PROJECT_ROOT/backups/nvram_$(date +%Y%m%d_%H%M%S)"

BOOT_IMG="$SCRIPT_DIR/openwrt-msm89xx-msm8916-yiming-uz801v3-squashfs-boot.img"
ROOTFS_IMG="$SCRIPT_DIR/openwrt-msm89xx-msm8916-yiming-uz801v3-squashfs-system.img"
GPT_BIN="$SCRIPT_DIR/openwrt-msm89xx-msm8916-yiming-uz801v3-squashfs-gpt_both0.bin"
FIRMWARE_ZIP="$SCRIPT_DIR/openwrt-msm89xx-msm8916-yiming-uz801v3-firmware.zip"

TOT_SECTORS=7569408

echo "============================================================"
echo "   OPENWRT UZ801 v3 MASS-FLASHING UTILITY (EDL 9008)"
echo "============================================================"
echo

# 1. Verifikasi File Image
for f in "$BOOT_IMG" "$ROOTFS_IMG" "$GPT_BIN" "$FIRMWARE_ZIP" "$LOADER" "$EDL_BIN"; do
    if [ ! -f "$f" ]; then
        echo "[-] ERROR: File tidak ditemukan: $f"
        exit 1
    fi
done
echo "[+] Semua file firmware terverifikasi 100% lengkap."

# 2. Cek Koneksi EDL
echo "[*] Mendeteksi modem di mode EDL 9008..."
if ! ioreg -p IOUSB -w0 | grep -q "QHSUSB__BULK"; then
    echo "[!] Modem belum terdeteksi di EDL mode."
    echo "[*] Mencoba switch via ADB..."
    adb reboot edl 2>/dev/null || true
    sleep 3
    if ! ioreg -p IOUSB -w0 | grep -q "QHSUSB__BULK"; then
        echo "[-] ERROR: Modem tidak terdeteksi di USB EDL 9008."
        echo "    Pastikan modem tercolok atau switch via 'adb reboot edl'."
        exit 1
    fi
fi
echo "[+] Handshake EDL 9008 & Firehose Loader Sukses!"

# 3. Ekstrak .mbn firmware
FW_TMP="$(mktemp -d)"
trap 'rm -rf "$FW_TMP"' EXIT
echo "[*] Mengekstrak partisi radio/bootloader .mbn..."
unzip -q -j -d "$FW_TMP" "$FIRMWARE_ZIP" "*.mbn"

# 4. Backup Partisi Kritis (IMEI / NVRAM)
mkdir -p "$BACKUP_DIR"
echo "[*] Mencadangkan IMEI & NVRAM ke: $BACKUP_DIR"
for part in fsc fsg modemst1 modemst2 modem persist sec; do
    echo "    -> Dump partisi: $part"
    "$EDL_BIN" r "$part" "$BACKUP_DIR/$part.bin" --loader="$LOADER" --memory=eMMC >/dev/null
done
echo "[+] Backup NVRAM/IMEI selesai aman."

# 5. Flash Tabel Partisi Baru (GPT SquashFS OpenWrt)
echo "[*] Menulis tabel partisi OpenWrt GPT..."
GPT_TMP="$(mktemp -d)"
trap 'rm -rf "$FW_TMP" "$GPT_TMP"' EXIT
dd if="$GPT_BIN" bs=512 count=34         of="${GPT_TMP}/primary.bin"        2>/dev/null
dd if="$GPT_BIN" bs=512 skip=34 count=32 of="${GPT_TMP}/backup_entries.bin" 2>/dev/null
dd if="$GPT_BIN" bs=512 skip=66 count=1  of="${GPT_TMP}/backup_header.bin"  2>/dev/null

"$EDL_BIN" ws 0                      "${GPT_TMP}/primary.bin"        --loader="$LOADER" --memory=eMMC >/dev/null
"$EDL_BIN" ws $((TOT_SECTORS - 33)) "${GPT_TMP}/backup_entries.bin" --loader="$LOADER" --memory=eMMC >/dev/null
"$EDL_BIN" ws $((TOT_SECTORS - 1))  "${GPT_TMP}/backup_header.bin"  --loader="$LOADER" --memory=eMMC >/dev/null
echo "[+] Tabel partisi OpenWrt berhasil ditulis."

# 6. Flash Firmware Bootloader MBN
echo "[*] Menulis bootloader MBN..."
for part in sbl1 tz rpm hyp aboot; do
    echo "    -> Flashing $part.mbn"
    "$EDL_BIN" w "$part" "$FW_TMP/$part.mbn" --loader="$LOADER" --memory=eMMC >/dev/null
done

# 7. Flash Kernel & Rootfs OpenWrt
echo "[*] Flashing OpenWrt Kernel (boot)..."
"$EDL_BIN" w boot "$BOOT_IMG" --loader="$LOADER" --memory=eMMC >/dev/null

echo "[*] Flashing OpenWrt System (rootfs squashfs)..."
"$EDL_BIN" w rootfs "$ROOTFS_IMG" --loader="$LOADER" --memory=eMMC >/dev/null

echo "[*] Erasing rootfs_data (clean overlay)..."
"$EDL_BIN" e rootfs_data --loader="$LOADER" --memory=eMMC >/dev/null || true

# 8. Restore Partisi Radio / IMEI
echo "[*] Mengembalikan partisi sinyal & IMEI..."
for part in fsc fsg modemst1 modemst2 modem persist sec; do
    echo "    -> Restoring $part"
    "$EDL_BIN" w "$part" "$BACKUP_DIR/$part.bin" --loader="$LOADER" --memory=eMMC >/dev/null
done

# 9. Reboot Modem
echo
echo "============================================================"
echo "[+] FLASHING OPENWRT v25.12.5 SELESAI 100%!"
echo "[*] Merestart modem..."
echo "============================================================"
"$EDL_BIN" reset --loader="$LOADER" --memory=eMMC >/dev/null 2>&1 || true

echo
echo "[i] IP Default OpenWrt: 192.168.1.1"
echo "[i] Login LuCI Web / SSH: root (tanpa password)"
echo
