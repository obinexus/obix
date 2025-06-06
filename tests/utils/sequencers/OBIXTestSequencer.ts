// tests/utils/OBIXTestSequencer.ts

import { Sequencer } from '@jest/test-sequencer';
import path from 'path';
import fs from 'fs';

/**
 * Cache for test file information to avoid repeated file operations
 */
const testInfoCache = new Map<string, { hasIntegration: boolean; dependencies: string[] }>();

/**
 * Custom test sequencer implementation that orders tests by module priority
 * and optimizes test execution for the OBIX framework.
 * 
 * This implementation follows Nnamdi Okpala's requirement for module ordering
 * to ensure that dependent components are tested after their dependencies.
 */
class OBIXTestSequencer extends Sequencer {
  /**
   * Sort test paths based on module priority and dependencies
   * @param tests Array of test objects to sort
   * @returns Sorted array of tests
   */
  sort(tests: Array<any>): Array<any> {
    // Return a new array of tests sorted by the priority of modules
    return Array.from(tests).sort((testA, testB) => {
      // Extract module paths
      const pathA = testA.path;
      const pathB = testB.path;
      
      // Get the priority for both tests
      const priorityA = this.getModulePriority(pathA);
      const priorityB = this.getModulePriority(pathB);
      
      // Sort by priority (lower priority number = higher priority)
      if (priorityA !== priorityB) {
        return priorityA - priorityB;
      }
      
      // If both tests are in the same module group, check for specific dependencies
      const depsA = this.getDependencies(pathA);
      const depsB = this.getDependencies(pathB);
      
      // If B depends on A, run A first
      if (depsB.includes(path.basename(pathA))) {
        return -1;
      }
      
      // If A depends on B, run B first
      if (depsA.includes(path.basename(pathB))) {
        return 1;
      }
      
      // If priority is the same and no specific dependencies, sort alphabetically for stable ordering
      return pathA.localeCompare(pathB);
    });
  }
  
  /**
   * Get the priority value for a test module to establish execution order
   * Core modules with dependencies should be tested first
   * @param testPath Path to the test file
   * @returns Priority value (lower is higher priority)
   */
  getModulePriority(testPath: string): number {
    // Extract relevant module information from the test path
    const relativePath = path.relative(process.cwd(), testPath);
    
    // Prioritize modules based on dependencies per Nnamdi Okpala's requirements
    
    // Base data types and constants have highest priority
    if (relativePath.includes('/core/types/') || relativePath.includes('/core/constants/')) {
      return 1;
    }
    
    // Core utilities come next
    if (relativePath.includes('/core/utils/')) {
      return 2;
    }
    
    // Data models should be tested early (foundation)
    if (relativePath.includes('/core/dop/data/')) {
      return 3;
    }
    
    // Behavior models depend on data models
    if (relativePath.includes('/core/dop/behavior/')) {
      return 4;
    }
    
    // Validation depends on behavior and data
    if (relativePath.includes('/core/dop/validation/')) {
      return 5;
    }
    
    // Adapters depend on all previous modules
    if (relativePath.includes('/core/dop/adapter/')) {
      return 6;
    }
    
    // Other DOP module tests
    if (relativePath.includes('/core/dop/')) {
      return 7;
    }
    
    // Automaton state minimization tests
    if (relativePath.includes('/core/automaton/')) {
      return 8;
    }
    
    // HTML parser components
    if (relativePath.includes('/core/parser/html/tokens/')) {
      return 9;
    }
    
    if (relativePath.includes('/core/parser/html/processors/')) {
      return 10;
    }
    
    if (relativePath.includes('/core/parser/html/')) {
      return 11;
    }
    
    // CSS parser components
    if (relativePath.includes('/core/parser/css/tokenizer/')) {
      return 12;
    }
    
    if (relativePath.includes('/core/parser/css/')) {
      return 13;
    }
    
    // Other core module tests
    if (relativePath.includes('/core/')) {
      return 14;
    }
    
    // Integration suites after all unit tests
    if (relativePath.includes('/integration/')) {
      return 20;
    }
    
    return 100; // Default priority for other tests
  }
  
  /**
   * Check if a test has integration dependencies
   * @param testPath Path to the test file
   * @returns True if the test has integration dependencies
   */
  hasIntegrationDependencies(testPath: string): boolean {
    if (!testInfoCache.has(testPath)) {
      this.analyzeTestFile(testPath);
    }
    
    return testInfoCache.get(testPath)?.hasIntegration || false;
  }
  
  /**
   * Get the list of test files this test depends on
   * @param testPath Path to the test file
   * @returns Array of dependent test filenames
   */
  getDependencies(testPath: string): string[] {
    if (!testInfoCache.has(testPath)) {
      this.analyzeTestFile(testPath);
    }
    
    return testInfoCache.get(testPath)?.dependencies || [];
  }
  
  /**
   * Analyze a test file to determine its dependencies and integration requirements
   * @param testPath Path to the test file
   */
  private analyzeTestFile(testPath: string): void {
    try {
      const content = fs.readFileSync(testPath, 'utf8');
      
      // Check for integration dependencies
      const hasIntegration = content.includes('@integration') || 
                            content.includes('require(\'../integration/') ||
                            content.includes('from \'../integration/');
      
      // Look for explicit test dependency annotations
      // Format: @depends ModuleName.test.ts
      const dependencyRegex = /@depends\s+([^\s\n]+)/g;
      const dependencies: string[] = [];
      
      let match;
      while ((match = dependencyRegex.exec(content)) !== null) {
        dependencies.push(match[1]);
      }
      
      testInfoCache.set(testPath, { hasIntegration, dependencies });
      
    } catch (error) {
      console.warn(`Warning: Could not analyze test file ${testPath}`, error instanceof Error ? error.message : String(error));
      testInfoCache.set(testPath, { hasIntegration: false, dependencies: [] });
    }
  }
}

export default OBIXTestSequencer;