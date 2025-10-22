#!/bin/bash
# OBIX Babel Transform Integration Script
# Integrates refactored module structure with babel plugin ecosystem
# Project: Aegis - OBIX Framework
# Methodology: Waterfall Development with Systematic Integration

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
readonly BABEL_PLUGINS_DIR="$PROJECT_ROOT/scripts/setup"
readonly SRC_DIR="$PROJECT_ROOT/src"
readonly LOG_FILE="$PROJECT_ROOT/babel-integration-$(date +%Y%m%d-%H%M%S).log"

# Babel Plugin Configuration Matrix
declare -A BABEL_PLUGIN_MATRIX=(
    ["obix-compiler"]="Core compilation and module resolution"
    ["obix-component-syntax"]="React-stable JSX syntax processing"
    ["obix-policy"]="Decorator policy enforcement (@enforce_bank_policy)"
    ["obix-state-optimization"]="Automaton state minimization integration"
    ["obix-validation"]="Validation layer transforms"
)

# Policy Decorator Templates for Domain-Specific Enforcement
readonly POLICY_DECORATOR_TEMPLATE='/**
 * OBIX Policy Enforcement Decorator
 * Generated for: {{POLICY_DOMAIN}}
 * Security Level: {{SECURITY_LEVEL}}
 */

export function {{POLICY_NAME}}(
  securityLevel: "strict" | "standard" | "relaxed" = "standard",
  options: PolicyOptions = {}
) {
  return function <T extends new (...args: any[]) => any>(constructor: T) {
    return class extends constructor {
      private readonly policyEnforcer = new {{POLICY_DOMAIN}}PolicyEnforcer(securityLevel);
      
      constructor(...args: any[]) {
        super(...args);
        this.policyEnforcer.validateConstruction(this, options);
      }
      
      // State transition validation with policy enforcement
      protected applyTransition(transitionName: string, payload: any): any {
        const validationResult = this.policyEnforcer.validateTransition(
          transitionName, 
          payload, 
          this.getState()
        );
        
        if (!validationResult.isValid) {
          throw new PolicyViolationError(
            `Policy ${{{POLICY_NAME}}} violated: ${validationResult.message}`,
            validationResult.violations
          );
        }
        
        return super.applyTransition(transitionName, payload);
      }
    };
  };
}'

# JSX Transform Configuration for React-Stable Syntax
readonly JSX_TRANSFORM_CONFIG='{
  "pragma": "OBIX.createElement",
  "pragmaFrag": "OBIX.Fragment",
  "throwIfNamespace": false,
  "filter": {
    "include": ["**/*.obix.tsx", "**/*.obix.jsx"],
    "exclude": ["**/*.test.*", "**/node_modules/**"]
  },
  "transforms": {
    "componentSyntax": true,
    "stateOptimization": true,
    "policyEnforcement": true,
    "validationInjection": true
  }
}'

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

error() {
    echo "[ERROR] $*" >&2
    exit 1
}

# Generate Missing Babel Plugins with Template Implementation
generate_babel_plugin() {
    local plugin_name="$1"
    local plugin_description="$2"
    local plugin_file="$BABEL_PLUGINS_DIR/babel-plugin-$plugin_name.js"
    
    log "Generating babel plugin: $plugin_name"
    
    # Create plugin directory if it doesn't exist
    mkdir -p "$BABEL_PLUGINS_DIR"
    
    # Generate plugin based on type
    case "$plugin_name" in
        "obix-compiler")
            cat > "$plugin_file" << 'EOF'
// OBIX Compiler Babel Plugin
// Handles module resolution and core compilation transforms

module.exports = function({ types: t }) {
  return {
    name: "obix-compiler",
    visitor: {
      ImportDeclaration(path, state) {
        const source = path.node.source.value;
        const moduleAliases = state.opts.moduleAliases || {};
        
        // Transform @obix/* imports to proper paths
        for (const [alias, realPath] of Object.entries(moduleAliases)) {
          if (source.startsWith(alias)) {
            const newSource = source.replace(alias, realPath);
            path.node.source = t.stringLiteral(newSource);
            break;
          }
        }
      },
      
      Program: {
        enter(path, state) {
          // Add OBIX runtime imports if needed
          const hasOBIXImport = path.node.body.some(node => 
            t.isImportDeclaration(node) && 
            node.source.value.includes('@obix')
          );
          
          if (hasOBIXImport) {
            // Inject OBIX runtime dependencies
            const runtimeImport = t.importDeclaration(
              [t.importDefaultSpecifier(t.identifier('OBIX'))],
              t.stringLiteral('@obix/core/runtime')
            );
            path.unshiftContainer('body', runtimeImport);
          }
        }
      }
    }
  };
};
EOF
            ;;
            
        "obix-component-syntax")
            cat > "$plugin_file" << 'EOF'
// OBIX Component Syntax Babel Plugin
// Transforms React-stable JSX with OBIX optimizations

module.exports = function({ types: t }) {
  return {
    name: "obix-component-syntax",
    visitor: {
      JSXElement(path, state) {
        const pragma = state.opts.pragma || 'OBIX.createElement';
        const pragmaFrag = state.opts.pragmaFrag || 'OBIX.Fragment';
        
        // Transform JSX to OBIX.createElement calls
        if (state.opts.reactStableMode) {
          // Maintain React compatibility while adding OBIX optimizations
          const openingElement = path.node.openingElement;
          const tagName = openingElement.name.name;
          
          // Add OBIX-specific props for state optimization
          const obixProps = t.objectProperty(
            t.identifier('__obixOptimized'),
            t.booleanLiteral(true)
          );
          
          openingElement.attributes.push(t.jsxAttribute(
            t.jsxIdentifier('data-obix-component'),
            t.stringLiteral(tagName)
          ));
        }
      },
      
      Program: {
        enter(path, state) {
          // Auto-inject OBIX pragma
          if (state.opts.pragma && !path.scope.hasBinding('OBIX')) {
            const obixImport = t.importDeclaration(
              [t.importDefaultSpecifier(t.identifier('OBIX'))],
              t.stringLiteral('@obix/core')
            );
            path.unshiftContainer('body', obixImport);
          }
        }
      }
    }
  };
};
EOF
            ;;
            
        "obix-policy")
            cat > "$plugin_file" << 'EOF'
// OBIX Policy Enforcement Babel Plugin
// Transforms policy decorators for compile-time enforcement

module.exports = function({ types: t }) {
  return {
    name: "obix-policy",
    visitor: {
      Decorator(path, state) {
        const decoratorName = path.node.expression.callee?.name;
        const policyDomains = state.opts.policyDomains || [];
        const enforcementLevel = state.opts.enforcementLevel || 'standard';
        
        // Transform policy decorators
        if (decoratorName && decoratorName.startsWith('enforce_') && decoratorName.endsWith('_policy')) {
          const domain = decoratorName.replace('enforce_', '').replace('_policy', '');
          
          if (policyDomains.includes(domain)) {
            // Inject policy enforcement wrapper
            const policyWrapper = t.callExpression(
              t.memberExpression(
                t.identifier('OBIX'),
                t.identifier('enforcePolicyDecorator')
              ),
              [
                t.stringLiteral(domain),
                t.stringLiteral(enforcementLevel),
                path.node.expression
              ]
            );
            
            path.replaceWith(t.decorator(policyWrapper));
          }
        }
      },
      
      ClassDeclaration(path, state) {
        // Analyze class for policy enforcement requirements
        const decorators = path.node.decorators || [];
        const hasPolicyDecorator = decorators.some(decorator => {
          const name = decorator.expression.callee?.name;
          return name && name.includes('enforce_') && name.includes('_policy');
        });
        
        if (hasPolicyDecorator) {
          // Add policy enforcement metadata
          const policyMetadata = t.classProperty(
            t.identifier('__obixPolicyEnforced'),
            t.booleanLiteral(true)
          );
          policyMetadata.static = true;
          path.node.body.body.unshift(policyMetadata);
        }
      }
    }
  };
};
EOF
            ;;
            
        "obix-state-optimization")
            cat > "$plugin_file" << 'EOF'
// OBIX State Optimization Babel Plugin
// Integrates automaton state minimization at compile time

module.exports = function({ types: t }) {
  return {
    name: "obix-state-optimization",
    visitor: {
      ClassMethod(path, state) {
        const methodName = path.node.key.name;
        const enableMinimization = state.opts.enableAutomatonMinimization;
        const costOptimization = state.opts.costFunctionOptimization;
        
        // Optimize state transition methods
        if (methodName && methodName.includes('Transition') && enableMinimization) {
          // Inject state minimization logic
          const optimizationCall = t.expressionStatement(
            t.callExpression(
              t.memberExpression(
                t.identifier('OBIX'),
                t.identifier('optimizeStateTransition')
              ),
              [
                t.stringLiteral(methodName),
                t.thisExpression()
              ]
            )
          );
          
          path.node.body.body.unshift(optimizationCall);
        }
      },
      
      ObjectMethod(path, state) {
        // Optimize functional component state transitions
        if (path.node.key.name === 'transitions' && state.opts.costFunctionOptimization) {
          // Apply cost function optimization
          const costOptimization = t.objectProperty(
            t.identifier('__obixCostOptimized'),
            t.booleanLiteral(true)
          );
          
          if (t.isObjectExpression(path.node.value)) {
            path.node.value.properties.push(costOptimization);
          }
        }
      }
    }
  };
};
EOF
            ;;
            
        "obix-validation")
            cat > "$plugin_file" << 'EOF'
// OBIX Validation Layer Babel Plugin
// Integrates validation transforms with error propagation

module.exports = function({ types: t }) {
  return {
    name: "obix-validation",
    visitor: {
      CallExpression(path, state) {
        const callee = path.node.callee;
        const integrationMode = state.opts.integrationMode || 'manual';
        const errorPropagation = state.opts.errorPropagation;
        
        // Transform validation calls
        if (t.isMemberExpression(callee) && callee.property.name === 'validate') {
          if (integrationMode === 'automated') {
            // Inject automatic error handling
            const errorHandler = t.callExpression(
              t.memberExpression(
                t.identifier('OBIX'),
                t.identifier('handleValidationError')
              ),
              [path.node]
            );
            
            if (errorPropagation) {
              path.replaceWith(errorHandler);
            }
          }
        }
      },
      
      ThrowStatement(path, state) {
        // Enhance error propagation for validation errors
        if (state.opts.errorPropagation) {
          const enhancedError = t.callExpression(
            t.memberExpression(
              t.identifier('OBIX'),
              t.identifier('enhanceValidationError')
            ),
            [path.node.argument]
          );
          
          path.node.argument = enhancedError;
        }
      }
    }
  };
};
EOF
            ;;
    esac
    
    log "Generated babel plugin: $plugin_file"
}

# Enhanced Babel Plugin Ecosystem Validation with Auto-Generation
validate_and_generate_babel_plugins() {
    log "Validating and generating OBIX Babel plugin ecosystem..."
    
    local missing_plugins=()
    local invalid_plugins=()
    
    # First pass: Identify missing or invalid plugins
    for plugin in "${!BABEL_PLUGIN_MATRIX[@]}"; do
        local plugin_file="$BABEL_PLUGINS_DIR/babel-plugin-$plugin.js"
        local description="${BABEL_PLUGIN_MATRIX[$plugin]}"
        
        if [ ! -f "$plugin_file" ]; then
            log "⚠️  Missing babel plugin: $plugin"
            missing_plugins+=("$plugin:$description")
        else
            # Validate plugin exports
            if ! node -e "require('$plugin_file')" 2>/dev/null; then
                log "⚠️  Invalid babel plugin syntax: $plugin"
                invalid_plugins+=("$plugin:$description")
            else
                log "✅ Valid babel plugin: $plugin"
            fi
        fi
    done
    
    # Second pass: Generate missing plugins
    for plugin_entry in "${missing_plugins[@]}"; do
        local plugin="${plugin_entry%%:*}"
        local description="${plugin_entry#*:}"
        generate_babel_plugin "$plugin" "$description"
    done
    
    # Third pass: Regenerate invalid plugins
    for plugin_entry in "${invalid_plugins[@]}"; do
        local plugin="${plugin_entry%%:*}"
        local description="${plugin_entry#*:}"
        log "Regenerating invalid plugin: $plugin"
        generate_babel_plugin "$plugin" "$description"
    done
    
    # Final validation
    local final_validation_errors=0
    for plugin in "${!BABEL_PLUGIN_MATRIX[@]}"; do
        local plugin_file="$BABEL_PLUGINS_DIR/babel-plugin-$plugin.js"
        
        if ! node -e "require('$plugin_file')" 2>/dev/null; then
            log "ERROR: Plugin generation failed for: $plugin"
            ((final_validation_errors++))
        fi
    done
    
    if [ "$final_validation_errors" -eq 0 ]; then
        log "✅ Complete babel plugin ecosystem validated and generated successfully"
        log "Generated plugins: ${#missing_plugins[@]} missing, ${#invalid_plugins[@]} invalid"
        return 0
    else
        error "❌ Babel plugin ecosystem generation failed with $final_validation_errors errors"
    fi
}

# Generate Policy Enforcement Decorators
generate_policy_decorators() {
    local policy_domain="$1"
    local security_level="$2"
    local output_dir="$SRC_DIR/core/policy/decorators/generated"
    
    log "Generating policy decorator for domain: $policy_domain"
    
    mkdir -p "$output_dir"
    
    local policy_name="enforce_${policy_domain}_policy"
    local decorator_file="$output_dir/${policy_name}.ts"
    
    # Generate decorator from template
    local decorator_content="$POLICY_DECORATOR_TEMPLATE"
    decorator_content="${decorator_content//\{\{POLICY_DOMAIN\}\}/$policy_domain}"
    decorator_content="${decorator_content//\{\{SECURITY_LEVEL\}\}/$security_level}"
    decorator_content="${decorator_content//\{\{POLICY_NAME\}\}/$policy_name}"
    
    echo "$decorator_content" > "$decorator_file"
    
    log "Generated policy decorator: $decorator_file"
}

# Configure Babel Integration with OBIX Modules
configure_babel_integration() {
    log "Configuring babel integration with refactored OBIX modules..."
    
    local babel_config="$PROJECT_ROOT/babel.obix.config.js"
    
    cat > "$babel_config" << EOF
// OBIX Babel Configuration
// Generated: $(date)
// Integration with refactored module structure

module.exports = function(api) {
  api.cache(true);
  
  const presets = [
    ["@babel/preset-env", {
      "targets": {
        "node": "14",
        "browsers": ["last 2 Chrome versions", "last 2 Firefox versions"]
      }
    }],
    ["@babel/preset-typescript", {
      "allowNamespaces": true,
      "allowDeclareFields": true
    }]
  ];
  
  const plugins = [
    // OBIX Core Plugins (Order-dependent for single-pass processing)
    ["./scripts/setup/babel-plugin-obix-compiler.js", {
      "moduleAliases": {
        "@obix/core": "./src/core",
        "@obix/cli": "./src/cli",
        "@obix/api": "./src/core/api",
        "@obix/automaton": "./src/core/automaton",
        "@obix/dop": "./src/core/dop",
        "@obix/parser": "./src/core/parser",
        "@obix/validation": "./src/core/validation"
      }
    }],
    
    ["./scripts/setup/babel-plugin-obix-component-syntax.js", {
      "pragma": "OBIX.createElement",
      "pragmaFrag": "OBIX.Fragment",
      "reactStableMode": true
    }],
    
    ["./scripts/setup/babel-plugin-obix-state-optimization.js", {
      "enableAutomatonMinimization": true,
      "costFunctionOptimization": true
    }],
    
    ["./scripts/setup/babel-plugin-obix-policy.js", {
      "enforcementLevel": "strict",
      "policyDomains": ["banking", "healthcare", "fintech"],
      "decoratorValidation": true
    }],
    
    ["./scripts/setup/babel-plugin-obix-validation.js", {
      "integrationMode": "automated",
      "errorPropagation": true
    }]
  ];
  
  return {
    presets,
    plugins,
    sourceMaps: true,
    ignore: ["**/*.test.ts", "**/*.spec.ts", "**/node_modules/**"]
  };
};
EOF
    
    log "Generated OBIX babel configuration: $babel_config"
}

# Integrate with Package.json Scripts
update_package_scripts() {
    log "Updating package.json scripts for babel integration..."
    
    local temp_package=$(mktemp)
    
    # Add OBIX-specific build scripts
    jq '.scripts += {
      "build:obix": "babel src --out-dir dist/obix --config-file ./babel.obix.config.js --extensions \".ts,.tsx,.obix.tsx\"",
      "build:policy": "babel src/core/policy --out-dir dist/policy --config-file ./babel.obix.config.js",
      "validate:babel": "babel src --out-dir /tmp/babel-test --config-file ./babel.obix.config.js --dry-run",
      "prebuild:obix": "npm run validate:babel"
    }' "$PROJECT_ROOT/package.json" > "$temp_package"
    
    mv "$temp_package" "$PROJECT_ROOT/package.json"
    
    log "Updated package.json with OBIX babel integration scripts"
}

# Generate Domain-Specific Policy Decorators
generate_domain_policies() {
    log "Generating domain-specific policy decorators..."
    
    # Common financial domain policies
    generate_policy_decorators "banking" "strict"
    generate_policy_decorators "fintech" "standard" 
    generate_policy_decorators "healthcare" "strict"
    generate_policy_decorators "generic" "relaxed"
    
    # Generate policy registry
    local policy_registry="$SRC_DIR/core/policy/decorators/generated/index.ts"
    cat > "$policy_registry" << EOF
/**
 * OBIX Policy Decorator Registry
 * Generated: $(date)
 */

export { enforce_banking_policy } from './enforce_banking_policy';
export { enforce_fintech_policy } from './enforce_fintech_policy';
export { enforce_healthcare_policy } from './enforce_healthcare_policy';
export { enforce_generic_policy } from './enforce_generic_policy';

// Policy domain configuration
export const POLICY_DOMAINS = {
  BANKING: 'banking',
  FINTECH: 'fintech', 
  HEALTHCARE: 'healthcare',
  GENERIC: 'generic'
} as const;

export type PolicyDomain = typeof POLICY_DOMAINS[keyof typeof POLICY_DOMAINS];
EOF
    
    log "Generated policy decorator registry: $policy_registry"
}

# Main Integration Process
main() {
    log "Starting OBIX Babel Transform Integration..."
    
    # Validate prerequisite babel plugins with auto-generation
    validate_and_generate_babel_plugins
    
    # Generate domain-specific policy decorators
    generate_domain_policies
    
    # Configure babel integration with refactored modules
    configure_babel_integration
    
    # Update package.json build scripts
    update_package_scripts
    
    log "✅ OBIX Babel Transform Integration completed successfully"
    log "Next steps:"
    log "  1. Execute: npm run validate:babel"
    log "  2. Test policy decorators: npm run build:policy"
    log "  3. Full OBIX build: npm run build:obix"
}

# Execute with error handling
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi