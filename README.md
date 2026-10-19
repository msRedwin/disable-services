# Disable Services ⚙️

KernelSU / KernelSU Next module — version **2.2**, author **msRedwin**.

Disables Double Tap to Wake (DT2W), stops Xiaomi MLiPay, Tencent Soter and Vendor ATrace init services without modifying the `/vendor` partition. No WebUI is included.

## Functions

| Component | Action |
|---|---|
| DT2W | Writes `0` to `/sys/touchpanel/double_tap` |
| Xiaomi MLiPay | Stops `vendor.mlipay-1-1` and `mlipay-1-1` if present |
| Tencent Soter HAL | Stops `soter-1-0` |
| Tencent SoterServer | Disables, hides, and force-stops `com.tencent.soter.soterserver` for Android user 0 |
| Vendor ATrace | Stops `vendor.atrace-hal-1-0` |

The module does not modify Shelter / user 10. Pre-existing manually hidden Tencent states are preserved upon uninstall.

## Installation

Install the module ZIP through KernelSU Next, then reboot. The module ID was changed to `disable_services`; remove the older `disable_services_dt2w_mlipay_atrace` module and reboot before installing this version.

## Verify as root

```sh
cat /sys/touchpanel/double_tap
getprop init.svc.vendor.mlipay-1-1
getprop init.svc.vendor.atrace-hal-1-0
getprop init.svc.soter-1-0
pidof com.tencent.soter.soterserver
dumpsys package com.tencent.soter.soterserver | grep 'User 0:'
tail -n 60 /data/adb/modules/disable_services/disable_services.log
```

The package may be absent on other devices. Disabling Soter can affect payment, biometric and security services. See [CHANGELOG.md](CHANGELOG.md) and [README.txt](README.txt).
