#!/bin/bash
# autosync.sh
# اجرا کردن sync.sh هر ۲ ثانیه

SCRIPT_DIR=$(dirname "$0")
SYNC_SCRIPT="$SCRIPT_DIR/sync.sh"

echo "🚀 Starting auto-sync every 2 seconds..."
while true; do
    echo "⏱ $(date '+%H:%M:%S') - Running sync..."
    bash "$SYNC_SCRIPT"
    sleep 2
done
