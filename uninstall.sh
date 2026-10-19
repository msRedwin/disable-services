#!/system/bin/sh
# Restore only user-0 states changed by this module, not manual user settings.
MODDIR=${0%/*}
PKG=com.tencent.soter.soterserver
if [ -f "$MODDIR/tencent_was_visible" ]; then
    pm unhide --user 0 "$PKG" >/dev/null 2>&1
fi
if [ -f "$MODDIR/tencent_was_enabled" ]; then
    pm enable --user 0 "$PKG" >/dev/null 2>&1
fi
# HAL/DT2W runtime changes naturally reset with reboot.
exit 0
