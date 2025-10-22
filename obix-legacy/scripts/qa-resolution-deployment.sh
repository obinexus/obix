#!/bin/bash
# OBIX Framework QA Resolution and Tool Deployment Script
# Systematically deploys all validation tools to their designated locations
# Ensures package.json script alignment and proper permissions

set -euo pipefail

readonly PROJECT_ROOT="$(pwd)"
readonly SCRIPTS_DIR="$PROJECT_ROOT/scripts"
readonly TOOLS_DIR="$SCRIPTS_DIR/tools"

# ANSI color codes
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

log_deployment() {
    echo -e "${BLUE}[DEPLOYMENT]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

# Create directory structure
create_infrastructure() {
    log_deployment "Creating OBIX framework infrastructure..."
    
    mkdir -p "$TOOLS_DIR"
    mkdir -p "$SCRIPTS_DIR/setup"
    mkdir -p "$SCRIPTS_DIR/build/compile"
    mkdir -p "$SCRIPTS_DIR/test/performance"
    mkdir -p "$SCRIPTS_DIR/release/prepare"
    mkdir -p "$SCRIPTS_DIR/release/publish"
    
    log_success "Infrastructure directories created"
}

# Deploy import migration tool
deploy_import_migration_tool() {
    log_deployment "Deploying import migration tool to scripts/tools/import-migration-tool.ts..."
    
    cat > "$TOOLS_DIR/import-migration-tool.ts" << 'EOF'
#!/usr/bin/env ts-node
/**
 * OBIX Framework Import Migration Tool
 * Automated migration of relative imports to namespace-based imports
 * Supporting Nnamdi Okpala's automaton state minimization framework
 */

import * as fs from 'fs';
import * as path from 'path';
import { promisify } from 'util';

const readFile = promisify(fs.readFile);
const writeFile = promisify(fs.writeFile);
const readdir = promisify(fs.readdir);
const stat = promisify(fs.stat);

interface ImportMigrationRule {
  pattern: RegExp;
  replacement: string;
  priority: number;
  description: string;
}

interface MigrationResult {
  filePath: string;
  originalImports: string[];
  migratedImports: string[];
  changeCount: number;
  status: 'success' | 'error' | 'skipped';
  errorMessage?: string;
}

interface ProjectAnalysis {
  totalFiles: number;
  processedFiles: number;
  migratedFiles: number;
  totalChanges: number;
  errors: string[];
  results: MigrationResult[];
}

class OBIXImportMigrator {
  private migrationRules: ImportMigrationRule[] = [
    // Core module migrations - high priority
    {
      pattern: /from\s+['"]\.\.\/\.\.\/core\/dop\/([^'"]*)['"]/g,
      replacement: "from '@core/dop/$1'",
      priority: 1,
      description: 'Migrate DOP module imports'
    },
    {
      pattern: /from\s+['"]\.\.\/\.\.\/core\/automaton\/([^'"]*)['"]/g,
      replacement: "from '@core/automaton/$1'",
      priority: 1,
      description: 'Migrate automaton module imports'
    },
    {
      pattern: /from\s+['"]\.\.\/\.\.\/core\/parser\/([^'"]*)['"]/g,
      replacement: "from '@core/parser/$1'",
      priority: 1,
      description: 'Migrate parser module imports'
    },
    {
      pattern: /from\s+['"]\.\.\/\.\.\/core\/validation\/([^'"]*)['"]/g,
      replacement: "from '@core/validation/$1'",
      priority: 1,
      description: 'Migrate validation module imports'
    },
    {
      pattern: /from\s+['"]\.\.\/\.\.\/core\/ast\/([^'"]*)['"]/g,
      replacement: "from '@core/ast/$1'",
      priority: 1,
      description: 'Migrate AST module imports'
    },
    
    // API layer migrations
    {
      pattern: /from\s+['"]\.\.\/\.\.\/core\/api\/([^'"]*)['"]/g,
      replacement: "from '@api/$1'",
      priority: 2,
      description: 'Migrate API module imports'
    },
    
    // CLI module migrations
    {
      pattern: /from\s+['"]\.\.\/\.\.\/cli\/([^'"]*)['"]/g,
      replacement: "from '@cli/$1'",
      priority: 2,
      description: 'Migrate CLI module imports'
    },
    
    // Generic core module migrations (lower priority)
    {
      pattern: /from\s+['"]\.\.\/\.\.\/core\/([^'"]*)['"]/g,
      replacement: "from '@core/$1'",
      priority: 3,
      description: 'Migrate generic core module imports'
    }
  ];

  private projectRoot: string;
  private srcDir: string;
  private analysisResult: ProjectAnalysis;

  constructor(projectRoot: string) {
    this.projectRoot = projectRoot;
    this.srcDir = path.join(projectRoot, 'src');
    this.analysisResult = {
      totalFiles: 0,
      processedFiles: 0,
      migratedFiles: 0,
      totalChanges: 0,
      errors: [],
      results: []
    };
  }

  async migrateProject(dryRun: boolean = false): Promise<ProjectAnalysis> {
    console.log('🔄 Starting OBIX framework import migration...');
    console.log(`📁 Project root: ${this.projectRoot}`);
    console.log(`🎯 Source directory: ${this.srcDir}`);
    console.log(`🧪 Dry run mode: ${dryRun ? 'enabled' : 'disabled'}`);

    try {
      const tsFiles = await this.findTypeScriptFiles(this.srcDir);
      this.analysisResult.totalFiles = tsFiles.length;

      console.log(`📊 Found ${tsFiles.length} TypeScript files to analyze`);

      for (const filePath of tsFiles) {
        try {
          const result = await this.migrateFile(filePath, dryRun);
          this.analysisResult.results.push(result);
          this.analysisResult.processedFiles++;

          if (result.changeCount > 0) {
            this.analysisResult.migratedFiles++;
            this.analysisResult.totalChanges += result.changeCount;
          }

        } catch (error) {
          const errorMessage = error instanceof Error ? error.message : 'Unknown error';
          this.analysisResult.errors.push(`${filePath}: ${errorMessage}`);
          console.error(`❌ Error processing ${filePath}: ${errorMessage}`);
        }
      }

      this.generateReport();
      return this.analysisResult;

    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      console.error(`💥 Critical error during migration: ${errorMessage}`);
      throw error;
    }
  }

  private async migrateFile(filePath: string, dryRun: boolean): Promise<MigrationResult> {
    const content = await readFile(filePath, 'utf-8');
    const originalImports: string[] = [];
    const migratedImports: string[] = [];
    let modifiedContent = content;
    let changeCount = 0;

    const sortedRules = this.migrationRules.sort((a, b) => a.priority - b.priority);

    for (const rule of sortedRules) {
      const matches = [...content.matchAll(rule.pattern)];
      
      for (const match of matches) {
        originalImports.push(match[0]);
        const replacement = match[0].replace(rule.pattern, rule.replacement);
        migratedImports.push(replacement);
        
        if (!dryRun) {
          modifiedContent = modifiedContent.replace(match[0], replacement);
        }
        changeCount++;
      }
    }

    if (!dryRun && changeCount > 0) {
      await writeFile(filePath, modifiedContent, 'utf-8');
    }

    return {
      filePath: path.relative(this.projectRoot, filePath),
      originalImports,
      migratedImports,
      changeCount,
      status: 'success'
    };
  }

  private async findTypeScriptFiles(directory: string): Promise<string[]> {
    const files: string[] = [];
    
    try {
      const entries = await readdir(directory);
      
      for (const entry of entries) {
        const fullPath = path.join(directory, entry);
        const fileStat = await stat(fullPath);
        
        if (fileStat.isDirectory()) {
          if (!['node_modules', 'dist', '.git'].includes(entry)) {
            const subFiles = await this.findTypeScriptFiles(fullPath);
            files.push(...subFiles);
          }
        } else if (fileStat.isFile() && /\.tsx?$/.test(entry)) {
          files.push(fullPath);
        }
      }
    } catch (error) {
      console.warn(`⚠️ Warning: Could not read directory ${directory}: ${error}`);
    }
    
    return files;
  }

  private generateReport(): void {
    console.log('\n📋 OBIX Framework Import Migration Report');
    console.log('=========================================');
    console.log(`📁 Total files analyzed: ${this.analysisResult.totalFiles}`);
    console.log(`✅ Files processed: ${this.analysisResult.processedFiles}`);
    console.log(`🔄 Files migrated: ${this.analysisResult.migratedFiles}`);
    console.log(`🎯 Total import changes: ${this.analysisResult.totalChanges}`);
    console.log(`❌ Errors encountered: ${this.analysisResult.errors.length}`);

    if (this.analysisResult.errors.length > 0) {
      console.log('\n🚨 Migration Errors:');
      this.analysisResult.errors.forEach(error => console.log(`   ${error}`));
    }

    const successfulMigrations = this.analysisResult.results.filter(r => r.changeCount > 0);
    if (successfulMigrations.length > 0) {
      console.log('\n🎯 Sample Migrations:');
      successfulMigrations.slice(0, 5).forEach(result => {
        console.log(`\n📄 ${result.filePath} (${result.changeCount} changes)`);
        result.originalImports.slice(0, 3).forEach((original, index) => {
          const migrated = result.migratedImports[index];
          console.log(`   ❌ ${original}`);
          console.log(`   ✅ ${migrated}`);
        });
      });
    }

    console.log('\n🎉 Migration analysis complete!');
  }
}

async function main() {
  const args = process.argv.slice(2);
  const dryRun = args.includes('--dry-run');
  const projectRoot = args.find(arg => !arg.startsWith('--')) || process.cwd();

  if (args.includes('--help')) {
    console.log(`
OBIX Framework Import Migration Tool
===================================

Usage: ts-node import-migration-tool.ts [options] [project-root]

Options:
  --dry-run    Analyze imports without making changes
  --help       Show this help message

Examples:
  ts-node import-migration-tool.ts --dry-run
  ts-node import-migration-tool.ts /path/to/obix/project
`);
    process.exit(0);
  }

  try {
    const migrator = new OBIXImportMigrator(projectRoot);
    const result = await migrator.migrateProject(dryRun);
    
    if (result.errors.length > 0) {
      process.exit(1);
    }
  } catch (error) {
    console.error('💥 Migration failed:', error);
    process.exit(1);
  }
}

if (require.main === module) {
  main().catch(console.error);
}

export { OBIXImportMigrator };
EOF

    chmod +x "$TOOLS_DIR/import-migration-tool.ts"
    log_success "Import migration tool deployed"
}

# Deploy namespace validator
deploy_namespace_validator() {
    log_deployment "Deploying namespace validator to scripts/tools/obix-namespace-validator.sh..."
    
    cat > "$TOOLS_DIR/obix-namespace-validator.sh" << 'EOF'
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
EOF

    chmod +x "$TOOLS_DIR/obix-namespace-validator.sh"
    log_success "Namespace validator deployed"
}

# Deploy basic namespace tree validator
deploy_namespace_tree_validator() {
    log_deployment "Deploying namespace tree validator to scripts/tools/validate-namespace-tree.sh..."
    
    cat > "$TOOLS_DIR/validate-namespace-tree.sh" << 'EOF'
#!/bin/bash
# OBIX Framework Basic Namespace Tree Validation
set -euo pipefail

readonly PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
readonly SRC_DIR="$PROJECT_ROOT/src"

echo "Validating OBIX namespace tree structure..."
echo "Project Root: $PROJECT_ROOT"
echo "Source Directory: $SRC_DIR"

FAIL=0

# Check core namespaces
NAMESPACES=("core" "cli")

for ns in "${NAMESPACES[@]}"; do
    if [ ! -d "$SRC_DIR/$ns" ]; then
        echo "❌ Missing directory: $SRC_DIR/$ns"
        FAIL=1
    else
        echo "✅ Found: @$ns → $SRC_DIR/$ns"
        for dir in $(find "$SRC_DIR/$ns" -type d -maxdepth 1); do
            if [ "$dir" != "$SRC_DIR/$ns" ]; then
                relpath="${dir#"$SRC_DIR/"}"
                echo "  - @${relpath} → $dir"
            fi
        done
    fi
done

exit $FAIL
EOF

    chmod +x "$TOOLS_DIR/validate-namespace-tree.sh"
    log_success "Namespace tree validator deployed"
}

# Deploy package.json validator
deploy_package_validator() {
    log_deployment "Deploying package.json validator to scripts/tools/package-json-validator.sh..."
    
    cat > "$TOOLS_DIR/package-json-validator.sh" << 'EOF'
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
EOF

    chmod +x "$TOOLS_DIR/package-json-validator.sh"
    log_success "Package.json validator deployed"
}

# Deploy existing validate-imports.sh to scripts root
deploy_validate_imports() {
    log_deployment "Ensuring validate-imports.sh is in correct location..."
    
    if [ ! -f "$SCRIPTS_DIR/validate-imports.sh" ]; then
        cat > "$SCRIPTS_DIR/validate-imports.sh" << 'EOF'
#!/bin/bash
# OBIX Import Structure Validation Script
set -euo pipefail

readonly PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly SRC_DIR="$PROJECT_ROOT/src"

echo "Starting OBIX import structure validation..."

validation_errors=0
total_files=0
compliant_files=0

while IFS= read -r -d '' file; do
    ((total_files++))
    
    if grep -q "import.*from.*\.\./\.\." "$file" 2>/dev/null; then
        echo "⚠️  Invalid relative import in: ${file#$PROJECT_ROOT/}"
        ((validation_errors++))
    else
        ((compliant_files++))
    fi
    
done < <(find "$SRC_DIR" -name "*.ts" -type f -print0 2>/dev/null || true)

echo "Import validation summary:"
echo "  Total files: $total_files"
echo "  Compliant files: $compliant_files"
echo "  Files with violations: $validation_errors"

if [ "$validation_errors" -eq 0 ]; then
    echo "✅ All imports follow proper module boundaries"
    exit 0
else
    echo "❌ Import structure validation failed with $validation_errors violations"
    exit 1
fi
EOF

        chmod +x "$SCRIPTS_DIR/validate-imports.sh"
        log_success "Validate imports script deployed"
    else
        log_success "Validate imports script already exists"
    fi
}

# Deploy analyze-modules.sh to scripts root
deploy_analyze_modules() {
    log_deployment "Ensuring analyze-modules.sh is in correct location..."
    
    if [ ! -f "$SCRIPTS_DIR/analyze-modules.sh" ]; then
        cat > "$SCRIPTS_DIR/analyze-modules.sh" << 'EOF'
#!/bin/bash
# OBIX Module Architecture Analysis Script
set -euo pipefail

readonly PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly SRC_DIR="$PROJECT_ROOT/src"

echo "Analyzing OBIX module structure..."

total_modules=0
modules_with_index=0

for module_dir in "$SRC_DIR/core"/*; do
    if [ -d "$module_dir" ]; then
        ((total_modules++))
        module_name=$(basename "$module_dir")
        
        if [ -f "$module_dir/index.ts" ]; then
            ((modules_with_index++))
            echo "✅ Module $module_name has index.ts"
        else
            echo "⚠️  Module $module_name missing index.ts"
        fi
    fi
done

echo "Module analysis summary:"
echo "  Total core modules: $total_modules"
echo "  Modules with index.ts: $modules_with_index"
EOF

        chmod +x "$SCRIPTS_DIR/analyze-modules.sh"
        log_success "Analyze modules script deployed"
    else
        log_success "Analyze modules script already exists"
    fi
}

# Verify deployment success
verify_deployment() {
    log_deployment "Verifying tool deployment success..."
    
    local expected_tools=(
        "scripts/tools/import-migration-tool.ts"
        "scripts/tools/obix-namespace-validator.sh"
        "scripts/tools/validate-namespace-tree.sh"
        "scripts/tools/package-json-validator.sh"
        "scripts/validate-imports.sh"
        "scripts/analyze-modules.sh"
    )
    
    local missing_count=0
    
    for tool in "${expected_tools[@]}"; do
        if [ -f "$PROJECT_ROOT/$tool" ]; then
            log_success "✓ Deployed: $tool"
        else
            log_error "✗ Missing: $tool"
            ((missing_count++))
        fi
    done
    
    if [ $missing_count -eq 0 ]; then
        log_success "All tools successfully deployed"
        return 0
    else
        log_error "$missing_count tools failed to deploy"
        return 1
    fi
}

# Test package.json script alignment
test_script_alignment() {
    log_deployment "Testing package.json script alignment..."
    
    echo "Testing script execution paths..."
    
    # Test namespace validation
    if npm run namespace:validate 2>/dev/null; then
        log_success "namespace:validate script aligned"
    else
        log_warning "namespace:validate script needs verification"
    fi
    
    # Test import validation
    if npm run validate:imports 2>/dev/null; then
        log_success "validate:imports script aligned"
    else
        log_warning "validate:imports script needs verification"
    fi
}

# Main execution
main() {
    log_deployment "Starting OBIX framework QA resolution and tool deployment..."
    
    create_infrastructure
    deploy_import_migration_tool
    deploy_namespace_validator
    deploy_namespace_tree_validator
    deploy_package_validator
    deploy_validate_imports
    deploy_analyze_modules
    
    if verify_deployment; then
        log_success "QA resolution deployment completed successfully"
        
        echo ""
        echo "Next Steps:"
        echo "1. Run: npm run namespace:migrate:dry-run"
        echo "2. Run: npm run imports:validate"
        echo "3. Run: npm run namespace:validate:full"
        echo "4. Run: npm run dev:validate"
        
        test_script_alignment
    else
        log_error "QA resolution deployment encountered issues"
        exit 1
    fi
}

# Execute main function
main "$@"
