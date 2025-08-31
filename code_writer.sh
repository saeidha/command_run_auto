#!/bin/bash
set -e

# --- Arguments ---
SRC_FILE="$1"         # Source file to read from
DEST_FILE="$2"        # Destination file to append to
MIN_LINES="$3"        # Minimum number of lines per chunk
MAX_LINES="$4"        # Maximum number of lines per chunk
MIN_SLEEP="$5"        # Minimum seconds to sleep (can be float)
MAX_SLEEP="$6"        # Maximum seconds to sleep (can be float)

# --- Validation ---
if [ $# -lt 6 ]; then
  echo "❌ Usage: $0 <source_file> <dest_file> <min_lines> <max_lines> <min_sleep> <max_sleep>"
  exit 1
fi

if [ ! -f "$SRC_FILE" ]; then
  echo "❌ Source file not found: $SRC_FILE"
  exit 1
fi

# --- Main ---
TOTAL_LINES=$(wc -l < "$SRC_FILE")
CURRENT_LINE=1

echo "📄 Starting append from $SRC_FILE → $DEST_FILE"
echo "   Writing between $MIN_LINES–$MAX_LINES lines per step"
echo "   Sleeping between $MIN_SLEEP–$MAX_SLEEP seconds"

while [ "$CURRENT_LINE" -le "$TOTAL_LINES" ]; do
  # Random number of lines
  NUM_LINES=$(shuf -i "$MIN_LINES"-"$MAX_LINES" -n 1)

  # Extract lines and append
  sed -n "${CURRENT_LINE},$((CURRENT_LINE + NUM_LINES - 1))p" "$SRC_FILE" >> "$DEST_FILE"

  echo "✍️  Appended lines $CURRENT_LINE–$((CURRENT_LINE + NUM_LINES - 1))"

  CURRENT_LINE=$((CURRENT_LINE + NUM_LINES))

  # Random sleep
  SLEEP_TIME=$(awk -v min="$MIN_SLEEP" -v max="$MAX_SLEEP" 'BEGIN{srand(); print min+rand()*(max-min)}')
  echo "⏳ Sleeping for $SLEEP_TIME seconds..."
  sleep "$SLEEP_TIME"
done

echo "✅ Done appending file!"

# -------------------------
# 📖 Usage Guide (English)
# -------------------------
# This script reads a source file and writes its content into a destination file
# in random chunks of lines, appending instead of overwriting.
#
# Example:
#   ./sample.sh source.sol destination.sol 2 4 1.5 3.5
#
# This means:
# - Read from "source.sol"
# - Append content into "destination.sol"
# - Each step will write between 2–4 random lines
# - Wait between 1.5–3.5 seconds before writing the next chunk
#
# ⚠️ Important: The destination file will keep growing since it appends.
