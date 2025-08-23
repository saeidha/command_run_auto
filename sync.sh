#!/bin/bash
set -e

# import پروژه‌ها
SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR/projects.sh"

SOURCE=${PROJECT_PATHS[0]}
TARGETS=("${PROJECT_PATHS[@]:1}")

cd "$SOURCE" || exit

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
    if ! git apply --3way --whitespace=fix /tmp/last.diff; then
        echo "⚠️ Conflict while applying patch to $target"
        continue
    fi
done

echo "✅ Sync complete!"

# اجرای اتومات commit_all.sh
bash "/Users/saeid/sh/commit_all.sh" "$@"
