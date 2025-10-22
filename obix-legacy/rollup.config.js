// rollup.config.js - OBIX Single-Pass Architecture Build Configuration
import typescript from '@rollup/plugin-typescript';
import resolve from '@rollup/plugin-node-resolve';
import commonjs from '@rollup/plugin-commonjs';
import alias from '@rollup/plugin-alias';
import { readFileSync } from 'fs';
import path from 'path';

// IoC Container Configuration Loader
class OBIXConfigurationContainer {
  constructor() {
    this.serviceRegistry = new Map();
    this.configurationPaths = {
      core: 'src/core/ioc/providers',
      cli: 'src/cli',
      validation: 'src/core/validation',
      parser: 'src/core/parser',
      automaton: 'src/core/automaton',
      dop: 'src/core/dop'
    };
  }

  registerService(name, factory) {
    this.serviceRegistry.set(name, factory);
  }

  resolve(name) {
    const factory = this.serviceRegistry.get(name);
    if (!factory) {
      throw new Error(`Service '${name}' not registered in IoC container`);
    }
    return factory();
  }

  getModuleAliases() {
    return {
      '@obix/core': path.resolve('src/core'),
      '@obix/cli': path.resolve('src/cli'),
      '@obix/api': path.resolve('src/core/api'),
      '@obix/automaton': path.resolve('src/core/automaton'),
      '@obix/dop': path.resolve('src/core/dop'),
      '@obix/parser': path.resolve('src/core/parser'),
      '@obix/validation': path.resolve('src/core/validation'),
      '@obix/ast': path.resolve('src/core/ast'),
      '@obix/policy': path.resolve('src/core/policy'),
      '@obix/common': path.resolve('src/core/common')
    };
  }
}

// UML Relationship Mapping for Dependency Resolution
const UMLRelationshipTypes = {
  AGGREGATION: 'aggregation',      // "has-a" relationship, loose coupling
  COMPOSITION: 'composition',      // "part-of" relationship, tight coupling
  INHERITANCE: 'inheritance',      // "is-a" relationship, extends/implements
  DEPENDENCY: 'dependency',        // "uses-a" relationship, method parameters
  ASSOCIATION: 'association',      // "knows-about" relationship, references
  REALIZATION: 'realization'       // "implements" relationship, interface contracts
};

// Single-Pass Build Strategy Configuration
const createBuildConfiguration = () => {
  const container = new OBIXConfigurationContainer();
  
  // Register core services following DOP Adapter pattern
  container.registerService('StateMachineMinimizer', () => ({
    external: ['@obix/automaton/minimizer'],
    relationship: UMLRelationshipTypes.COMPOSITION
  }));
  
  container.registerService('DOPAdapter', () => ({
    external: ['@obix/dop/adapter'],
    relationship: UMLRelationshipTypes.AGGREGATION
  }));
  
  container.registerService('ValidationEngine', () => ({
    external: ['@obix/validation/engine'],
    relationship: UMLRelationshipTypes.DEPENDENCY
  }));

  return container;
};

// Core Package Configuration (Business Logic)
const createCoreConfig = (container) => ({
  input: 'src/core/index.ts',
  output: [
    {
      file: 'dist/core/index.cjs',
      format: 'cjs',
      exports: 'named',
      sourcemap: true
    },
    {
      file: 'dist/core/index.esm.js',
      format: 'esm',
      exports: 'named',
      sourcemap: true
    }
  ],
  external: [
    // Prevent bundling of CLI dependencies in core
    /^@obix\/cli/,
    // External dependencies
    'typescript',
    'fs',
    'path'
  ],
  plugins: [
    alias({
      entries: container.getModuleAliases()
    }),
    resolve({
      preferBuiltins: false,
      browser: false
    }),
    commonjs(),
    typescript({
      tsconfig: 'tsconfig.json',
      sourceMap: true,
      inlineSources: true,
      declaration: true,
      declarationDir: 'dist/core/types'
    })
  ],
  treeshake: {
    moduleSideEffects: false,
    propertyReadSideEffects: false,
    unknownGlobalSideEffects: false
  }
});

// CLI Package Configuration (Application Interface)
const createCLIConfig = (container) => ({
  input: 'src/cli/main.ts',
  output: {
    file: 'dist/cli/obix.cjs',
    format: 'cjs',
    banner: '#!/usr/bin/env node',
    sourcemap: true
  },
  external: [
    // Core should be external dependency for CLI
    /^@obix\/core/,
    // Node.js built-ins
    'fs',
    'path',
    'process',
    'os',
    'child_process'
  ],
  plugins: [
    alias({
      entries: {
        ...container.getModuleAliases(),
        // CLI-specific mappings
        '@obix/cli/commands': path.resolve('src/cli'),
        '@obix/cli/utils': path.resolve('src/cli/command')
      }
    }),
    resolve({
      preferBuiltins: true,
      browser: false
    }),
    commonjs(),
    typescript({
      tsconfig: 'tsconfig.cjs.json',
      sourceMap: true
    })
  ]
});

// Development Configuration (Hot Reload Support)
const createDevConfig = (container) => ({
  input: 'src/index.ts',
  output: {
    file: 'dist/dev/obix.dev.js',
    format: 'esm',
    sourcemap: true
  },
  plugins: [
    alias({
      entries: container.getModuleAliases()
    }),
    resolve(),
    commonjs(),
    typescript({
      tsconfig: 'tsconfig.json'
    })
  ],
  watch: {
    include: 'src/**',
    clearScreen: false
  }
});

// Main Configuration Factory
export default (commandLineArgs) => {
  const container = createBuildConfiguration();
  const isDevelopment = commandLineArgs.watch || process.env.NODE_ENV === 'development';
  
  // Single-pass build strategy: Core → CLI → Dev (no circular dependencies)
  const configurations = [
    createCoreConfig(container),
    createCLIConfig(container)
  ];
  
  if (isDevelopment) {
    configurations.push(createDevConfig(container));
  }
  
  return configurations;
};

// Export IoC container for external configuration
export { OBIXConfigurationContainer, UMLRelationshipTypes };
