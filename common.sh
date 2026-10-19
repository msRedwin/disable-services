#!/system/bin/sh
# KernelSU / KernelSU Next shared functions. Never modify /vendor files.

DT2W_NODE=${DT2W_NODE:-/sys/touchpanel/double_tap}
TENCENT_PACKAGE=com.tencent.soter.soterserver
TENCENT_ENABLE_RESTORE_FLAG="$MODDIR/tencent_was_enabled"
TENCENT_UNHIDE_RESTORE_FLAG="$MODDIR/tencent_was_visible"

log_message() {
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

disable_dt2w() {
    if [ ! -e "$DT2W_NODE" ]; then
        log_message "DT2W: sysfs node not found: $DT2W_NODE"
        return 0
    fi
    if ( printf '0\n' > "$DT2W_NODE" ) 2>/dev/null; then
        current=$(cat "$DT2W_NODE" 2>/dev/null)
        log_message "DT2W: wrote 0; current=${current:-unknown}"
    else
        log_message "DT2W: FAILED to write 0 to $DT2W_NODE"
        return 1
    fi
}

stop_init_service() {
    svc="$1"
    before=$(getprop "init.svc.$svc" 2>/dev/null)
    setprop ctl.stop "$svc" >/dev/null 2>&1
    rc=$?
    after=$(getprop "init.svc.$svc" 2>/dev/null)
    log_message "init $svc: before=${before:-absent/unknown} after=${after:-absent/unknown} ctl.stop_rc=$rc"
}

stop_selected_services() {
    stop_init_service 'vendor.mlipay-1-1'
    stop_init_service 'mlipay-1-1'
    if command -v pidof >/dev/null 2>&1 && pidof mlipayd@1.1 >/dev/null 2>&1; then
        if command -v killall >/dev/null 2>&1; then
            killall mlipayd@1.1 >/dev/null 2>&1
            log_message 'MLiPay: signaled process mlipayd@1.1'
        else
            log_message 'MLiPay: killall not available'
        fi
    fi
    stop_init_service 'vendor.atrace-hal-1-0'
    stop_init_service 'soter-1-0'
}

# Parse user 0 from dumpsys. Unlike 'pm list packages --user 0', this still
# discovers a package after 'pm hide --user 0' has hidden it.
tencent_user0_line() {
    command -v dumpsys >/dev/null 2>&1 || return 1
    dumpsys package "$TENCENT_PACKAGE" 2>/dev/null |
        awk '$1 == "User" && $2 == "0:" && /installed=/{print; exit}'
}

# Extract one literal field from a dumpsys user-state line.
tencent_field() {
    field_key="$1"
    field_line="$2"
    for field_token in $field_line; do
        case "$field_token" in
            "$field_key"=*) printf '%s\n' "${field_token#*=}"; return 0 ;;
        esac
    done
    return 1
}

# Hide the Soter APK for Android user 0; unlike disable-user alone, this
# prevented its PERSISTENT process from coming back on the tested device.
# Existing user choices are preserved across module removal.
disable_tencent_app() {
    if ! command -v pm >/dev/null 2>&1; then
        log_message 'Tencent APK: PackageManager not available'
        return 1
    fi
    user_line=$(tencent_user0_line)
    if [ -z "$user_line" ]; then
        log_message 'Tencent APK: user-0 package state not available; retry later'
        return 1
    fi
    installed=$(tencent_field installed "$user_line")
    enabled=$(tencent_field enabled "$user_line")
    hidden=$(tencent_field hidden "$user_line")
    if [ "$installed" != true ]; then
        log_message 'Tencent APK: package not installed for user 0; skipped'
        return 1
    fi

    case "$enabled" in
        0|1)
            pm disable-user --user 0 "$TENCENT_PACKAGE" >/dev/null 2>&1
            rc=$?
            check_line=$(tencent_user0_line)
            check_enabled=$(tencent_field enabled "$check_line")
            if [ "$rc" -eq 0 ] && [ "$check_enabled" = 3 ]; then
                : > "$TENCENT_ENABLE_RESTORE_FLAG"
                log_message 'Tencent APK: disabled for user 0; original enabled state recorded'
            else
                log_message "Tencent APK: disable-user FAILED; rc=$rc enabled=${check_enabled:-unknown}"
                return 1
            fi
            ;;
        2|3|4)
            log_message "Tencent APK: user-0 package already disabled (enabled=$enabled)"
            ;;
        *)
            log_message "Tencent APK: unknown enabled state: ${enabled:-missing}; skipped"
            return 1
            ;;
    esac

    case "$hidden" in
        false)
            pm hide --user 0 "$TENCENT_PACKAGE" >/dev/null 2>&1
            rc=$?
            check_line=$(tencent_user0_line)
            check_hidden=$(tencent_field hidden "$check_line")
            if [ "$rc" -eq 0 ] && [ "$check_hidden" = true ]; then
                : > "$TENCENT_UNHIDE_RESTORE_FLAG"
                log_message 'Tencent APK: hidden for user 0; original visible state recorded'
            else
                log_message "Tencent APK: hide FAILED; rc=$rc hidden=${check_hidden:-unknown}"
                return 1
            fi
            ;;
        true)
            log_message 'Tencent APK: already hidden for user 0; previous setting preserved'
            ;;
        *)
            log_message "Tencent APK: unknown hidden state: ${hidden:-missing}; skipped"
            return 1
            ;;
    esac

    if command -v am >/dev/null 2>&1; then
        am force-stop --user 0 "$TENCENT_PACKAGE" >/dev/null 2>&1
        rc=$?
        log_message "Tencent APK: force-stop rc=$rc"
    else
        log_message 'Tencent APK: am not available'
    fi

    if command -v pidof >/dev/null 2>&1; then
        remaining=$(pidof "$TENCENT_PACKAGE" 2>/dev/null)
        if [ -n "$remaining" ]; then
            log_message "Tencent APK: process currently present (PID $remaining); no kill loop"
        else
            log_message 'Tencent APK: process absent at check time'
        fi
    fi
}
