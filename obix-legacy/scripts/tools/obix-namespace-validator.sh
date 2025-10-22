#!/bin/bash
# OBIX Framework Namespace Validation and Enforcement System
set -euo pipefail

readonly PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
readonly SRC_DIR="$PROJECT_ROOT/src"
readonly VALIDATION_LOG="$PROJECT_ROOT/validation-report.log"

# ANSI color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*" | tee -a "$VALIDATION_LOG"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*" | tee -a "$VALIDATION_LOG"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*" | tee -a "$VALIDATION_LOG"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" | tee -a "$VALIDATION_LOG"
}

# Initialize validation report
initialize_validation_report() {
    echo "OBIX Framework Namespace Validation Report" > "$VALIDATION_LOG"
    echo "Generated: $(date)" >> "$VALIDATION_LOG"
    echo "Project: Nnamdi Okpala's OBIX Framework" >> "$VALIDATION_LOG"
    echo "=========================================" >> "$VALIDATION_LOG"
    echo "" >> "$VALIDATION_LOG"
}

# Validate import patterns
validate_import_patterns() {
    log_info "Analyzing import patterns for namespace compliance..."
    
    local total_files=0
    local compliant_files=0
    local violation_files=0
    local critical_violations=0
    
    while IFS= read -r -d '' file; do
        ((total_files++))
        local file_violations=0
        
        if grep -qE "import.*from.*['\"](\.\./){2,}" "$file" 2>/dev/null; then
            log_error "Critical boundary violation in: ${file#$PROJECT_ROOT/}"
            ((file_violations++))
            ((critical_violations++))
        fi
        
        if [ "$file_violations" -eq 0 ]; then
            ((compliant_files++))
        else
            ((violation_files++))
        fi
        
    done < <(find "$SRC_DIR" -name "*.ts" -type f -print0 2>/dev/null || true)
    
    log_info "Import pattern analysis complete:"
    log_info "  Total files analyzed: $total_files"
    log_info "  Compliant files: $compliant_files"
    log_info "  Files with violations: $violation_files"
    log_info "  Critical violations: $critical_violations"
    
    return $critical_violations
}

# Main validation
main() {
    log_info "Starting OBIX Framework namespace validation..."
    
    initialize_validation_report
    
    local total_errors=0
    validate_import_patterns || ((total_errors += $?))
    
    if [ "$total_errors" -eq 0 ]; then
        log_success "OBIX framework namespace validation completed successfully"
        exit 0
    else
        log_error "OBIX framework validation failed with $total_errors critical issues"
        exit 1
    fi
}

case "${1:-}" in
    --help|-h)
        echo "OBIX Framework Namespace Validation Tool"
        echo "Usage: $0 [--help]"
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac
