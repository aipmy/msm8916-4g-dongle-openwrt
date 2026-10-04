# Hardware Analysis & Modifications

## Hardware Matrix: JZ0145 vs FY_UZ801

| Parameter | JZ0145_V40_20260509 (New) | FY_UZ801_V3.31 (Classic) |
| :--- | :--- | :--- |
| **Baseband Release** | Modern `MPSS.DPM.2.0.c12` | Legacy `UZ801_V3.3_5733` (Sep 2015) |
| **Carrier MBN Requirement** | **Mandatory** (`MCFG_SW_ROW.MBN`) | Handled internally by modem baseband |
| **SIM Tray Hardware** | **GPIO-switched Multiplexer** | **Direct hardwired** |
| **SIM Hotplug Detect** | **GPIO 52** (Active HIGH) | PMIC native |
| **SIM Switch Lines** | GPIO 22 (HIGH), GPIO 23 (HIGH), GPIO 1 (LOW) | Not applicable |
| **LED Pinout** | Red=GPIO 25, Green=GPIO 6, Blue=GPIO 7 | Red=GPIO 7, Green=GPIO 8, Blue=GPIO 6 |
| **Operating Temperature** | **~48.1 °C** (Idle) | **~60.1 °C** (Idle) |

---

## 1. Kernel Device Tree (DTB) Patching
In the board revision `JZ0145_V40_20260509`, the SIM card lines are routed through an electronic multiplexer. Without configuring these GPIOs at startup, the SIM tray receives no power, resulting in a persistent `sim-missing` error.

The kernel DTB is patched inside `boot.img` with:
- Asserting `GPIO 52` HIGH for hotplug detection.
- Configuring SIM select multiplexers:
  ```dts
  sim1_switch_gpio = <&msmgpio 22 0>;
  sim2_switch_gpio = <&msmgpio 23 0>;
  sim3_switch_gpio = <&msmgpio 1 0>;
  ```

---

## 2. Carrier Configuration Injection (`MCFG_SW_ROW.MBN`)
The baseband firmware requires an MBN profile to initialize cellular radio networks in Europe, Asia, and the Rest of the World (ROW).

In standard OpenWrt images, this profile is omitted. Our patched rootfs includes `MCFG_SW_ROW.MBN` extracted from the factory Android system partition and pre-installed at `/lib/firmware/MCFG_SW.MBN`.
