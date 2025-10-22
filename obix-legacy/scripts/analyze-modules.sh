#!/bin/bash
# OBIX Module Architecture Analysis Script

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
readonly SRC_DIR="$PROJECT_ROOT/src"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

# Calculate module metrics
analyze_modules() {
    log "Analyzing OBIX module structure..."
    
    local total_modules=0
    local modules_with_index=0
    
    # Analyze core modules
    for module_dir in "$SRC_DIR/core"/*; do
        if [ -d "$module_dir" ]; then
            ((total_modules++))
            local module_name=$(basename "$module_dir")
            
            if [ -f "$module_dir/index.ts" ]; then
                ((modules_with_index++))
                log "✅ Module $module_name has index.ts"
            else
                log "⚠️  Module $module_name missing index.ts"
            fi
        fi
    done
    
    log "Module analysis summary:"
    log "  Total core modules: $total_modules"
    log "  Modules with index.ts: $modules_with_index"
    
    return 0
}

# Main analysis process
main() {
    log "Starting OBIX module analysis..."
    analyze_modules
    log "✅ Module analysis completed"
}

# Execute analysis
main "$@"
