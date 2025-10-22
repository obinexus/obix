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
