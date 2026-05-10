#!/usr/bin/env bash
set -euo pipefail

# =========================================================
# CONFIG
# =========================================================

BASE_DIR="$HOME/backup"
CONFIG_FILE="$BASE_DIR/backup.conf"

[[ -f "$CONFIG_FILE" ]] || exit 1
source "$CONFIG_FILE"

mkdir -p "$TEMP_DIR" "$LOG_DIR"

# =========================================================
# LOG
# =========================================================

DATE="$(date '+%Y-%m-%d_%H-%M-%S')"
LOG_FILE="$LOG_DIR/backup_$DATE.log"

log() {
    echo "[$(date '+%F %T')] $*" | tee -a "$LOG_FILE"
}

# =========================================================
# EXIT STATUS
# =========================================================

EXIT_CODE=0

on_exit() {
    local code=$?

    if [[ $code -eq 0 && $EXIT_CODE -eq 0 ]]; then
        log "Backup finished: SUCCESS"
    else
        log "Backup finished: FAILED (exit=$code)"
    fi

    exit $code
}

trap on_exit EXIT

# =========================================================
# EXCLUDES
# =========================================================

EXCLUDES=()
EXCLUDE_FILE="$BASE_DIR/exclude.txt"

if [[ -f "$EXCLUDE_FILE" ]]; then
    while read -r line; do
        [[ -z "$line" || "$line" == \#* ]] && continue
        EXCLUDES+=(--exclude="$line")
    done < "$EXCLUDE_FILE"
fi

# =========================================================
# SAFE RUN
# =========================================================

run_safe() {
    "$@" || EXIT_CODE=1
}

# =========================================================
# ARCHIVE
# =========================================================

archive() {
    local src="$1"

    [[ -d "$src" ]] || return 0

    local name archive_file
    name="$(basename "$src")"

    archive_file="$TEMP_DIR/${name}_${DATE}.tar.zst"

    log "ARCHIVE: $src"

    tar "${EXCLUDES[@]}" -cf - -C "$(dirname "$src")" "$name" \
        | zstd -T0 -6 -o "$archive_file"

    log "UPLOAD ARCHIVE: $archive_file"

    rclone copy "$archive_file" "$REMOTE:$REMOTE_DIR/archive/" \
        --log-file "$LOG_FILE"

    rm -f "$archive_file"
}

# =========================================================
# SYNC (mirror)
# =========================================================

sync_folder() {
    local src="$1"

    [[ -d "$src" ]] || return 0

    local name
    name="$(basename "$src")"

    log "SYNC: $src"

    rclone sync "$src" "$REMOTE:$REMOTE_DIR/sync/$name" \
        --log-file "$LOG_FILE"
}

# =========================================================
# COPY (NO DELETE + ALWAYS CREATE FOLDER)
# =========================================================

copy_folder() {
    local src="$1"

    [[ -d "$src" ]] || return 0

    local name
    name="$(basename "$src")"

    log "COPY: $src"

    # ВАЖНО: force-empty-dir + explicit directory creation behaviour
    rclone copy "$src" "$REMOTE:$REMOTE_DIR/copy/$name" \
        --create-empty-src-dirs \
        --log-file "$LOG_FILE"
}

# =========================================================
# RUN
# =========================================================

log "Backup started"

for p in "${ARCHIVE_PATHS[@]}"; do
    run_safe archive "$p"
done

for p in "${SYNC_PATHS[@]}"; do
    run_safe sync_folder "$p"
done

for p in "${COPY_PATHS[@]}"; do
    run_safe copy_folder "$p"
done
