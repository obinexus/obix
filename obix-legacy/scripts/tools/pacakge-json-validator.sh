#!/bin/bash
# OBIX Framework Package.json Structural Compliance Validator
# Ensures JSON integrity and dependency consistency across development lifecycle
# Author: Technical Infrastructure Team

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
readonly PACKAGE_JSON="$PROJECT_ROOT/package.json"
readonly VALIDATION_LOG="$PROJECT_ROOT/package-validation.log"

# ANSI color codes for structured output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

log_technical() {
    echo -e "${BLUE}[TECHNICAL]${NC} $*" | tee -a "$VALIDATION_LOG"
}

log_validation_success() {
    echo -e "${GREEN}[VALIDATION-SUCCESS]${NC} $*" | tee -a "$VALIDATION_LOG"
}

log_compliance_warning() {
    echo -e "${YELLOW}[COMPLIANCE-WARNING]${NC} $*" | tee -a "$VALIDATION_LOG"
}

log_structural_error() {
    echo -e "${RED}[STRUCTURAL-ERROR]${NC} $*" | tee -a "$VALIDATION_LOG"
}

# Initialize validation report
initialize_validation_framework() {
    echo "OBIX Framework Package.json Compliance Validation Report" > "$VALIDATION_LOG"
    echo "Generated: $(date)" >> "$VALIDATION_LOG"
    echo "Validation Framework Version: 1.0.0" >> "$VALIDATION_LOG"
    echo "Project: Nnamdi Okpala's OBIX Framework" >> "$VALIDATION_LOG"
    echo "=================================================" >> "$VALIDATION_LOG"
    echo "" >> "$VALIDATION_LOG"
}

# Validate JSON syntax integrity
validate_json_syntax() {
    log_technical "Executing JSON syntax validation for package.json..."
    
    if [ ! -f "$PACKAGE_JSON" ]; then
        log_structural_error "Package.json not found at expected location: $PACKAGE_JSON"
        return 1
    fi
    
    # Execute JSON syntax validation using Node.js built-in parser
    if node -e "JSON.parse(require('fs').readFileSync('$PACKAGE_JSON', 'utf8')); console.log('JSON syntax validation: PASSED')" 2>/dev/null; then
        log_validation_success "JSON syntax validation completed successfully"
        return 0
    else
        log_structural_error "JSON syntax validation failed - malformed package.json detected"
        
        # Attempt to identify specific syntax errors
        node -e "
            try {
                JSON.parse(require('fs').readFileSync('$PACKAGE_JSON', 'utf8'));
            } catch (error) {
                console.error('Syntax Error Details:', error.message);
                console.error('Error Position:', error.toString().match(/position (\d+)/)?.[1] || 'Unknown');
            }
        " 2>&1 | tee -a "$VALIDATION_LOG"
        
        return 1
    fi
}

# Validate dependency consistency and structure
validate_dependency_integrity() {
    log_technical "Analyzing dependency declarations for consistency..."
    
    local validation_errors=0
    
    # Extract and analyze dependency sections
    local dependencies=$(node -e "
        const pkg = JSON.parse(require('fs').readFileSync('$PACKAGE_JSON', 'utf8'));
        console.log('Dependencies:', Object.keys(pkg.dependencies || {}).length);
        console.log('DevDependencies:', Object.keys(pkg.devDependencies || {}).length);
        console.log('PeerDependencies:', Object.keys(pkg.peerDependencies || {}).length);
        console.log('OptionalDependencies:', Object.keys(pkg.optionalDependencies || {}).length);
    ")
    
    log_technical "Dependency analysis results:"
    echo "$dependencies" | tee -a "$VALIDATION_LOG"
    
    # Validate for duplicate dependencies across sections
    node -e "
        const pkg = JSON.parse(require('fs').readFileSync('$PACKAGE_JSON', 'utf8'));
        const deps = Object.keys(pkg.dependencies || {});
        const devDeps = Object.keys(pkg.devDependencies || {});
        const duplicates = deps.filter(dep => devDeps.includes(dep));
        
        if (duplicates.length > 0) {
            console.error('Duplicate dependencies detected:', duplicates.join(', '));
            process.exit(1);
        } else {
            console.log('No duplicate dependencies detected');
        }
    " 2>&1 | tee -a "$VALIDATION_LOG"
    
    if [ $? -eq 0 ]; then
        log_validation_success "Dependency consistency validation passed"
    else
        log_structural_error "Dependency duplication detected"
        ((validation_errors++))
    fi
    
    return $validation_errors
}

# Validate script definition integrity
validate_script_definitions() {
    log_technical "Validating npm script definitions and consistency..."
    
    local script_errors=0
    
    # Analyze script structure and detect potential issues
    node -e "
        const pkg = JSON.parse(require('fs').readFileSync('$PACKAGE_JSON', 'utf8'));
        const scripts = pkg.scripts || {};
        const scriptNames = Object.keys(scripts);
        
        console.log('Total scripts defined:', scriptNames.length);
        
        // Check for script naming consistency
        const namespaceScripts = scriptNames.filter(name => name.includes('namespace:'));
        const importScripts = scriptNames.filter(name => name.includes('imports:'));
        const buildScripts = scriptNames.filter(name => name.includes('build:'));
        const testScripts = scriptNames.filter(name => name.includes('test:'));
        
        console.log('Namespace scripts:', namespaceScripts.length);
        console.log('Import validation scripts:', importScripts.length);
        console.log('Build pipeline scripts:', buildScripts.length);
        console.log('Test execution scripts:', testScripts.length);
        
        // Validate essential OBIX framework scripts
        const requiredScripts = [
            'build', 'test', 'lint', 'validate:imports', 
            'namespace:validate', 'cli', 'dev'
        ];
        
        const missingScripts = requiredScripts.filter(script => !scripts[script]);
        
        if (missingScripts.length > 0) {
            console.error('Missing essential scripts:', missingScripts.join(', '));
            process.exit(1);
        } else {
            console.log('All essential OBIX framework scripts present');
        }
    " 2>&1 | tee -a "$VALIDATION_LOG"
    
    if [ $? -eq 0 ]; then
        log_validation_success "Script definition validation completed successfully"
    else
        log_structural_error "Essential script definitions missing"
        ((script_errors++))
    fi
    
    return $script_errors
}

# Validate OBIX framework-specific metadata
validate_obix_metadata() {
    log_technical "Validating OBIX framework-specific package metadata..."
    
    node -e "
        const pkg = JSON.parse(require('fs').readFileSync('$PACKAGE_JSON', 'utf8'));
        
        // Validate OBIX-specific fields
        const requiredFields = [
            'name', 'version', 'description', 'main', 'module', 'types',
            'author', 'repository', 'keywords'
        ];
        
        const missingFields = requiredFields.filter(field => !pkg[field]);
        
        if (missingFields.length > 0) {
            console.error('Missing required metadata fields:', missingFields.join(', '));
            process.exit(1);
        }
        
        // Validate OBIX-specific keywords
        const keywords = pkg.keywords || [];
        const obixKeywords = ['automaton', 'state-minimization', 'dop', 'obinexus'];
        const hasObixKeywords = obixKeywords.some(keyword => keywords.includes(keyword));
        
        if (!hasObixKeywords) {
            console.error('Missing OBIX framework identification keywords');
            process.exit(1);
        }
        
        console.log('OBIX framework metadata validation: PASSED');
    " 2>&1 | tee -a "$VALIDATION_LOG"
    
    if [ $? -eq 0 ]; then
        log_validation_success "OBIX framework metadata validation successful"
        return 0
    else
        log_structural_error "OBIX framework metadata validation failed"
        return 1
    fi
}

# Generate compliance report
generate_compliance_report() {
    log_technical "Generating comprehensive compliance assessment..."
    
    {
        echo ""
        echo "OBIX FRAMEWORK PACKAGE.JSON COMPLIANCE SUMMARY"
        echo "============================================="
        echo "Framework: Nnamdi Okpala's OBIX Implementation"
        echo "Validation Date: $(date)"
        echo "Package Version: $(node -e "console.log(JSON.parse(require('fs').readFileSync('$PACKAGE_JSON', 'utf8')).version)")"
        echo ""
        echo "VALIDATION RESULTS:"
        echo "- JSON Syntax: $(grep -q "JSON syntax validation: PASSED" "$VALIDATION_LOG" && echo "COMPLIANT" || echo "NON-COMPLIANT")"
        echo "- Dependency Integrity: $(grep -q "Dependency consistency validation passed" "$VALIDATION_LOG" && echo "VALIDATED" || echo "ISSUES DETECTED")"
        echo "- Script Definitions: $(grep -q "Script definition validation completed successfully" "$VALIDATION_LOG" && echo "COMPLETE" || echo "INCOMPLETE")"
        echo "- OBIX Metadata: $(grep -q "OBIX framework metadata validation: PASSED" "$VALIDATION_LOG" && echo "VERIFIED" || echo "MISSING")"
        echo ""
        echo "TECHNICAL RECOMMENDATIONS:"
        echo "1. Maintain automated validation in CI/CD pipeline"
        echo "2. Implement pre-commit hooks for package.json changes"
        echo "3. Regular dependency audit and update cycles"
        echo "4. Version consistency monitoring across build targets"
        
    } >> "$VALIDATION_LOG"
}

# Execute comprehensive validation workflow
execute_validation_workflow() {
    log_technical "Initiating OBIX framework package.json validation workflow..."
    
    initialize_validation_framework
    
    local total_errors=0
    
    # Execute validation phases sequentially
    validate_json_syntax || ((total_errors += $?))
    validate_dependency_integrity || ((total_errors += $?))
    validate_script_definitions || ((total_errors += $?))
    validate_obix_metadata || ((total_errors += $?))
    
    # Generate comprehensive assessment
    generate_compliance_report
    
    # Determine validation outcome
    if [ "$total_errors" -eq 0 ]; then
        log_validation_success "OBIX framework package.json validation completed successfully"
        log_technical "Compliance validation report: $VALIDATION_LOG"
        exit 0
    else
        log_structural_error "Package.json validation failed with $total_errors critical issues"
        log_technical "Review detailed analysis: $VALIDATION_LOG"
        exit 1
    fi
}

# Command line interface
case "${1:-}" in
    --help|-h)
        echo "OBIX Framework Package.json Compliance Validator"
        echo "Usage: $0 [--help]"
        echo ""
        echo "Validates JSON syntax, dependency consistency, and OBIX framework compliance"
        exit 0
        ;;
    *)
        execute_validation_workflow
        ;;
esac
