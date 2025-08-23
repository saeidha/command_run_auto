#!/bin/bash
set -e

# import پروژه‌ها
source "$(dirname "$0")/projects.sh"

COMMIT_MESSAGE=$1

# --- بخش ۱: تعیین پیام کامیت ---
if [ -z "$COMMIT_MESSAGE" ]; then
    echo "🔍 No commit message provided. Generating one automatically..."

    FIRST_PROJECT_PATH=${PROJECT_PATHS[0]}
    cd "$FIRST_PROJECT_PATH" || exit

    FIRST_CHANGED_FILE=$(git status --porcelain | head -n 1 | awk '{print $2}')

    if [ -z "$FIRST_CHANGED_FILE" ]; then
        echo "❌ No changes found. Aborting."
        exit 1
    fi

    WORDS=(
        "Enhancement" "Adjustment" "Revision" "Improvement" "Correction" 
        "Fix" "Feature" "Addition" "Optimization" "Refactor" "Cleanup" 
        "Implementation" "Verification" "Security" "Access" "Control" 
        "Logic" "State" "Function" "Interface" "Event" "Handling" 
        "Efficiency" "Upgrade" "Standard" "Module" "Component" "Protocol"
    )

    RANDOM_WORD=${WORDS[$((RANDOM % ${#WORDS[@]}))]}
    COMMIT_MESSAGE="change on $FIRST_CHANGED_FILE Solidity contract $RANDOM_WORD"
    
    echo "✨ Generated message: \"$COMMIT_MESSAGE\""
fi

echo "--------------------------------"

# --- بخش ۲: اضافه کردن و کامیت کردن در تمام پروژه‌ها ---
for project_path in "${PROJECT_PATHS[@]}"; do
    echo "📦 Processing project: $project_path"
    cd "$project_path" || continue
    git add .
    git commit -m "$COMMIT_MESSAGE" || echo "⚠️ Nothing to commit in $project_path"
    echo "--------------------------------"
done

echo "✅ All projects have been committed successfully!"
