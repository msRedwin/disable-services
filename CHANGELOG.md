# Technical changelog

## v2.2
- Added `pm hide --user 0` to Tencent SoterServer controls.
- Read PackageManager state through `dumpsys package` even when hidden.
- Removed the Tencent SIGTERM/SIGKILL fallback.
- Preserved pre-existing manual package state and added conditional unhide on uninstall.
- Changed the module ID to `disable_services` (remove the previous module and reboot before installation).

## v2.1
- Added verified user-0 PID handling and SIGTERM/SIGKILL fallback for Tencent SoterServer.

## v2.0
- Added `soter-1-0` HAL stop and APK disable/force-stop for user 0.
- Added conditional restoration of the APK on uninstall.

## v1.0
- Combined DT2W, MLiPay and Vendor ATrace controls.
- Removed `/vendor` remounting and `.rc` renaming from MLiPay shutdown.
