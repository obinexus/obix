#!/bin/bash

# =============================================================================
# scripts/validate-cli-provider.sh
# 
# CLI Provider Validation Script for OBIX Framework
# Implements systematic validation of CLI Provider standardized interface layer
# Supports waterfall methodology with structured validation approach
# 
# Copyright © 2025 OBINexus Computing
# =============================================================================

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
readonly LOG_FILE="${PROJECT_ROOT}/cli-provider-validation-${TIMESTAMP}.log"

# Color codes for technical output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# =============================================================================
# TECHNICAL LOGGING FUNCTIONS
# =============================================================================

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${timestamp} [${level}] ${message}" | tee -a "${LOG_FILE}"
}

log_technical() { log "TECHNICAL" "$@"; }
log_validation() { log "VALIDATION" "$@"; }
log_error() { log "ERROR" "$@"; }
log_success() { log "SUCCESS" "$@"; }

technical_banner() {
    local title="$1"
    echo ""
    echo "============================================================================="
    echo " ${title}"
    echo "============================================================================="
    echo ""
}

# =============================================================================
# CLI PROVIDER VALIDATION FUNCTIONS
# =============================================================================

validate_cli_provider_files() {
    log_technical "Validating CLI Provider file structure and implementation"
    
    local validation_errors=0
    local required_files=(
        "src/cli/cliProvider.ts"
        "src/cli/providers/index.ts"
        "tsconfig.cli.json"
        "jest.qa.config.js"
        "tests/qa/setup.js"
    )
    
    for file in "${required_files[@]}"; do
        local full_path="${PROJECT_ROOT}/${file}"
        if [ ! -f "${full_path}" ]; then
            log_error "Critical file missing: ${file}"
            ((validation_errors++))
        else
            log_success "Verified file exists: ${file}"
        fi
    done
    
    return ${validation_errors}
}

validate_typescript_compilation() {
    log_technical "Validating TypeScript compilation for CLI module"
    
    local compilation_errors=0
    
    # Validate CLI TypeScript configuration
    if ! npx tsc --project tsconfig.cli.json --noEmit --skipLibCheck 2>/dev/null; then
        log_error "CLI TypeScript compilation validation failed"
        ((compilation_errors++))
    else
        log_success "CLI TypeScript compilation validation passed"
    fi
    
    # Validate QA TypeScript configuration
    if ! npx tsc --project tsconfig.qa.json --noEmit --skipLibCheck 2>/dev/null; then
        log_error "QA TypeScript compilation validation failed"
        ((compilation_errors++))
    else
        log_success "QA TypeScript compilation validation passed"
    fi
    
    return ${compilation_errors}
}

validate_cli_provider_interface() {
    log_technical "Validating CLI Provider interface contract implementation"
    
    local interface_errors=0
    
    # Check if CLI Provider exports are available
    if ! node -e "
        const { CLIProvider, CLIProviderImpl, createCLIProvider } = require('./dist/cli/cliProvider.js');
        if (!CLIProvider || !CLIProviderImpl || !createCLIProvider) {
            console.error('CLI Provider interface exports missing');
            process.exit(1);
        }
        console.log('CLI Provider interface exports validated');
    " 2>/dev/null; then
        log_error "CLI Provider interface validation failed - exports not available"
        ((interface_errors++))
    else
        log_success "CLI Provider interface exports validated"
    fi
    
    return ${interface_errors}
}

validate_ioc_integration() {
    log_technical "Validating IoC container integration for CLI Provider"
    
    local ioc_errors=0
    
    # Test IoC service registration
    if ! node -e "
        const { createMockServiceContainer } = require('./tests/qa/setup.js');
        const { createCLIProvider } = require('./dist/cli/cliProvider.js');
        
        try {
            const container = createMockServiceContainer();
            const provider = createCLIProvider();
            provider.configure(container);
            
            const services = provider.getServices();
            if (services.length === 0) {
                console.error('No services registered by CLI Provider');
                process.exit(1);
            }
            
            console.log('IoC integration validated - services registered:', services.length);
        } catch (error) {
            console.error('IoC integration validation failed:', error.message);
            process.exit(1);
        }
    " 2>/dev/null; then
        log_error "IoC integration validation failed"
        ((ioc_errors++))
    else
        log_success "IoC container integration validated"
    fi
    
    return ${ioc_errors}
}

validate_command_registry_integration() {
    log_technical "Validating Command Registry integration for CLI Provider"
    
    local registry_errors=0
    
    # Test command registration
    if ! node -e "
        const { createMockServiceContainer, createMockCommandRegistry } = require('./tests/qa/setup.js');
        const { createCLIProvider } = require('./dist/cli/cliProvider.js');
        
        try {
            const container = createMockServiceContainer();
            const registry = createMockCommandRegistry(container);
            const provider = createCLIProvider();
            
            provider.configure(container);
            provider.registerCommands(registry);
            
            const commands = registry.getAllCommands();
            if (commands.length === 0) {
                console.error('No commands registered by CLI Provider');
                process.exit(1);
            }
            
            console.log('Command Registry integration validated - commands registered:', commands.length);
        } catch (error) {
            console.error('Command Registry integration validation failed:', error.message);
            process.exit(1);
        }
    " 2>/dev/null; then
        log_error "Command Registry integration validation failed"
        ((registry_errors++))
    else
        log_success "Command Registry integration validated"
    fi
    
    return ${registry_errors}
}

validate_qa_test_infrastructure() {
    log_technical "Validating QA test infrastructure for CLI Provider"
    
    local qa_errors=0
    
    # Test Jest QA configuration
    if ! npx jest --config jest.qa.config.js --passWithNoTests --silent 2>/dev/null; then
        log_error "Jest QA configuration validation failed"
        ((qa_errors++))
    else
        log_success "Jest QA configuration validated"
    fi
    
    # Test QA setup file
    if ! node -e "
        require('./tests/qa/setup.js');
        console.log('QA setup file loaded successfully');
    " 2>/dev/null; then
        log_error "QA setup file validation failed"
        ((qa_errors++))
    else
        log_success "QA setup file validated"
    fi
    
    return ${qa_errors}
}

validate_namespace_resolution() {
    log_technical "Validating namespace resolution for CLI Provider modules"
    
    local namespace_errors=0
    
    # Test CLI namespace mappings
    local cli_namespaces=(
        "@cli/cliProvider"
        "@cli/command/CommandRegistry"
        "@core/ioc/containers/ServiceContainer"
    )
    
    for namespace in "${cli_namespaces[@]}"; do
        if ! npx tsc --project tsconfig.cli.json --noEmit --skipLibCheck \
            --moduleResolution node \
            --esModuleInterop true \
            --allowSyntheticDefaultImports true 2>/dev/null; then
            log_error "Namespace resolution failed for CLI mappings"
            ((namespace_errors++))
            break
        fi
    done
    
    if [ ${namespace_errors} -eq 0 ]; then
        log_success "CLI namespace resolution validated"
    fi
    
    return ${namespace_errors}
}

# =============================================================================
# PERFORMANCE VALIDATION FUNCTIONS
# =============================================================================

validate_provider_performance() {
    log_technical "Validating CLI Provider performance characteristics"
    
    local performance_errors=0
    
    # Test initialization performance
    if ! node -e "
        const { createMockServiceContainer } = require('./tests/qa/setup.js');
        const { createCLIProvider } = require('./dist/cli/cliProvider.js');
        
        const startTime = Date.now();
        const container = createMockServiceContainer();
        const provider = createCLIProvider();
        provider.configure(container);
        
        provider.initialize().then(() => {
            const endTime = Date.now();
            const initTime = endTime - startTime;
            
            if (initTime > 5000) {
                console.error('CLI Provider initialization too slow:', initTime + 'ms');
                process.exit(1);
            }
            
            console.log('CLI Provider initialization performance validated:', initTime + 'ms');
        }).catch(error => {
            console.error('Performance validation error:', error.message);
            process.exit(1);
        });
    " 2>/dev/null; then
        log_error "CLI Provider performance validation failed"
        ((performance_errors++))
    else
        log_success "CLI Provider performance characteristics validated"
    fi
    
    return ${performance_errors}
}

# =============================================================================
# MAIN VALIDATION ORCHESTRATION
# =============================================================================

main() {
    technical_banner "OBIX CLI Provider Validation Framework"
    
    log_technical "Initiating systematic CLI Provider validation for waterfall methodology compliance"
    log_technical "Validating standardized interface layer implementation"
    
    local total_errors=0
    local start_time=$(date +%s)
    
    # Step 1: File structure validation
    validate_cli_provider_files
    total_errors=$((total_errors + $?))
    
    # Step 2: TypeScript compilation validation
    validate_typescript_compilation
    total_errors=$((total_errors + $?))
    
    # Step 3: Interface contract validation
    validate_cli_provider_interface
    total_errors=$((total_errors + $?))
    
    # Step 4: IoC integration validation
    validate_ioc_integration
    total_errors=$((total_errors + $?))
    
    # Step 5: Command Registry integration validation
    validate_command_registry_integration
    total_errors=$((total_errors + $?))
    
    # Step 6: QA infrastructure validation
    validate_qa_test_infrastructure
    total_errors=$((total_errors + $?))
    
    # Step 7: Namespace resolution validation
    validate_namespace_resolution
    total_errors=$((total_errors + $?))
    
    # Step 8: Performance validation
    validate_provider_performance
    total_errors=$((total_errors + $?))
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Generate validation summary
    technical_banner "CLI Provider Validation Summary"
    
    if [ ${total_errors} -eq 0 ]; then
        echo -e "${GREEN}✅ CLI Provider Validation PASSED${NC}"
        echo ""
        echo "Validation Results:"
        echo "  ✓ File structure validation: PASSED"
        echo "  ✓ TypeScript compilation: PASSED"
        echo "  ✓ Interface contract: PASSED"
        echo "  ✓ IoC integration: PASSED"
        echo "  ✓ Command Registry integration: PASSED"
        echo "  ✓ QA infrastructure: PASSED"
        echo "  ✓ Namespace resolution: PASSED"
        echo "  ✓ Performance characteristics: PASSED"
        echo ""
        echo "Technical Summary:"
        echo "  Total validation errors: 0"
        echo "  Validation duration: ${duration} seconds"
        echo "  CLI Provider standardized interface: COMPLIANT"
        echo "  Waterfall methodology compliance: ACHIEVED"
        echo ""
        log_success "CLI Provider validation completed successfully"
        log_technical "Validation log: ${LOG_FILE}"
        
        return 0
    else
        echo -e "${RED}❌ CLI Provider Validation FAILED${NC}"
        echo ""
        echo "Validation Results:"
        echo "  Total validation errors: ${total_errors}"
        echo "  Validation duration: ${duration} seconds"
        echo ""
        echo -e "${YELLOW}Review validation log for detailed error analysis:${NC}"
        echo "  ${LOG_FILE}"
        echo ""
        log_error "CLI Provider validation failed with ${total_errors} errors"
        
        return 1
    fi
}

# Execute main validation function
main "$@"
