#!/system/bin/sh
# Boot early: turn DT2W off if the kernel exposes the sysfs node already.
MODDIR=${0%/*}
. "$MODDIR/common.sh"
LOGFILE="$MODDIR/disable_services.log"
{
    log_message '=== post-fs-data: early DT2W ==='
    disable_dt2w
} > "$LOGFILE" 2>&1
exit 0
