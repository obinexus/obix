#!/bin/bash
# OBIX Framework Basic Namespace Tree Validation
set -euo pipefail

readonly PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
readonly SRC_DIR="$PROJECT_ROOT/src"

echo "Validating OBIX namespace tree structure..."
echo "Project Root: $PROJECT_ROOT"
echo "Source Directory: $SRC_DIR"

FAIL=0

# Check core namespaces
NAMESPACES=("core" "cli")

for ns in "${NAMESPACES[@]}"; do
    if [ ! -d "$SRC_DIR/$ns" ]; then
        echo "❌ Missing directory: $SRC_DIR/$ns"
        FAIL=1
    else
        echo "✅ Found: @$ns → $SRC_DIR/$ns"
        for dir in $(find "$SRC_DIR/$ns" -type d -maxdepth 1); do
            if [ "$dir" != "$SRC_DIR/$ns" ]; then
                relpath="${dir#"$SRC_DIR/"}"
                echo "  - @${relpath} → $dir"
            fi
        done
    fi
done

exit $FAIL
