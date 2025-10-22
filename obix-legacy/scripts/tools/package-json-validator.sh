#!/bin/bash
# OBIX Framework Package.json Compliance Validator
set -euo pipefail

readonly PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
readonly PACKAGE_JSON="$PROJECT_ROOT/package.json"

# ANSI color codes
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

echo "Validating OBIX framework package.json compliance..."

# Validate JSON syntax
if node -e "JSON.parse(require('fs').readFileSync('$PACKAGE_JSON', 'utf8')); console.log('JSON syntax validation: PASSED')" 2>/dev/null; then
    log_success "JSON syntax validation completed successfully"
else
    log_error "JSON syntax validation failed - malformed package.json detected"
    exit 1
fi

# Validate essential scripts
node -e "
    const pkg = JSON.parse(require('fs').readFileSync('$PACKAGE_JSON', 'utf8'));
    const scripts = pkg.scripts || {};
    
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
" 2>&1

if [ $? -eq 0 ]; then
    log_success "Package.json validation successful"
    exit 0
else
    log_error "Package.json validation failed"
    exit 1
fi
