#!/bin/bash
# OBIX Framework Import Structure Validation Script
# Enhanced with absolute path resolution and namespace enforcement
# Eliminates path ambiguity through concrete directory anchoring

set -eo pipefail

# ABSOLUTE PATH RESOLUTION - Eliminates dangling reference semantics
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Ensure script is run from project root or adjust paths accordingly
if [ ! -d "$SCRIPT_DIR" ] || [ ! -d "$PROJECT_ROOT/src" ]; then
    echo -e "\033[0;31m[ARCHITECTURAL-ERROR]\033[0m [$(date '+%Y-%m-%d %H:%M:%S')] Project source directory not found at $PROJECT_ROOT/src"
    exit 1
fi

# CONCRETE NAMESPACE ANCHORS - Hardcoded absolute path frame of reference
readonly OBIX_SRC_ROOT="$PROJECT_ROOT/src"
readonly OBIX_CORE_ROOT="$PROJECT_ROOT/src/core"
readonly OBIX_CLI_ROOT="$PROJECT_ROOT/src/cli"

# NAMESPACE VALIDATION MAPPINGS - Absolute path enforcement
declare -A NAMESPACE_ABSOLUTE_MAPPINGS=(
    ["@obix"]="$OBIX_SRC_ROOT"
    ["@core"]="$OBIX_CORE_ROOT"
    ["@cli"]="$OBIX_CLI_ROOT"
    ["@core/automaton"]="$OBIX_CORE_ROOT/automaton"
    ["@core/dop"]="$OBIX_CORE_ROOT/dop"
    ["@core/parser"]="$OBIX_CORE_ROOT/parser"
    ["@core/validation"]="$OBIX_CORE_ROOT/validation"
    ["@core/ast"]="$OBIX_CORE_ROOT/ast"
    ["@core/common"]="$OBIX_CORE_ROOT/common"
    ["@core/ioc"]="$OBIX_CORE_ROOT/ioc"
    ["@core/policy"]="$OBIX_CORE_ROOT/policy"
    ["@core/vhtml"]="$OBIX_CORE_ROOT/vhtml"
    ["@core/vcss"]="$OBIX_CORE_ROOT/vcss"
    ["@core/vdom"]="$OBIX_CORE_ROOT/vdom"
    ["@api"]="$OBIX_CORE_ROOT/api"
    ["@parser"]="$OBIX_CORE_ROOT/parser"
    ["@diff"]="$OBIX_CORE_ROOT/diff"
    ["@factory"]="$OBIX_CORE_ROOT/factory"
)

# ANSI color codes for structured diagnostic output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

log_technical() {
    echo -e "${BLUE}[TECHNICAL]${NC} [$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

log_validation_success() {
    echo -e "${GREEN}[VALIDATION-SUCCESS]${NC} [$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

log_compliance_violation() {
    echo -e "${YELLOW}[COMPLIANCE-VIOLATION]${NC} [$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

log_architectural_error() {
    echo -e "${RED}[ARCHITECTURAL-ERROR]${NC} [$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

# NAMESPACE DIRECTORY STRUCTURE VALIDATION
validate_namespace_absolute_paths() {
    log_technical "Validating OBIX namespace absolute path resolution..."
    
    local path_resolution_errors=0
    local validated_namespaces=0
    
    for namespace in "${!NAMESPACE_ABSOLUTE_MAPPINGS[@]}"; do
        local absolute_path="${NAMESPACE_ABSOLUTE_MAPPINGS[$namespace]}"
        
        if [ -d "$absolute_path" ]; then
            log_validation_success "Namespace anchor verified: $namespace → $absolute_path"
            ((validated_namespaces++))
        else
            log_architectural_error "Missing namespace directory: $namespace → $absolute_path"
            ((path_resolution_errors++))
        fi
    done
    
    log_technical "Namespace path resolution summary:"
    log_technical "  Validated namespaces: $validated_namespaces"
    log_technical "  Path resolution errors: $path_resolution_errors"
    
    return $path_resolution_errors
}

# IMPORT PATTERN COMPLIANCE VALIDATION
validate_import_compliance_patterns() {
    log_technical "Executing import pattern compliance validation with absolute path context..."
    
    local total_files=0
    local compliant_files=0
    local violation_files=0
    local critical_violations=0
    
    # Traverse source tree using absolute path anchors
    while IFS= read -r -d '' file; do
        ((total_files++))
        local file_violations=0
        
        # CRITICAL: Detect relative imports crossing module boundaries
        if grep -qE "import.*from.*['\"](\.\./){2,}" "$file" 2>/dev/null; then
            log_compliance_violation "Critical boundary violation detected: ${file#$PROJECT_ROOT/}"
            
            # Extract and report specific violations
            grep -nE "import.*from.*['\"](\.\./){2,}" "$file" | while IFS= read -r violation_line; do
                log_architectural_error "  Line: $violation_line"
            done
            
            ((file_violations++))
            ((critical_violations++))
        fi
        
        # VALIDATION: Check for single-level relative imports (warnings)
        if grep -qE "import.*from.*['\"]\.\./" "$file" 2>/dev/null; then
            local relative_import_count=$(grep -cE "import.*from.*['\"]\.\./" "$file" 2>/dev/null || echo 0)
            if [ "$relative_import_count" -gt 0 ]; then
                log_compliance_violation "Relative imports detected: ${file#$PROJECT_ROOT/} ($relative_import_count occurrences)"
                ((file_violations++))
            fi
        fi
        
        # Classification based on compliance status
        if [ "$file_violations" -eq 0 ]; then
            ((compliant_files++))
        else
            ((violation_files++))
        fi
        
    done < <(find "$OBIX_SRC_ROOT" -name "*.ts" -type f -print0 2>/dev/null || true)
    
    log_technical "Import compliance analysis results:"
    log_technical "  Total TypeScript files analyzed: $total_files"
    log_technical "  Compliant files: $compliant_files"
    log_technical "  Files with violations: $violation_files"
    log_technical "  Critical boundary violations: $critical_violations"
    
    return $critical_violations
}

# ABSTRACT BASE CLASS DETECTION AND FLAGGING
detect_abstract_base_classes() {
    log_technical "Scanning for abstract base class inheritance violations..."
    
    local base_class_count=0
    local abstract_violations=()
    
    # Scan for Base*.ts pattern files
    while IFS= read -r -d '' base_file; do
        ((base_class_count++))
        local relative_path="${base_file#$PROJECT_ROOT/}"
        abstract_violations+=("$relative_path")
        log_compliance_violation "Abstract base class detected: $relative_path"
    done < <(find "$OBIX_SRC_ROOT" -name "Base*.ts" -type f -print0 2>/dev/null || true)
    
    # Additional scan for abstract interface patterns
    while IFS= read -r -d '' abstract_file; do
        if grep -q "abstract class\|interface.*extends" "$abstract_file" 2>/dev/null; then
            local relative_path="${abstract_file#$PROJECT_ROOT/}"
            if [[ ! " ${abstract_violations[@]} " =~ " ${relative_path} " ]]; then
                abstract_violations+=("$relative_path")
                log_compliance_violation "Abstract inheritance pattern detected: $relative_path"
                ((base_class_count++))
            fi
        fi
    done < <(find "$OBIX_SRC_ROOT" -name "*.ts" -type f -print0 2>/dev/null || true)
    
    log_technical "Abstract base class analysis summary:"
    log_technical "  Total abstract violations detected: $base_class_count"
    
    if [ $base_class_count -gt 0 ]; then
        log_architectural_error "ARCHITECTURAL VIOLATION: Abstract base classes contradict single-pass concrete implementation requirements"
        log_technical "Recommended action: Migrate abstract classes to concrete implementations"
    else
        log_validation_success "No abstract base class violations detected"
    fi
    
    return $base_class_count
}

# COMPREHENSIVE VALIDATION ORCHESTRATION
execute_comprehensive_validation() {
    log_technical "Initiating comprehensive OBIX framework validation with absolute path resolution..."
    
    local total_validation_errors=0
    
    # Execute validation phases with error accumulation
    validate_namespace_absolute_paths || ((total_validation_errors += $?))
    validate_import_compliance_patterns || ((total_validation_errors += $?))
    detect_abstract_base_classes || ((total_validation_errors += $?))
    
    # Final validation assessment
    if [ "$total_validation_errors" -eq 0 ]; then
        log_validation_success "OBIX framework validation completed successfully"
        log_technical "All namespace paths resolved correctly with concrete implementation architecture verified"
        return 0
    else
        log_architectural_error "OBIX framework validation failed with $total_validation_errors critical architectural violations"
        log_technical "Systematic remediation required before proceeding with development workflow"
        return 1
    fi
}

# USAGE INFORMATION
show_technical_usage() {
    cat << 'EOF'
OBIX Framework Enhanced Validation Tool
======================================

Technical Specifications:
- Absolute path resolution eliminates relative path ambiguity
- Concrete namespace anchoring prevents dangling reference behavior
- Abstract base class detection enforces single-pass architecture
- Comprehensive compliance validation with detailed diagnostics

Usage: bash scripts/validate-imports.sh

Validation Phases:
1. Namespace absolute path verification
2. Import pattern compliance analysis  
3. Abstract base class architectural validation

Integration: Designed for waterfall methodology compliance validation
EOF
}

# COMMAND LINE INTERFACE
case "${1:-}" in
    --help|-h|help)
        show_technical_usage
        exit 0
        ;;
    *)
        execute_comprehensive_validation
        exit $?
        ;;
esac
