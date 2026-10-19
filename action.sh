#!/system/bin/sh
# Action button: reapply operations and print the combined log.
MODDIR=${0%/*}
. "$MODDIR/common.sh"
LOGFILE="$MODDIR/disable_services.log"
{
    log_message '=== action: manual reapply ==='
    disable_dt2w
    stop_selected_services
    disable_tencent_app
    log_message '=== action: finished ==='
} >> "$LOGFILE" 2>&1
cat "$LOGFILE"
