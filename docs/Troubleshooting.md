# Troubleshooting & FAQ

### 1. `DeviceClass - USBError(5, 'Input/Output Error')` at the end of flashing
- **Normal behavior**: This error occurs when the modem receives the `reset` command from the Firehose loader and resets its USB controller immediately to boot OpenWrt. It confirms the flashing succeeded.

---

### 2. SIM Card Not Detected (`sim-missing`)
- If you have board `JZ0145_V40_20260509`, make sure you flashed with `--board 1`.
- Verify card detection via SSH:
  ```bash
  qmicli -p -d /dev/wwan0qmi0 --uim-get-card-status
  ```
- If the card state is not `present`, check physical SIM orientation or test with another SIM card.

---

### 3. Radio Stuck in `+CFUN: 7` or `phone failure`
- This indicates that the baseband firmware cannot find the operator configuration file.
- Verify that `/lib/firmware/MCFG_SW.MBN` is present:
  ```bash
  ls -la /lib/firmware/MCFG_SW.MBN
  ```
- If absent, copy `MCFG_SW_ROW.MBN` from your factory Android backup into `/lib/firmware/MCFG_SW.MBN` and reboot.

---

### 4. How to Change or Restore IMEI via AT Command
Log in via SSH to `192.168.1.1` and run:
```bash
echo -e "AT+WRIMEI=\"864894079584406\"\r" > /dev/wwan0at1
```
Check the updated IMEI:
```bash
echo -e "AT+CGSN\r" > /dev/wwan0at1
```

---

### 5. Switching USB Gadget Mode (RNDIS vs CDC-NCM)
OpenWrt defaults to CDC-NCM for modern systems. If your host device (e.g. older router or Windows without drivers) requires RNDIS:
```bash
uci set network.usb.proto='dhcp'
uci commit network
/etc/init.d/network restart
```
