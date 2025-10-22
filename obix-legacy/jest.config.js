// jest.config.js - Consolidated OBIX Framework Test Configuration
// Addresses multiple configuration conflicts and architectural testing requirements

module.exports = {
  // Display name for test identification
  displayName: 'OBIX Framework',
  
  // Test environment configuration
  testEnvironment: 'node',
  
  // TypeScript support with ts-jest preset
  preset: 'ts-jest',
  
  // Test file discovery patterns
  testMatch: [
    '**/tests/**/*.test.ts',
    '**/tests/**/*.spec.ts',
    '**/__tests__/**/*.ts'
  ],
  
  // Ignore patterns for test discovery
  testPathIgnorePatterns: [
    '/node_modules/',
    '/dist/',
    '/build/',
    '/.obix-backups/'
  ],
  
  // Module resolution configuration
  moduleNameMapping: {
    '^@/(.*)$': '<rootDir>/src/$1',
    '^@core/(.*)$': '<rootDir>/src/core/$1',
    '^@parser/(.*)$': '<rootDir>/src/core/parser/$1',
    '^@validation/(.*)$': '<rootDir>/src/core/validation/$1',
    '^@dop/(.*)$': '<rootDir>/src/core/dop/$1',
    '^@ioc/(.*)$': '<rootDir>/src/core/ioc/$1'
  },
  
  // Setup files for test environment initialization
  setupFilesAfterEnv: [
    '<rootDir>/tests/setup/jest.setup.ts'
  ],
  
  // Coverage configuration for architectural compliance monitoring
  collectCoverage: true,
  coverageDirectory: 'coverage',
  coverageReporters: [
    'text',
    'text-summary',
    'html',
    'lcov',
    'json'
  ],
  
  // Coverage collection patterns
  collectCoverageFrom: [
    'src/**/*.ts',
    '!src/**/*.d.ts',
    '!src/**/*.test.ts',
    '!src/**/*.spec.ts',
    '!src/**/index.ts'
  ],
  
  // Coverage thresholds for quality gates
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 85,
      lines: 85,
      statements: 85
    },
    // Specific thresholds for critical modules
    'src/core/ioc/': {
      branches: 90,
      functions: 95,
      lines: 95,
      statements: 95
    },
    'src/core/validation/': {
      branches: 85,
      functions: 90,
      lines: 90,
      statements: 90
    }
  },
  
  // Test timeout configuration
  testTimeout: 10000,
  
  // Module file extensions
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx', 'json'],
  
  // Transform configuration for TypeScript
  transform: {
    '^.+\\.tsx?$': ['ts-jest', {
      tsconfig: 'tsconfig.json',
      isolatedModules: true
    }]
  },
  
  // Watch plugins (using available plugins only)
  watchPlugins: [
    'jest-watch-typeahead/filename',
    'jest-watch-typeahead/testname'
  ],
  
  // Reporter configuration for OBIX compliance tracking
  reporters: [
    'default',
    ['jest-junit', {
      outputDirectory: './reports/junit/',
      outputName: 'junit.xml',
      ancestorSeparator: ' › ',
      uniqueOutputName: 'false',
      suiteNameTemplate: '{title}',
      classNameTemplate: '{classname}',
      titleTemplate: '{title}'
    }]
  ],
  
  // Global test variables for OBIX context
  globals: {
    'ts-jest': {
      isolatedModules: true,
      tsconfig: 'tsconfig.json'
    },
    __OBIX_FRAMEWORK__: true,
    __SINPHASE_IOC__: true
  },
  
  // Verbose output for architectural violation tracking
  verbose: true,
  
  // Error handling configuration
  errorOnDeprecated: true,
  
  // Cache configuration
  cache: true,
  cacheDirectory: '<rootDir>/.jest-cache',
  
  // Clear mocks between tests
  clearMocks: true,
  
  // Test result processor for architectural compliance
  testResultsProcessor: '<rootDir>/tests/processors/architectural-compliance-processor.js'
};

// Architectural Testing Configuration
const architecturalTestConfig = {
  // Custom test suites for OBIX compliance
  projects: [
    {
      displayName: 'Unit Tests',
      testMatch: ['**/tests/unit/**/*.test.ts']
    },
    {
      displayName: 'Integration Tests',
      testMatch: ['**/tests/integration/**/*.test.ts']
    },
    {
      displayName: 'Architectural Compliance',
      testMatch: ['**/tests/architectural/**/*.test.ts'],
      coverageThreshold: {
        global: {
          branches: 95,
          functions: 100,
          lines: 100,
          statements: 100
        }
      }
    },
    {
      displayName: 'Sinphasé IoC Tests',
      testMatch: ['**/tests/ioc/**/*.test.ts'],
      setupFilesAfterEnv: ['<rootDir>/tests/setup/ioc.setup.ts']
    }
  ]
};

module.exports.architecturalTestConfig = architecturalTestConfig;