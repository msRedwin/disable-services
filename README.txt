Disable Services ⚙️
KernelSU / KernelSU Next module - Version 2.2
Author: msRedwin
GitHub: https://github.com/msRedwin

PURPOSE
-------
This module disables DT2W and stops selected Xiaomi/Tencent/vendor services on
compatible Android devices. It does not remount or modify /vendor, remove APKs,
or edit Android init .rc files. No WebUI or systemless file overlay is required.

TARGETS AND OPERATIONS
----------------------
1. DT2W (Double Tap to Wake)
   Writes 0 to /sys/touchpanel/double_tap early in post-fs-data and reapplies
   it during late_start. The sysfs node must exist and be writable.

2. Xiaomi MLiPay
   Stops init services vendor.mlipay-1-1 and mlipay-1-1 if present.
   Signals the exact mlipayd@1.1 process if it remains after init stop.

3. Tencent Soter
   Stops init service soter-1-0 via setprop ctl.stop.
   Restricts com.tencent.soter.soterserver ONLY for Android user 0:
     pm disable-user --user 0 com.tencent.soter.soterserver
     pm hide --user 0 com.tencent.soter.soterserver
     am force-stop --user 0 com.tencent.soter.soterserver
   Unlike previous releases, no SIGTERM/SIGKILL loop is used against its
   Android PERSISTENT process. Package state is read from dumpsys package so
   a package already hidden by pm hide remains detectable. User 10 (Shelter)
   settings are NOT changed by the module.

4. Vendor ATrace
   Stops init service vendor.atrace-hal-1-0 if present.

EXECUTION
---------
post-fs-data.sh - Early DT2W disable.
service.sh      - Stops init services and restricts Tencent for user 0.
                  Rechecks after approximately 3, 10, and 30 seconds.
action.sh       - Reapplies the operations and shows disable_services.log.
uninstall.sh    - Reverts ONLY the user-0 package changes actually made by
                  this module (see RESTORATION below).

INSTALL / MIGRATION
-------------------
IMPORTANT: Module ID changed from disable_services_dt2w_mlipay_atrace
(previous v1.0 through v2.2 packages) to disable_services (this release).
KernelSU considers these DIFFERENT modules; in-place upgrade is impossible.

1. Remove the old module "Disable Services" with the legacy ID through
   KernelSU Manager and REBOOT. This allows the old uninstall script to run
   and restores any Tencent state that the old module originally changed.
2. Confirm the old module is gone. Do not keep both IDs installed together.
3. Install this ZIP via KernelSU / KernelSU Next Manager and REBOOT.
4. Check the listed services and package state using the commands below.

Any older standalone DT2W, MLiPay or Vendor ATrace modules should also be
removed or disabled, to avoid conflicts. Older MLiPay modules may modify
/vendor; this module does not repair previous changes to that partition.

The new module reads current package state and records only changes it makes
itself. Manually hidden Tencent packages are left hidden on uninstall.

VERIFY AS ROOT
--------------
cat /sys/touchpanel/double_tap
getprop init.svc.vendor.mlipay-1-1
getprop init.svc.vendor.atrace-hal-1-0
getprop init.svc.soter-1-0
pidof com.tencent.soter.soterserver
dumpsys package com.tencent.soter.soterserver | grep 'User 0:'
cat /data/adb/modules/disable_services/disable_services.log

Expected on a compatible device:
- DT2W is 0.
- Targeted init services report stopped (if the service exists).
- Tencent user 0 state has hidden=true and enabled=3 (unless it was already
  disabled in another state; the module preserves pre-existing disable modes).
- Tencent SoterServer is absent from pidof output after boot (may vary with
  ROM and system state; package controls do not guarantee this universally).
- The module does not alter Tencent state in user 10 or other profiles.

RESTORATION / REMOVAL
---------------------
When the module itself disables an initially enabled Tencent APK, it records
that change and runs pm enable --user 0 during uninstall. When the module
itself hides an initially visible Tencent APK, it records that change and
runs pm unhide --user 0 during uninstall.

IMPORTANT: If the package was already hidden manually before v2.2 was
installed, v2.2 leaves it hidden during uninstall. This preserves the user's
manual settings. To reverse a manual hide, run separately as root:
    pm unhide --user 0 com.tencent.soter.soterserver
To reverse a pre-existing manual disable if desired:
    pm enable --user 0 com.tencent.soter.soterserver
Reboot after removing the module to restore HAL and DT2W boot defaults.

LIMITATIONS / CAUTIONS
----------------------
- The module does not edit /vendor or init scripts; a reflash is not needed
  to restore those files because the module never changes them.
- The SoterServer APK has the SYSTEM PERSISTENT flag on some ROM builds.
  pm hide + pm disable-user worked after reboot in the reported environment,
  but other ROMs might still restart the process. No recurring kill loop runs.
- Disabling Tencent Soter can affect payment, fingerprint/biometric auth,
  and other apps using the Soter security framework.
- The init service names and sysfs node are device and firmware dependent.
- If an older MLiPay module modified /vendor, this module cannot repair it.

TECHNICAL CHANGELOG
-------------------
2.2
- Added pm hide --user 0 for Tencent SoterServer in addition to disable-user.
- Reads user-0 PackageManager state from dumpsys even for a hidden package.
- Removed Tencent SoterServer SIGTERM/SIGKILL process termination fallback.
- Added conditional rollback of package hidden state on module uninstall;
  manually hidden packages remain hidden after module removal.
- Preserves both Tencent state-restore markers across future updates.

2.1
- Added exact process name and user-0 UID validation before sending signals
  to a remaining Tencent SoterServer process.
- Added SIGTERM and SIGKILL fallback with verification and logging.

2.0
- Added soter-1-0 HAL stop and user-0 Tencent SoterServer disable/force-stop.
- Added state-aware package re-enable on uninstall.

1.0
- Combined DT2W, Xiaomi MLiPay and Vendor ATrace service operations.
- Removed unsafe /vendor remount and init .rc renaming from MLiPay handling.

GITHUB / UPDATES
----------------
Author profile: https://github.com/msRedwin
Once the project repository and a hosted update.json file exist, add a working
updateJson=<public URL> property to module.prop for KernelSU Manager updates.
The GitHub profile URL is not itself a valid update.json endpoint.
