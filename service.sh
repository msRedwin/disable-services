#!/system/bin/sh
# Late-start service: stop selected HALs and apply user-0 Tencent restrictions.
MODDIR=${0%/*}
. "$MODDIR/common.sh"
LOGFILE="$MODDIR/disable_services.log"
{
    log_message '=== service: initial HAL stop, Tencent disable + hide ==='
    stop_selected_services
    disable_tencent_app

    sleep 3
    log_message '=== service: recheck after 3s ==='
    stop_selected_services
    disable_tencent_app

    sleep 7
    log_message '=== service: DT2W + HAL + Tencent check after 10s ==='
    disable_dt2w
    stop_selected_services
    disable_tencent_app

    sleep 20
    log_message '=== service: final HAL + Tencent check after 30s ==='
    stop_selected_services
    disable_tencent_app
    log_message '=== service: finished ==='
} >> "$LOGFILE" 2>&1
exit 0
