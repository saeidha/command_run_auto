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

# گرفتن همه تغییرات (staged + unstaged + untracked)
git add -N .
git diff HEAD --binary > /tmp/last.diff

if [ ! -s /tmp/last.diff ]; then
    echo "❌ No changes to apply."
    exit 0
fi

for target in "${TARGETS[@]}"; do
    echo "🔄 Applying patch to $target"
    cd "$target" || continue
    # اول امتحان با normal apply
    if ! git apply --whitespace=fix /tmp/last.diff; then
        echo "⚠️ Conflict while applying patch to $target"
        continue
    fi
done

echo "✅ Sync complete!"

# اجرای اتومات commit_all.sh
bash "$SCRIPT_DIR/commit_all.sh" "$@" || true

sleep 1  # کمی استراحت برای جلوگیری از فشار
