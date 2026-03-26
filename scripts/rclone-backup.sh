#!/bin/bash
set -euo pipefail

USER="ghostik"
USER_ID=$(id -u)

LOCKFILE="/tmp/rclone.lock"
LOGDIR="/home/$USER/logs"
DATE=$(date +%F_%H-%M-%S)

LOGFILE="$LOGDIR/rclone-$DATE.log"
RCLONE_LOGFILE="$LOGDIR/rclone-$DATE-rclone.log"

EXCLUDE="/home/$USER/.config/rclone/exclude.txt"
CONFIG_FILE="/home/$USER/.config/rclone/backup.conf"

DRY_RUN=${DRY_RUN:-false}

SUCCESS_COUNT=0
FAIL_COUNT=0

mkdir -p "$LOGDIR"
exec > >(tee -a "$LOGFILE") 2>&1

# 👇 env для dunst (на случай запуска вне systemd)
export DISPLAY=:0
export XDG_RUNTIME_DIR=/run/user/$USER_ID
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$USER_ID/bus

log() { echo "[MAIN] $(date '+%F %T') | $*"; }

log "========== BACKUP START =========="

# 🔔 уведомление за 30 сек
notify-send -t 30000 "Backup" "Backup will start in 30 seconds"
sleep 30
notify-send -u low "Backup" "Backup has started"

# lock
exec 200>$LOCKFILE
flock -w 10 200 || { log "Another process is running, exiting"; exit 1; }

# проверки
command -v rclone >/dev/null || { log "rclone not found"; exit 1; }

if ! rclone lsd gdrive: >/dev/null 2>&1; then
    log "gdrive not available"
    notify-send -u critical "Backup" "Error: gdrive not available"
    exit 1
fi

# ========================
# функция бэкапа
# ========================
backup_item() {
    local SRC="$1"
    local TARGET="$2"

    if [ ! -e "$SRC" ]; then
        log "Skipped: $SRC not found"
        return
    fi

    log "Processing: $SRC → $TARGET"

    local CMD=(rclone copy "$SRC" "$TARGET"
        --update
        --fast-list
        --no-traverse
        --links
        --log-level INFO
        --log-file "$RCLONE_LOGFILE"
        --transfers 4
        --checkers 4
        --tpslimit 8
        --retries 3
        --low-level-retries 10
        --drive-chunk-size 64M
        --exclude-from "$EXCLUDE"
    )

    $DRY_RUN && CMD+=(--dry-run)

    local START_TS=$(date +%s)

    if "${CMD[@]}"; then
        local END_TS=$(date +%s)
        log "SUCCESS: $SRC → $TARGET ($((END_TS - START_TS))s)"
        SUCCESS_COUNT=$((SUCCESS_COUNT+1))
    else
        log "ERROR: $SRC → $TARGET failed"
        FAIL_COUNT=$((FAIL_COUNT+1))
    fi
}

# ========================
# Чтение конфигурации
# ========================
if [ ! -f "$CONFIG_FILE" ]; then
    log "Config file $CONFIG_FILE not found, exiting"
    notify-send -u critical "Backup" "Error: no backup.conf"
    exit 1
fi

while IFS="=" read -r SRC TARGET; do
    [[ -z "$SRC" || "$SRC" =~ ^# ]] && continue
    backup_item "$SRC" "$TARGET"
done < "$CONFIG_FILE"

# ========================
# Очистка старых логов
# ========================
find "$LOGDIR" -type f -mtime +7 -delete

# ========================
# Итог
# ========================
log "Summary: success=$SUCCESS_COUNT failed=$FAIL_COUNT"

if [ "$FAIL_COUNT" -eq 0 ]; then
    notify-send "Backup" "Backup completed successfully ($SUCCESS_COUNT tasks)"
else
    notify-send -u critical "Backup" "Errors: $FAIL_COUNT"
fi

log "========== BACKUP END =========="
