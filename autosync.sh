#!/bin/bash
# autosync.sh
set -e

SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR/projects.sh"

SOURCE=${PROJECT_PATHS[0]}

echo "👀 Watching $SOURCE for changes..."
fswatch -o "$SOURCE" | while read -r event; do
    echo "🔄 Change detected in $SOURCE → running sync..."
    bash "$SCRIPT_DIR/sync.sh"
done
