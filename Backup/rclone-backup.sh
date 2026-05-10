#!/usr/bin/env bash
set -Euo pipefail
IFS=$'\n\t'

# =========================
# BASE
# =========================

BASE_DIR="$HOME/Backup"
CONFIG_FILE="$BASE_DIR/backup.conf"
EXCLUDE_FILE="$BASE_DIR/exclude.txt"

[[ -f "$CONFIG_FILE" ]] || {
    echo "[ERROR] Missing config: $CONFIG_FILE"
    exit 1
}

# shellcheck disable=SC1090
source "$CONFIG_FILE"

: "${REMOTE:?REMOTE not set}"
: "${REMOTE_DIR:?REMOTE_DIR not set}"
: "${TEMP_DIR:?TEMP_DIR not set}"
: "${LOG_DIR:?LOG_DIR not set}"
: "${TRANSFERS:=4}"
: "${CHECKERS:=8}"
: "${KEEP_ARCHIVES:=30}"
: "${MAX_JOBS:=3}"

DATE="$(date '+%Y-%m-%d_%H-%M-%S')"

mkdir -p "$TEMP_DIR" "$LOG_DIR"

LOG_FILE="$LOG_DIR/backup_$DATE.log"
SUMMARY_FILE="$LOG_DIR/summary.log"

# =========================
# LOGGING
# =========================

log() {
    echo "[$(date '+%F %T')] $*" | tee -a "$LOG_FILE"
}

log_info()  { log "[INFO] $*"; }
log_warn()  { log "[WARN] $*"; }
log_error() { log "[ERROR] $*"; }

# =========================
# PROCESS TRACKING
# =========================

PIDS=()
EXIT_OK=0

cleanup() {
    [[ "${EXIT_OK:-0}" -eq 1 ]] && return 0

    log_warn "Cleanup triggered (abnormal exit)"

    for pid in "${PIDS[@]:-}"; do
        kill -TERM "$pid" 2>/dev/null || true
    done

    rm -f "$TEMP_DIR"/*.tar.zst 2>/dev/null || true
}

trap cleanup INT TERM

# =========================
# CHECK SPACE
# =========================

check_free_space() {
    local available
    available=$(df --output=avail "$HOME" | tail -1)

    local min=10485760 # 10GB

    if (( available < min )); then
        log_error "Not enough disk space"
        exit 1
    fi
}

check_free_space

# =========================
# EXCLUDES
# =========================

TAR_EXCLUDES=()

if [[ -f "$EXCLUDE_FILE" ]]; then
    while IFS= read -r line; do
        [[ -z "$line" || "$line" == \#* ]] && continue
        TAR_EXCLUDES+=(--exclude="$line")
    done < "$EXCLUDE_FILE"
fi

# =========================
# ARCHIVE FUNCTION
# =========================

archive_folder() {
    local SRC="$1"

    [[ -d "$SRC" ]] || {
        log_warn "Missing $SRC"
        return
    }

    local NAME
    NAME="$(basename -- "$SRC")"

    local ARCHIVE="$TEMP_DIR/${NAME}_${DATE}.tar.zst"

    log_info "Archiving $SRC"

    tar \
        "${TAR_EXCLUDES[@]}" \
        --warning=no-file-changed \
        -cf - \
        -C "$(dirname "$SRC")" \
        "$NAME" \
        | zstd -T0 -6 -o "$ARCHIVE"

    log_info "Uploading $ARCHIVE"

    rclone copy \
        "$ARCHIVE" \
        "$REMOTE:$REMOTE_DIR/archive/" \
        --transfers="$TRANSFERS" \
        --checkers="$CHECKERS" \
        --fast-list \
        --stats 30s \
        --stats-one-line \
        --log-level INFO \
        --log-file "$LOG_FILE"

    rm -f "$ARCHIVE"
}

# =========================
# SYNC FUNCTION
# =========================

sync_folder() {
    local SRC="$1"

    [[ -d "$SRC" ]] || {
        log_warn "Missing $SRC"
        return
    }

    local NAME
    NAME="$(basename -- "$SRC")"

    log_info "Syncing $SRC"

    rclone sync \
        "$SRC" \
        "$REMOTE:$REMOTE_DIR/sync/$NAME" \
        --transfers="$TRANSFERS" \
        --checkers="$CHECKERS" \
        --fast-list \
        --multi-thread-streams 4 \
        --stats 30s \
        --stats-one-line \
        --log-level INFO \
        --log-file "$LOG_FILE"
}

# =========================
# ARCHIVE POOL (SAFE PARALLEL)
# =========================

archive_all() {
    local running=0

    for p in "${ARCHIVE_PATHS[@]}"; do
        archive_folder "$p" &
        pid=$!
        PIDS+=("$pid")

        ((running++))

        if (( running >= MAX_JOBS )); then
            wait -n
            ((running--))
        fi
    done

    wait
}

# =========================
# SYNC ALL
# =========================

sync_all() {
    for p in "${SYNC_PATHS[@]}"; do
        sync_folder "$p"
    done
}

# =========================
# RETENTION (SAFE)
# =========================

cleanup_old_archives() {
    log_info "Retention cleanup (keep last $KEEP_ARCHIVES days)"

    rclone delete "$REMOTE:$REMOTE_DIR/archive/" \
        --min-age "${KEEP_ARCHIVES}d" \
        --include "*.tar.zst" \
        --log-level INFO \
        --log-file "$LOG_FILE"
}

# =========================
# SUMMARY
# =========================

summary() {
    echo "[$(date)] backup done ($DATE)" >> "$SUMMARY_FILE"

    log_info "=== SUMMARY ==="
    log_info "Archives: ${#ARCHIVE_PATHS[@]}"
    log_info "Syncs:    ${#SYNC_PATHS[@]}"
    log_info "Date:     $DATE"
}

# =========================
# MAIN
# =========================

main() {
    log_info "Backup started"

    archive_all
    sync_all
    cleanup_old_archives
    summary

    log_info "DONE"

    EXIT_OK=1
}

main
