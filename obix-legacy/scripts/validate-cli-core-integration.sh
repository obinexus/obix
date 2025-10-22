#!/bin/bash

# =============================================================================
# scripts/validate-cli-core-integration.sh
# 
# CLI-Core Integration Validation Script for OBIX Framework
# Validates systematic integration between CLI Provider and Core modules
# Implements architectural boundary verification with waterfall methodology compliance
# 
# Copyright © 2025 OBINexus Computing
# =============================================================================

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
readonly LOG_FILE="${PROJECT_ROOT}/cli-core-integration-${TIMESTAMP}.log"

# Technical output formatting
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# =============================================================================
# TECHNICAL VALIDATION FRAMEWORK
# =============================================================================

log_technical() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${timestamp} [${level}] ${message}" | tee -a "${LOG_FILE}"
}

log_integration() { log_technical "INTEGRATION" "$@"; }
log_architectural() { log_technical "ARCHITECTURAL" "$@"; }
log_error() { log_technical "ERROR" "$@"; }
log_success() { log_technical "SUCCESS" "$@"; }

architectural_banner() {
    local title="$1"
    echo ""
    echo "============================================================================="
    echo " ${title}"
    echo "============================================================================="
    echo ""
}

# =============================================================================
# ARCHITECTURAL BOUNDARY VALIDATION
# =============================================================================

validate_architectural_boundaries() {
    log_architectural "Validating CLI-Core architectural boundary compliance"
    
    local boundary_violations=0
    
    # Validate CLI module isolation
    log_integration "Checking CLI module architectural isolation"
    if ! npx tsc --project tsconfig.cli.json --noEmit --skipLibCheck 2>/dev/null; then
        log_error "CLI module architectural boundary violation detected"
        ((boundary_violations++))
    else
        log_success "CLI module architectural boundaries validated"
    fi
    
    # Validate Core module isolation
    log_integration "Checking Core module architectural isolation"
    if ! npx tsc --project tsconfig.core.json --noEmit --skipLibCheck 2>/dev/null; then
        log_error "Core module architectural boundary violation detected"
        ((boundary_violations++))
    else
        log_success "Core module architectural boundaries validated"
    fi
    
    return ${boundary_violations}
}

validate_service_dependency_resolution() {
    log_integration "Validating systematic service dependency resolution between CLI and Core"
    
    local dependency_errors=0
    
    # Test CLI Provider dependency declarations
    if ! node -e "
        const { createCLIProvider } = require('./dist/cli/cliProvider.js');
        
        try {
            const provider = createCLIProvider();
            const dependencies = provider.getDependencies();
            
            const expectedCoreDependencies = [
                'core.automaton.minimizer',
                'core.dop.adapter',
                'core.parser.html',
                'core.parser.css',
                'core.validation.engine',
                'core.policy.ruleEngine',
                'core.ast.htmlOptimizer',
                'core.ast.cssOptimizer'
            ];
            
            const missingDependencies = expectedCoreDependencies.filter(dep => !dependencies.includes(dep));
            
            if (missingDependencies.length > 0) {
                console.error('Missing Core dependencies:', missingDependencies.join(', '));
                process.exit(1);
            }
            
            console.log('CLI Provider Core dependency declarations validated');
        } catch (error) {
            console.error('Dependency resolution validation failed:', error.message);
            process.exit(1);
        }
    " 2>/dev/null; then
        log_error "CLI Provider Core dependency resolution validation failed"
        ((dependency_errors++))
    else
        log_success "CLI Provider Core dependency resolution validated"
    fi
    
    return ${dependency_errors}
}

validate_obix_service_exposure() {
    log_integration "Validating systematic OBIX service exposure through CLI Provider interface"
    
    local exposure_errors=0
    
    # Test OBIX service exposure functionality
    if ! node -e "
        const { createMockServiceContainer, CLIProviderTestUtils } = require('./tests/qa/setup.js');
        const { createCLIProvider } = require('./dist/cli/cliProvider.js');
        
        try {
            const container = createMockServiceContainer();
            const provider = createCLIProvider();
            
            // Register mock Core services
            CLIProviderTestUtils.createMockCoreServices(container);
            
            provider.configure(container);
            
            const services = provider.exposeOBIXServices();
            
            // Validate service structure
            const requiredServiceCategories = ['automaton', 'dop', 'parser', 'validation', 'policy', 'ast'];
            const missingCategories = requiredServiceCategories.filter(category => !services[category]);
            
            if (missingCategories.length > 0) {
                console.error('Missing OBIX service categories:', missingCategories.join(', '));
                process.exit(1);
            }
            
            // Validate automaton services (Nnamdi Okpala's optimization algorithms)
            if (!services.automaton.minimizer || !services.automaton.stateManager) {
                console.error('Missing critical automaton state minimization services');
                process.exit(1);
            }
            
            console.log('OBIX service exposure systematic validation completed');
        } catch (error) {
            console.error('OBIX service exposure validation failed:', error.message);
            process.exit(1);
        }
    " 2>/dev/null; then
        log_error "OBIX service exposure validation failed"
        ((exposure_errors++))
    else
        log_success "OBIX service exposure through CLI Provider validated"
    fi
    
    return ${exposure_errors}
}

validate_command_core_integration() {
    log_integration "Validating CLI command integration with Core module services"
    
    local command_errors=0
    
    # Test command-core service integration
    if ! node -e "
        const { createMockServiceContainer, createMockCommandRegistry, CLIProviderTestUtils } = require('./tests/qa/setup.js');
        const { createCLIProvider } = require('./dist/cli/cliProvider.js');
        
        try {
            const container = createMockServiceContainer();
            const registry = createMockCommandRegistry(container);
            const provider = createCLIProvider();
            
            // Mock Core services
            CLIProviderTestUtils.createMockCoreServices(container);
            
            provider.configure(container);
            provider.registerCommands(registry);
            
            // Test specific command integration
            const analyzeCommand = registry.getCommandByName('analyze');
            const compileCommand = registry.getCommandByName('compile');
            const bundleCommand = registry.getCommandByName('bundle');
            
            if (!analyzeCommand || !compileCommand || !bundleCommand) {
                console.error('Critical CLI commands not properly integrated');
                process.exit(1);
            }
            
            console.log('CLI command-Core service integration validated');
        } catch (error) {
            console.error('Command-Core integration validation failed:', error.message);
            process.exit(1);
        }
    " 2>/dev/null; then
        log_error "CLI command-Core integration validation failed"
        ((command_errors++))
    else
        log_success "CLI command-Core service integration validated"
    fi
    
    return ${command_errors}
}

validate_namespace_cross_module_resolution() {
    log_integration "Validating cross-module namespace resolution between CLI and Core"
    
    local namespace_errors=0
    
    # Test CLI access to Core namespaces
    local cli_core_imports=(
        "@core/ioc/containers/ServiceContainer"
        "@core/automaton/minimizer"
        "@core/dop/adapter"
        "@core/validation/engine"
        "@core/policy/engine"
    )
    
    # Create temporary test file for namespace validation
    local test_file="${PROJECT_ROOT}/temp-namespace-test.ts"
    
    cat > "${test_file}" << 'EOF'
// Temporary CLI-Core namespace integration test
import { ServiceContainer } from '@core/ioc/containers/ServiceContainer';

// Mock CLI Provider integration test
export class NamespaceIntegrationTest {
  private container: ServiceContainer;
  
  constructor(container: ServiceContainer) {
    this.container = container;
  }
  
  testCoreAccess() {
    // Test Core service access patterns
    try {
      this.container.get('core.automaton.minimizer');
      this.container.get('core.dop.adapter');
      return true;
    } catch (error) {
      return false;
    }
  }
}
EOF
    
    # Validate namespace resolution
    if ! npx tsc --project tsconfig.cli.json --noEmit "${test_file}" 2>/dev/null; then
        log_error "CLI-Core namespace cross-module resolution failed"
        ((namespace_errors++))
    else
        log_success "CLI-Core namespace cross-module resolution validated"
    fi
    
    # Clean up test file
    rm -f "${test_file}"
    
    return ${namespace_errors}
}

validate_integration_performance() {
    log_integration "Validating CLI-Core integration performance characteristics"
    
    local performance_errors=0
    
    # Test integration performance
    if ! node -e "
        const { createMockServiceContainer, CLIProviderTestUtils } = require('./tests/qa/setup.js');
        const { createCLIProvider } = require('./dist/cli/cliProvider.js');
        
        async function performanceTest() {
            try {
                const startTime = Date.now();
                
                const container = createMockServiceContainer();
                CLIProviderTestUtils.createMockCoreServices(container);
                
                const provider = createCLIProvider();
                provider.configure(container);
                await provider.initialize();
                
                const services = provider.exposeOBIXServices();
                
                const endTime = Date.now();
                const integrationTime = endTime - startTime;
                
                if (integrationTime > 10000) {
                    console.error('CLI-Core integration performance too slow:', integrationTime + 'ms');
                    process.exit(1);
                }
                
                console.log('CLI-Core integration performance validated:', integrationTime + 'ms');
                
                // Test service access performance
                const serviceAccessStart = Date.now();
                const automatonService = services.automaton.minimizer;
                const dopService = services.dop.adapter;
                const parserService = services.parser.htmlParser;
                const serviceAccessEnd = Date.now();
                
                const serviceAccessTime = serviceAccessEnd - serviceAccessStart;
                if (serviceAccessTime > 100) {
                    console.error('Service access performance too slow:', serviceAccessTime + 'ms');
                    process.exit(1);
                }
                
                console.log('Service access performance validated:', serviceAccessTime + 'ms');
            } catch (error) {
                console.error('Integration performance test failed:', error.message);
                process.exit(1);
            }
        }
        
        performanceTest();
    " 2>/dev/null; then
        log_error "CLI-Core integration performance validation failed"
        ((performance_errors++))
    else
        log_success "CLI-Core integration performance characteristics validated"
    fi
    
    return ${performance_errors}
}

validate_error_boundary_handling() {
    log_integration "Validating error boundary handling in CLI-Core integration"
    
    local error_handling_errors=0
    
    # Test error boundary behavior
    if ! node -e "
        const { createMockServiceContainer } = require('./tests/qa/setup.js');
        const { createCLIProvider } = require('./dist/cli/cliProvider.js');
        
        try {
            // Test with incomplete Core services
            const incompleteContainer = createMockServiceContainer();
            const provider = createCLIProvider();
            
            provider.configure(incompleteContainer);
            
            // Should throw appropriate error when exposing services without Core dependencies
            try {
                provider.exposeOBIXServices();
                console.error('Expected error when exposing services without Core dependencies');
                process.exit(1);
            } catch (expectedError) {
                if (!expectedError.message.includes('Failed to expose OBIX services')) {
                    console.error('Unexpected error message:', expectedError.message);
                    process.exit(1);
                }
            }
            
            console.log('Error boundary handling validated for CLI-Core integration');
        } catch (error) {
            console.error('Error boundary validation failed:', error.message);
            process.exit(1);
        }
    " 2>/dev/null; then
        log_error "CLI-Core error boundary handling validation failed"
        ((error_handling_errors++))
    else
        log_success "CLI-Core error boundary handling validated"
    fi
    
    return ${error_handling_errors}
}

# =============================================================================
# COLLABORATIVE INTEGRATION VALIDATION
# =============================================================================

validate_nnamdi_okpala_optimization_integration() {
    log_integration "Validating integration of Nnamdi Okpala's automaton state minimization technology"
    
    local optimization_errors=0
    
    # Test automaton optimization service integration
    if ! node -e "
        const { createMockServiceContainer, CLIProviderTestUtils } = require('./tests/qa/setup.js');
        const { createCLIProvider } = require('./dist/cli/cliProvider.js');
        
        try {
            const container = createMockServiceContainer();
            CLIProviderTestUtils.createMockCoreServices(container);
            
            const provider = createCLIProvider();
            provider.configure(container);
            
            const services = provider.exposeOBIXServices();
            
            // Validate automaton state minimization service availability
            if (!services.automaton || !services.automaton.minimizer) {
                console.error('Nnamdi Okpala automaton state minimization service not exposed');
                process.exit(1);
            }
            
            // Validate DOP adapter integration for optimization
            if (!services.dop || !services.dop.adapter) {
                console.error('DOP adapter for state optimization not exposed');
                process.exit(1);
            }
            
            console.log('Nnamdi Okpala optimization technology integration validated');
        } catch (error) {
            console.error('Optimization technology integration validation failed:', error.message);
            process.exit(1);
        }
    " 2>/dev/null; then
        log_error "Nnamdi Okpala optimization technology integration validation failed"
        ((optimization_errors++))
    else
        log_success "Nnamdi Okpala automaton state minimization technology integration validated"
    fi
    
    return ${optimization_errors}
}

# =============================================================================
# SYSTEMATIC INTEGRATION ORCHESTRATION
# =============================================================================

main() {
    architectural_banner "OBIX CLI-Core Integration Validation Framework"
    
    log_integration "Initiating systematic CLI-Core integration validation"
    log_architectural "Validating architectural boundary compliance and service integration"
    log_integration "Collaborative validation of Nnamdi Okpala's optimization technology integration"
    
    local total_errors=0
    local start_time=$(date +%s)
    
    # Phase 1: Architectural boundary validation
    log_integration "Phase 1: Architectural Boundary Validation"
    validate_architectural_boundaries
    total_errors=$((total_errors + $?))
    
    # Phase 2: Service dependency resolution
    log_integration "Phase 2: Service Dependency Resolution Validation"
    validate_service_dependency_resolution
    total_errors=$((total_errors + $?))
    
    # Phase 3: OBIX service exposure validation
    log_integration "Phase 3: OBIX Service Exposure Validation"
    validate_obix_service_exposure
    total_errors=$((total_errors + $?))
    
    # Phase 4: Command-Core integration
    log_integration "Phase 4: CLI Command-Core Integration Validation"
    validate_command_core_integration
    total_errors=$((total_errors + $?))
    
    # Phase 5: Namespace cross-module resolution
    log_integration "Phase 5: Cross-Module Namespace Resolution Validation"
    validate_namespace_cross_module_resolution
    total_errors=$((total_errors + $?))
    
    # Phase 6: Integration performance validation
    log_integration "Phase 6: Integration Performance Validation"
    validate_integration_performance
    total_errors=$((total_errors + $?))
    
    # Phase 7: Error boundary handling
    log_integration "Phase 7: Error Boundary Handling Validation"
    validate_error_boundary_handling
    total_errors=$((total_errors + $?))
    
    # Phase 8: Optimization technology integration
    log_integration "Phase 8: Nnamdi Okpala Optimization Technology Integration"
    validate_nnamdi_okpala_optimization_integration
    total_errors=$((total_errors + $?))
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Generate comprehensive integration validation summary
    architectural_banner "CLI-Core Integration Validation Summary"
    
    if [ ${total_errors} -eq 0 ]; then
        echo -e "${GREEN}✅ CLI-Core Integration Validation PASSED${NC}"
        echo ""
        echo "Architectural Validation Results:"
        echo "  ✓ Architectural boundary compliance: VALIDATED"
        echo "  ✓ Service dependency resolution: VALIDATED"
        echo "  ✓ OBIX service exposure: VALIDATED"
        echo "  ✓ CLI command-Core integration: VALIDATED"
        echo "  ✓ Cross-module namespace resolution: VALIDATED"
        echo "  ✓ Integration performance: VALIDATED"
        echo "  ✓ Error boundary handling: VALIDATED"
        echo "  ✓ Nnamdi Okpala optimization integration: VALIDATED"
        echo ""
        echo "Technical Integration Summary:"
        echo "  Total integration validation errors: 0"
        echo "  Validation execution duration: ${duration} seconds"
        echo "  CLI Provider standardized interface: COMPLIANT"
        echo "  Core module service exposure: SYSTEMATIC"
        echo "  Waterfall methodology compliance: ACHIEVED"
        echo "  Collaborative optimization integration: SUCCESSFUL"
        echo ""
        log_success "CLI-Core integration validation completed successfully"
        log_architectural "Integration validation log: ${LOG_FILE}"
        
        return 0
    else
        echo -e "${RED}❌ CLI-Core Integration Validation FAILED${NC}"
        echo ""
        echo "Integration Validation Results:"
        echo "  Total integration validation errors: ${total_errors}"
        echo "  Validation execution duration: ${duration} seconds"
        echo ""
        echo -e "${YELLOW}Technical Analysis Required:${NC}"
        echo "  Review detailed integration validation log: ${LOG_FILE}"
        echo "  Address architectural boundary violations"
        echo "  Verify service dependency resolution"
        echo "  Validate systematic OBIX service exposure"
        echo ""
        log_error "CLI-Core integration validation failed with ${total_errors} errors"
        log_architectural "Systematic remediation required for waterfall methodology compliance"
        
        return 1
    fi
}

# Execute systematic integration validation
main "$@"
