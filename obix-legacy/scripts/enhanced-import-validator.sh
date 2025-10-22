#!/bin/bash

# OBINexus Enhanced Import Validation Framework
# Precision regex matching with false positive/negative mitigation
# Addresses specific architectural boundary enforcement

set -euo pipefail

# Advanced regex patterns for precise matching
declare -A IMPORT_PATTERNS=(
    # Core module patterns with positive/negative lookahead
    ["CORE_AUTOMATON"]='import\s+.*\s+from\s+['\''"][.]{1,2}\/.*automaton(?!.*node_modules).*['\''"];?'
    ["CORE_DOP"]='import\s+.*\s+from\s+['\''"][.]{1,2}\/.*dop(?!.*node_modules).*['\''"];?'
    ["CORE_PARSER"]='import\s+.*\s+from\s+['\''"][.]{1,2}\/.*parser(?!.*node_modules).*['\''"];?'
    ["CORE_VALIDATION"]='import\s+.*\s+from\s+['\''"][.]{1,2}\/.*validation(?!.*node_modules).*['\''"];?'
    ["CORE_AST"]='import\s+.*\s+from\s+['\''"][.]{1,2}\/.*ast(?!.*node_modules).*['\''"];?'
    ["CORE_IOC"]='import\s+.*\s+from\s+['\''"][.]{1,2}\/.*ioc(?!.*node_modules).*['\''"];?'
    ["CORE_POLICY"]='import\s+.*\s+from\s+['\''"][.]{1,2}\/.*policy(?!.*node_modules).*['\''"];?'
    
    # CLI module patterns
    ["CLI_ANALYZER"]='import\s+.*\s+from\s+['\''"][.]{1,2}\/.*analyzer(?!.*node_modules).*['\''"];?'
    ["CLI_BUNDLER"]='import\s+.*\s+from\s+['\''"][.]{1,2}\/.*bundler(?!.*node_modules).*['\''"];?'
    ["CLI_CACHE"]='import\s+.*\s+from\s+['\''"][.]{1,2}\/.*cache(?!.*node_modules).*['\''"];?'
    ["CLI_COMPILER"]='import\s+.*\s+from\s+['\''"][.]{1,2}\/.*compiler(?!.*node_modules).*['\''"];?'
    ["CLI_MINIFIER"]='import\s+.*\s+from\s+['\''"][.]{1,2}\/.*minifier(?!.*node_modules).*['\''"];?'
    ["CLI_COMMAND"]='import\s+.*\s+from\s+['\''"][.]{1,2}\/.*command(?!.*node_modules).*['\''"];?'
    
    # Legacy boundary violations
    ["LEGACY_DOP"]='import\s+.*\s+from\s+['\''"].*old\/dop.*['\''"];?'
    ["ERROR_TRACKER"]='import\s+.*\s+from\s+['\''"][.]{1,2}\/.*ErrorTracker['\''"];?'
    
    # Generic relative imports (catch-all with exclusions)
    ["GENERIC_RELATIVE"]='import\s+.*\s+from\s+['\''"][.]{1,2}\/(?!.*node_modules)(?!.*\.d\.ts).*['\''"];?'
)

# Replacement patterns mapped to path mappings
declare -A REPLACEMENT_PATTERNS=(
    ["CORE_AUTOMATON"]='@core/automaton/'
    ["CORE_DOP"]='@core/dop/'
    ["CORE_PARSER"]='@core/parser/'
    ["CORE_VALIDATION"]='@core/validation/'
    ["CORE_AST"]='@core/ast/'
    ["CORE_IOC"]='@core/ioc/'
    ["CORE_POLICY"]='@core/policy/'
    ["CLI_ANALYZER"]='@cli/analyzer/'
    ["CLI_BUNDLER"]='@cli/bundler/'
    ["CLI_CACHE"]='@cli/cache/'
    ["CLI_COMPILER"]='@cli/compiler/'
    ["CLI_MINIFIER"]='@cli/minifier/'
    ["CLI_COMMAND"]='@cli/command/'
)

# Validation functions
validate_import_pattern() {
    local file="$1"
    local pattern_name="$2"
    local pattern="${IMPORT_PATTERNS[$pattern_name]}"
    
    # Use grep -P for Perl-compatible regex with proper lookaheads
    if grep -P "$pattern" "$file" >/dev/null 2>&1; then
        return 0  # Pattern found
    else
        return 1  # Pattern not found
    fi
}

# Precise import transformation with context awareness
transform_import_with_context() {
    local file="$1"
    local original_import="$2"
    local target_module="$3"
    
    # Extract relative path and convert to absolute
    local relative_path
    relative_path=$(echo "$original_import" | grep -oP "(?<=from\s['\"])[^'\"]+")
    
    # Determine target absolute path based on file context
    local file_dir
    file_dir=$(dirname "$file")
    
    # Calculate absolute target based on file location and relative path
    local absolute_target
    if [[ "$file_dir" == *"/cli/"* ]]; then
        # CLI context
        absolute_target=$(resolve_cli_path "$relative_path" "$file_dir")
    elif [[ "$file_dir" == *"/core/"* ]]; then
        # Core context  
        absolute_target=$(resolve_core_path "$relative_path" "$file_dir")
    else
        # Fallback context
        absolute_target="@${target_module}/${relative_path#*/}"
    fi
    
    echo "$absolute_target"
}

# CLI path resolution with module awareness
resolve_cli_path() {
    local relative_path="$1"
    local current_dir="$2"
    
    # Remove leading ./ and ../
    local clean_path="${relative_path#./}"
    clean_path="${clean_path#../}"
    
    # Detect target CLI module
    if [[ "$clean_path" == *"analyzer"* ]]; then
        echo "@cli/analyzer/${clean_path#*analyzer/}"
    elif [[ "$clean_path" == *"bundler"* ]]; then
        echo "@cli/bundler/${clean_path#*bundler/}"
    elif [[ "$clean_path" == *"cache"* ]]; then
        echo "@cli/cache/${clean_path#*cache/}"
    elif [[ "$clean_path" == *"compiler"* ]]; then
        echo "@cli/compiler/${clean_path#*compiler/}"
    elif [[ "$clean_path" == *"minifier"* ]]; then
        echo "@cli/minifier/${clean_path#*minifier/}"
    elif [[ "$clean_path" == *"command"* ]]; then
        echo "@cli/command/${clean_path#*command/}"
    else
        # Same module reference
        local current_module
        current_module=$(echo "$current_dir" | grep -oP "cli/\K[^/]+")
        echo "@cli/${current_module}/${clean_path}"
    fi
}

# Core path resolution with module awareness
resolve_core_path() {
    local relative_path="$1"
    local current_dir="$2"
    
    # Remove leading ./ and ../
    local clean_path="${relative_path#./}"
    clean_path="${clean_path#../}"
    
    # Detect target core module
    if [[ "$clean_path" == *"automaton"* ]]; then
        echo "@core/automaton/${clean_path#*automaton/}"
    elif [[ "$clean_path" == *"dop"* ]]; then
        echo "@core/dop/${clean_path#*dop/}"
    elif [[ "$clean_path" == *"parser"* ]]; then
        echo "@core/parser/${clean_path#*parser/}"
    elif [[ "$clean_path" == *"validation"* ]]; then
        echo "@core/validation/${clean_path#*validation/}"
    elif [[ "$clean_path" == *"ast"* ]]; then
        echo "@core/ast/${clean_path#*ast/}"
    elif [[ "$clean_path" == *"ioc"* ]]; then
        echo "@core/ioc/${clean_path#*ioc/}"
    elif [[ "$clean_path" == *"policy"* ]]; then
        echo "@core/policy/${clean_path#*policy/}"
    elif [[ "$clean_path" == *"vhtml"* ]]; then
        echo "@core/vhtml/${clean_path#*vhtml/}"
    elif [[ "$clean_path" == *"vcss"* ]]; then
        echo "@core/vcss/${clean_path#*vcss/}"
    elif [[ "$clean_path" == *"vdom"* ]]; then
        echo "@core/vdom/${clean_path#*vdom/}"
    elif [[ "$clean_path" == *"common"* ]]; then
        echo "@core/common/${clean_path#*common/}"
    else
        # Same module reference
        local current_module
        current_module=$(echo "$current_dir" | grep -oP "core/\K[^/]+")
        echo "@core/${current_module}/${clean_path}"
    fi
}

# Enhanced validation with false positive mitigation
validate_transformation() {
    local file="$1"
    
    # Check for valid TypeScript syntax
    if ! node -c "$file" 2>/dev/null; then
        echo "WARNING: Syntax error in $file after transformation"
        return 1
    fi
    
    # Check for unresolved imports (basic validation)
    if grep -P "import\s+.*\s+from\s+['\"][.]{2,}" "$file" >/dev/null; then
        echo "WARNING: Unresolved relative imports remain in $file"
        return 1
    fi
    
    return 0
}

# Comprehensive import analysis and transformation
analyze_and_transform() {
    local target_dir="${1:-src}"
    local dry_run="${2:-false}"
    
    log_info "Analyzing imports in $target_dir (dry_run: $dry_run)"
    
    # Find all TypeScript files
    local ts_files
    mapfile -t ts_files < <(find "$target_dir" -name "*.ts" -type f ! -path "*/node_modules/*")
    
    local total_files=${#ts_files[@]}
    local processed_files=0
    local transformed_files=0
    
    for file in "${ts_files[@]}"; do
        ((processed_files++))
        echo -ne "\rProcessing: $processed_files/$total_files"
        
        local has_violations=false
        
        # Check each pattern
        for pattern_name in "${!IMPORT_PATTERNS[@]}"; do
            if validate_import_pattern "$file" "$pattern_name"; then
                has_violations=true
                
                if [[ "$dry_run" == "false" ]]; then
                    # Perform transformation
                    transform_imports_in_file "$file" "$pattern_name"
                else
                    echo "Would transform $pattern_name in $file"
                fi
            fi
        done
        
        if [[ "$has_violations" == "true" ]]; then
            ((transformed_files++))
            
            if [[ "$dry_run" == "false" ]]; then
                # Validate transformation
                if ! validate_transformation "$file"; then
                    log_error "Transformation validation failed for $file"
                fi
            fi
        fi
    done
    
    echo ""
    log_success "Analysis complete: $transformed_files/$total_files files require transformation"
}

# Advanced import transformation
transform_imports_in_file() {
    local file="$1"
    local pattern_name="$2"
    
    # Create backup
    cp "$file" "${file}.bak"
    
    # Apply precise transformation based on pattern
    case "$pattern_name" in
        "CORE_"*)
            # Core module transformation
            local module_name="${pattern_name#CORE_}"
            local replacement="@core/${module_name,,}"
            
            # Use sophisticated sed replacement
            sed -i.tmp -E "s|import(.*)from ['\"](\.\./)*core/${module_name,,}/([^'\"]*)['\"]|import\1from '${replacement}/\3'|g" "$file"
            ;;
        "CLI_"*)
            # CLI module transformation
            local module_name="${pattern_name#CLI_}"
            local replacement="@cli/${module_name,,}"
            
            sed -i.tmp -E "s|import(.*)from ['\"](\.\./)*cli/${module_name,,}/([^'\"]*)['\"]|import\1from '${replacement}/\3'|g" "$file"
            ;;
        "LEGACY_DOP")
            # Legacy DOP fix
            sed -i.tmp -E "s|import(.*)from ['\"].*old/dop/dop/([^'\"]*)['\"]|import\1from '@core/dop/\2'|g" "$file"
            ;;
        "ERROR_TRACKER")
            # ErrorTracker fix
            sed -i.tmp -E "s|import(.*)from ['\"](\.\./)*ErrorTracker['\"]|import\1from '@core/common/errors/ErrorTracker'|g" "$file"
            ;;
    esac
    
    # Clean up temporary files
    rm -f "${file}.tmp"
}

# Logging functions
log_info() {
    echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') $1"
}

log_error() {
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') $1" >&2
}

log_success() {
    echo "[SUCCESS] $(date '+%Y-%m-%d %H:%M:%S') $1"
}

# Main execution with options
main() {
    local target_dir="${1:-src}"
    local dry_run="${2:-false}"
    
    log_info "Starting enhanced import validation for OBINexus framework"
    
    if [[ "$dry_run" == "true" ]]; then
        log_info "Running in dry-run mode - no files will be modified"
    fi
    
    analyze_and_transform "$target_dir" "$dry_run"
    
    log_success "Import validation and transformation completed"
}

# Execute with command line arguments
main "$@"
