/**
 * jest.qa.config.js
 * 
 * Jest Configuration for OBIX QA Validation Framework
 * Supports systematic CLI Provider testing and Core module validation
 * Implements waterfall methodology compliance with structured testing approach
 * 
 * Copyright © 2025 OBINexus Computing
 */

/** @type {import('jest').Config} */
const config = {
  // Use ts-jest preset for TypeScript support
  preset: 'ts-jest',
  
  // Node environment for CLI Provider testing
  testEnvironment: 'node',
  
  // Project identification
  displayName: 'OBIX QA Validation Framework',
  
  // Root directories for module resolution
  roots: ['<rootDir>/src', '<rootDir>/tests'],
  
  // Test file patterns for QA validation
  testMatch: [
    '<rootDir>/tests/qa/**/*.test.{js,ts}',
    '<rootDir>/tests/qa/**/*.spec.{js,ts}',
    '<rootDir>/tests/qa/modules/**/*.test.{js,ts}',
    '<rootDir>/tests/qa/behavioral/**/*.test.{js,ts}',
    '<rootDir>/tests/qa/react-compatibility/**/*.test.{js,ts}',
    '<rootDir>/tests/qa/performance/**/*.test.{js,ts}'
  ],
  
  // TypeScript transformation configuration
  transform: {
    '^.+\\.tsx?$': ['ts-jest', {
      tsconfig: 'tsconfig.qa.json',
      diagnostics: {
        warnOnly: true
      },
      isolatedModules: true
    }]
  },
  
  // Module name mapping for namespace resolution
  moduleNameMapper: {
    // QA-specific mappings
    '^@qa/(.*)$': '<rootDir>/tests/qa/$1',
    '^@qa/modules/(.*)$': '<rootDir>/tests/qa/modules/$1',
    '^@qa/behavioral/(.*)$': '<rootDir>/tests/qa/behavioral/$1',
    '^@qa/fixtures/(.*)$': '<rootDir>/tests/fixtures/qa/$1',
    '^@qa/utils/(.*)$': '<rootDir>/tests/qa/utils/$1',
    '^@qa/helpers/(.*)$': '<rootDir>/scripts/qa/helpers/$1',
    
    // CLI module mappings
    '^@cli/(.*)$': '<rootDir>/src/cli/$1',
    '^@cli/analyzer/(.*)$': '<rootDir>/src/cli/analyzer/$1',
    '^@cli/bundler/(.*)$': '<rootDir>/src/cli/bundler/$1',
    '^@cli/cache/(.*)$': '<rootDir>/src/cli/cache/$1',
    '^@cli/compiler/(.*)$': '<rootDir>/src/cli/compiler/$1',
    '^@cli/minifier/(.*)$': '<rootDir>/src/cli/minifier/$1',
    '^@cli/profiler/(.*)$': '<rootDir>/src/cli/profiler/$1',
    '^@cli/policy/(.*)$': '<rootDir>/src/cli/policy/$1',
    '^@cli/command/(.*)$': '<rootDir>/src/cli/command/$1',
    '^@cli/test-module/(.*)$': '<rootDir>/src/cli/test-module/$1',
    '^@cli/providers/(.*)$': '<rootDir>/src/cli/providers/$1',
    
    // Core module mappings
    '^@core/(.*)$': '<rootDir>/src/core/$1',
    '^@core/api/(.*)$': '<rootDir>/src/core/api/$1',
    '^@core/automaton/(.*)$': '<rootDir>/src/core/automaton/$1',
    '^@core/dop/(.*)$': '<rootDir>/src/core/dop/$1',
    '^@core/parser/(.*)$': '<rootDir>/src/core/parser/$1',
    '^@core/validation/(.*)$': '<rootDir>/src/core/validation/$1',
    '^@core/ioc/(.*)$': '<rootDir>/src/core/ioc/$1',
    '^@core/policy/(.*)$': '<rootDir>/src/core/policy/$1',
    '^@core/ast/(.*)$': '<rootDir>/src/core/ast/$1',
    '^@core/vhtml/(.*)$': '<rootDir>/src/core/vhtml/$1',
    '^@core/vcss/(.*)$': '<rootDir>/src/core/vcss/$1',
    '^@core/vdom/(.*)$': '<rootDir>/src/core/vdom/$1',
    '^@core/common/(.*)$': '<rootDir>/src/core/common/$1',
    '^@core/config/(.*)$': '<rootDir>/src/core/config/$1',
    '^@core/components/(.*)$': '<rootDir>/src/core/components/$1',
    '^@core/factory/(.*)$': '<rootDir>/src/core/factory/$1',
    
    // Legacy mappings for compatibility
    '^@parser/(.*)$': '<rootDir>/src/core/parser/$1',
    '^@diff/(.*)$': '<rootDir>/src/core/diff/$1',
    '^@api/(.*)$': '<rootDir>/src/core/api/$1',
    '^@factory/(.*)$': '<rootDir>/src/core/factory/$1',
    
    // General test utilities
    '^@test/(.*)$': '<rootDir>/tests/$1',
    '^@test/fixtures/(.*)$': '<rootDir>/tests/fixtures/$1',
    '^@test/utils/(.*)$': '<rootDir>/tests/utils/$1',
    '^@/(.*)$': '<rootDir>/src/$1'
  },
  
  // Module file extensions
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx', 'json', 'node'],
  
  // Module directories for resolution
  moduleDirectories: ['node_modules', 'src', 'tests'],
  
  // Coverage collection configuration
  collectCoverageFrom: [
    'src/cli/**/*.{ts,tsx}',
    'src/core/**/*.{ts,tsx}',
    '!src/**/*.d.ts',
    '!src/**/index.{ts,tsx}',
    '!src/**/*.test.{ts,tsx}',
    '!src/**/*.spec.{ts,tsx}'
  ],
  
  // Coverage path ignore patterns
  coveragePathIgnorePatterns: [
    '/node_modules/',
    '/tests/',
    '/dist/',
    '/build/',
    '/.git/',
    '/coverage/'
  ],
  
  // Test path ignore patterns
  testPathIgnorePatterns: [
    '/node_modules/',
    '/dist/',
    '/build/',
    '/.git/'
  ],
  
  // Setup files
  setupFilesAfterEnv: [
    '<rootDir>/tests/qa/setup.js'
  ],
  
  // Test timeout for complex QA operations
  testTimeout: 30000,
  
  // Reporter configuration
  reporters: [
    'default',
    ['jest-junit', {
      outputDirectory: './test-results/qa',
      outputName: 'qa-test-results.xml',
      suiteName: 'OBIX QA Validation'
    }]
  ],
  
  // Coverage directory
  coverageDirectory: '<rootDir>/coverage/qa',
  
  // Coverage reporters
  coverageReporters: [
    'text',
    'lcov',
    'html',
    'json-summary'
  ],
  
  // Coverage thresholds for QA validation
  coverageThreshold: {
    global: {
      branches: 70,
      functions: 70,
      lines: 70,
      statements: 70
    },
    // CLI Provider specific thresholds
    './src/cli/': {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80
    },
    // CLI Provider core thresholds
    './src/cli/cliProvider.ts': {
      branches: 90,
      functions: 90,
      lines: 90,
      statements: 90
    },
    // Core IoC container thresholds
    './src/core/ioc/': {
      branches: 85,
      functions: 85,
      lines: 85,
      statements: 85
    }
  },
  
  // Clear mocks automatically
  clearMocks: true,
  
  // Restore mocks automatically
  restoreMocks: true,
  
  // Reset modules automatically
  resetModules: true,
  
  // Verbose output for detailed test information
  verbose: true,
  
  // Force exit after tests complete
  forceExit: true,
  
  // Detect open handles
  detectOpenHandles: true,
  
  // Global setup and teardown
  globalSetup: undefined,
  globalTeardown: undefined,
  
  // Error on deprecated features
  errorOnDeprecated: true,
  
  // Cache directory
  cacheDirectory: '<rootDir>/.jest-cache-qa',
  
  // Transform ignore patterns
  transformIgnorePatterns: [
    'node_modules/(?!(.*\\.mjs$))'
  ],
  
  // Watch plugins (for development)
  watchPlugins: [
    'jest-watch-typeahead/filename',
    'jest-watch-typeahead/testname'
  ],
  
  // Collect coverage from untested files
  collectCoverageOnlyFrom: {
    'src/cli/**/*.{ts,tsx}': true,
    'src/core/ioc/**/*.{ts,tsx}': true
  },
  
  // Maximum worker processes
  maxWorkers: '50%',
  
  // Notify of test results
  notify: false,
  
  // Bail on first test failure (for CI)
  bail: false,
  
  // Extra globals
  globals: {
    'ts-jest': {
      tsconfig: 'tsconfig.qa.json',
      isolatedModules: true
    }
  }
};

module.exports = config;
