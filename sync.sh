#!/bin/bash
set -euo pipefail

LOCK_FILE="/tmp/sync.lock"

# --- جلوگیری از اجرای همزمان ---
if [ -f "$LOCK_FILE" ]; then
    echo "⏳ Sync already running, skipping this trigger."
    exit 0
fi
trap "rm -f $LOCK_FILE" EXIT
touch "$LOCK_FILE"

# import پروژه‌ها
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/projects.sh"

SOURCE=${PROJECT_PATHS[0]}
TARGETS=("${PROJECT_PATHS[@]:1}")

cd "$SOURCE" || exit 1

# چک تغییرات
if git diff --quiet && git diff --cached --quiet; then
    echo "❌ No changes to apply."
    exit 0
fi

# فایل‌های تغییر یافته رو پیدا کن
CHANGED_FILES=$(git status --porcelain | awk '{print $2}')

if [ -z "$CHANGED_FILES" ]; then
    echo "❌ No changes to sync."
    exit 0
fi

for target in "${TARGETS[@]}"; do
    echo "🔄 Syncing changes to $target"
    for file in $CHANGED_FILES; do
        if [ -f "$SOURCE/$file" ]; then
            mkdir -p "$(dirname "$target/$file")"
            rsync -a "$SOURCE/$file" "$target/$file"
        fi
    done
done

echo "✅ Sync complete!"

# اجرای اتومات commit_all.sh
bash "$SCRIPT_DIR/commit_all.sh" "$@" || true

sleep 1
