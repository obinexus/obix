#!/bin/bash

# OBINexus Import Compliance Resolution Framework
# Systematic remediation for architectural violations
# Converts relative imports to absolute path mappings per tsconfig specification

set -euo pipefail

# Configuration
PROJECT_ROOT="$(pwd)"
SRC_DIR="src"
BACKUP_DIR=".backup-$(date +%Y%m%d-%H%M%S)"

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

# Create backup
create_backup() {
    log_info "Creating backup at $BACKUP_DIR"
    cp -r "$SRC_DIR" "$BACKUP_DIR"
    log_success "Backup created successfully"
}

# Core import resolution patterns
resolve_core_imports() {
    local target_dir="$1"
    
    log_info "Resolving core module imports in $target_dir"
    
    # Core automaton imports
    find "$target_dir" -name "*.ts" -type f -exec grep -l "import.*from.*['\"]\.\..*automaton" {} \; | while read -r file; do
        sed -i.bak -E "s|import(.*)from ['\"](\.\./)*core/automaton/([^'\"]*)['\"]|import\1from '@core/automaton/\3'|g" "$file"
        rm -f "${file}.bak"
    done
    
    # Core DOP imports  
    find "$target_dir" -name "*.ts" -type f -exec grep -l "import.*from.*['\"]\.\..*dop" {} \; | while read -r file; do
        sed -i.bak -E "s|import(.*)from ['\"](\.\./)*core/dop/([^'\"]*)['\"]|import\1from '@core/dop/\3'|g" "$file"
        rm -f "${file}.bak"
    done
    
    # Core parser imports
    find "$target_dir" -name "*.ts" -type f -exec grep -l "import.*from.*['\"]\.\..*parser" {} \; | while read -r file; do
        sed -i.bak -E "s|import(.*)from ['\"](\.\./)*core/parser/([^'\"]*)['\"]|import\1from '@core/parser/\3'|g" "$file"
        rm -f "${file}.bak"
    done
    
    # Core validation imports
    find "$target_dir" -name "*.ts" -type f -exec grep -l "import.*from.*['\"]\.\..*validation" {} \; | while read -r file; do
        sed -i.bak -E "s|import(.*)from ['\"](\.\./)*core/validation/([^'\"]*)['\"]|import\1from '@core/validation/\3'|g" "$file"
        rm -f "${file}.bak"
    done
    
    # Core AST imports
    find "$target_dir" -name "*.ts" -type f -exec grep -l "import.*from.*['\"]\.\..*ast" {} \; | while read -r file; do
        sed -i.bak -E "s|import(.*)from ['\"](\.\./)*core/ast/([^'\"]*)['\"]|import\1from '@core/ast/\3'|g" "$file"
        rm -f "${file}.bak"
    done
    
    # Core IoC imports
    find "$target_dir" -name "*.ts" -type f -exec grep -l "import.*from.*['\"]\.\..*ioc" {} \; | while read -r file; do
        sed -i.bak -E "s|import(.*)from ['\"](\.\./)*core/ioc/([^'\"]*)['\"]|import\1from '@core/ioc/\3'|g" "$file"
        rm -f "${file}.bak"
    done
    
    # Core policy imports
    find "$target_dir" -name "*.ts" -type f -exec grep -l "import.*from.*['\"]\.\..*policy" {} \; | while read -r file; do
        sed -i.bak -E "s|import(.*)from ['\"](\.\./)*core/policy/([^'\"]*)['\"]|import\1from '@core/policy/\3'|g" "$file"
        rm -f "${file}.bak"
    done
    
    # Virtual DOM/HTML/CSS imports
    find "$target_dir" -name "*.ts" -type f -exec grep -l "import.*from.*['\"]\.\..*v(html|dom|css)" {} \; | while read -r file; do
        sed -i.bak -E "s|import(.*)from ['\"](\.\./)*core/vhtml/([^'\"]*)['\"]|import\1from '@core/vhtml/\3'|g" "$file"
        sed -i.bak -E "s|import(.*)from ['\"](\.\./)*core/vdom/([^'\"]*)['\"]|import\1from '@core/vdom/\3'|g" "$file"
        sed -i.bak -E "s|import(.*)from ['\"](\.\./)*core/vcss/([^'\"]*)['\"]|import\1from '@core/vcss/\3'|g" "$file"
        rm -f "${file}.bak"
    done
    
    # Core common imports
    find "$target_dir" -name "*.ts" -type f -exec grep -l "import.*from.*['\"]\.\..*common" {} \; | while read -r file; do
        sed -i.bak -E "s|import(.*)from ['\"](\.\./)*core/common/([^'\"]*)['\"]|import\1from '@core/common/\3'|g" "$file"
        rm -f "${file}.bak"
    done
}

# CLI import resolution patterns
resolve_cli_imports() {
    local target_dir="$1"
    
    log_info "Resolving CLI module imports in $target_dir"
    
    # CLI analyzer imports
    find "$target_dir" -name "*.ts" -type f -exec grep -l "import.*from.*['\"]\.\..*analyzer" {} \; | while read -r file; do
        sed -i.bak -E "s|import(.*)from ['\"](\.\./)*cli/analyzer/([^'\"]*)['\"]|import\1from '@cli/analyzer/\3'|g" "$file"
        rm -f "${file}.bak"
    done
    
    # CLI bundler imports
    find "$target_dir" -name "*.ts" -type f -exec grep -l "import.*from.*['\"]\.\..*bundler" {} \; | while read -r file; do
        sed -i.bak -E "s|import(.*)from ['\"](\.\./)*cli/bundler/([^'\"]*)['\"]|import\1from '@cli/bundler/\3'|g" "$file"
        rm -f "${file}.bak"
    done
    
    # CLI cache imports
    find "$target_dir" -name "*.ts" -type f -exec grep -l "import.*from.*['\"]\.\..*cache" {} \; | while read -r file; do
        sed -i.bak -E "s|import(.*)from ['\"](\.\./)*cli/cache/([^'\"]*)['\"]|import\1from '@cli/cache/\3'|g" "$file"
        rm -f "${file}.bak"
    done
    
    # CLI compiler imports
    find "$target_dir" -name "*.ts" -type f -exec grep -l "import.*from.*['\"]\.\..*compiler" {} \; | while read -r file; do
        sed -i.bak -E "s|import(.*)from ['\"](\.\./)*cli/compiler/([^'\"]*)['\"]|import\1from '@cli/compiler/\3'|g" "$file"
        rm -f "${file}.bak"
    done
    
    # CLI minifier imports
    find "$target_dir" -name "*.ts" -type f -exec grep -l "import.*from.*['\"]\.\..*minifier" {} \; | while read -r file; do
        sed -i.bak -E "s|import(.*)from ['\"](\.\./)*cli/minifier/([^'\"]*)['\"]|import\1from '@cli/minifier/\3'|g" "$file"
        rm -f "${file}.bak"
    done
    
    # CLI command registry imports
    find "$target_dir" -name "*.ts" -type f -exec grep -l "import.*from.*['\"]\.\..*command" {} \; | while read -r file; do
        sed -i.bak -E "s|import(.*)from ['\"](\.\./)*cli/command/([^'\"]*)['\"]|import\1from '@cli/command/\3'|g" "$file"
        rm -f "${file}.bak"
    done
}

# Resolve legacy boundary violations
resolve_boundary_violations() {
    local target_dir="$1"
    
    log_info "Resolving critical boundary violations in $target_dir"
    
    # Fix old/dop references
    find "$target_dir" -name "*.ts" -type f -exec grep -l "old/dop" {} \; | while read -r file; do
        log_info "Fixing legacy DOP reference in $file"
        sed -i.bak -E "s|import(.*)from ['\"].*old/dop/dop/([^'\"]*)['\"]|import\1from '@core/dop/\2'|g" "$file"
        rm -f "${file}.bak"
    done
    
    # Fix ErrorTracker references
    find "$target_dir" -name "*.ts" -type f -exec grep -l "ErrorTracker" {} \; | while read -r file; do
        log_info "Fixing ErrorTracker reference in $file"
        sed -i.bak -E "s|import(.*)from ['\"](\.\./)*ErrorTracker['\"]|import\1from '@core/common/errors/ErrorTracker'|g" "$file"
        rm -f "${file}.bak"
    done
}

# Validate import resolution
validate_import_resolution() {
    log_info "Validating import resolution"
    
    # Check for remaining relative imports
    relative_count=$(find "$SRC_DIR" -name "*.ts" -type f -exec grep -l "import.*from.*['\"]\.\./" {} \; | wc -l)
    
    if [ "$relative_count" -eq 0 ]; then
        log_success "All relative imports resolved successfully"
        return 0
    else
        log_error "$relative_count files still contain relative imports"
        return 1
    fi
}

# Main execution
main() {
    log_info "Starting OBINexus import compliance resolution"
    
    # Verify project structure
    if [ ! -d "$SRC_DIR" ]; then
        log_error "Source directory not found: $SRC_DIR"
        exit 1
    fi
    
    # Create backup
    create_backup
    
    # Resolve imports by category
    resolve_core_imports "$SRC_DIR"
    resolve_cli_imports "$SRC_DIR" 
    resolve_boundary_violations "$SRC_DIR"
    
    # Validate resolution
    if validate_import_resolution; then
        log_success "Import compliance resolution completed successfully"
    else
        log_error "Import compliance resolution completed with warnings"
        exit 1
    fi
}

# Execute main function
main "$@"