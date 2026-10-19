#!/system/bin/sh
# KernelSU / KernelSU Next installer for the new permanent module ID.
ui_print '- Disable Services v2.2: DT2W, MLiPay, Tencent Soter, Vendor ATrace'
ui_print '- No changes to /vendor files; WebUI is not included.'
LEGACY_MOD=/data/adb/modules/disable_services_dt2w_mlipay_atrace
if [ -d "$LEGACY_MOD" ]; then
    abort '! Previous module ID is still installed. Remove the old Disable Services module, reboot, then install this ZIP.'
fi
set_perm "$MODPATH/module.prop" 0 0 0644
set_perm "$MODPATH/common.sh" 0 0 0644
set_perm "$MODPATH/README.txt" 0 0 0644
set_perm "$MODPATH/background.png" 0 0 0644
set_perm "$MODPATH/icon.png" 0 0 0644
set_perm "$MODPATH/post-fs-data.sh" 0 0 0755
set_perm "$MODPATH/service.sh" 0 0 0755
set_perm "$MODPATH/action.sh" 0 0 0755
set_perm "$MODPATH/uninstall.sh" 0 0 0755
