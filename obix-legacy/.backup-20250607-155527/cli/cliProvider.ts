/**
 * src/cli/cliProvider.ts
 * 
 * CLI Provider API for OBIX Framework
 * Exposes standardized OBIX services to CLI consumers
 * Implements IoC configuration logic for CLI command registration
 * 
 * Copyright © 2025 OBINexus Computing
 */

import { ServiceContainer } from '@core/ioc/containers/ServiceContainer';
import { CommandRegistry } from '@cli/command/CommandRegistry';

// CLI Command Imports
import { AnalyzeCommand } from '@cli/analyzer/commands/analyze';
import { MetricsCommand } from '@cli/analyzer/commands/metrics';
import { AnalyzeBundleCommand } from '@cli/bundler/commands/analyze-bundle';
import { BundleCommand } from '@cli/bundler/commands/bundle';
import { ClearCommand } from '@cli/cache/commands/clear';
import { StatusCommand } from '@cli/cache/commands/status';
import { CompileCommand } from '@cli/compiler/commands/compile';
import { WatchCommand } from '@cli/compiler/commands/watch';
import { MinifyCommand } from '@cli/minifier/commands/minify';
import { OptimizeCommand } from '@cli/minifier/commands/optimize';
import { ProfileCommand } from '@cli/profiler/commands/profile';
import { ReportCommand } from '@cli/profiler/commands/report';
import { HelloCommand } from '@cli/test-module/commands/hello';

/**
 * Interface for CLI Provider standardized API
 * Defines contract for CLI service exposure and IoC configuration
 */
export interface CLIProvider {
  /**
   * Configure CLI services in IoC container
   * @param container Service container for dependency injection
   */
  configure(container: ServiceContainer): void;
  
  /**
   * Get list of services provided by CLI module
   * @returns Array of service identifiers
   */
  getServices(): string[];
  
  /**
   * Get list of dependencies required by CLI module
   * @returns Array of dependency identifiers
   */
  getDependencies(): string[];
  
  /**
   * Register CLI commands with command registry
   * @param registry Command registry for CLI command registration
   */
  registerCommands(registry: CommandRegistry): void;
  
  /**
   * Initialize CLI provider with runtime configuration
   * @param config Runtime configuration options
   */
  initialize(config?: CLIProviderConfig): Promise<void>;
  
  /**
   * Expose OBIX services for CLI consumption
   * @returns Object containing exposed OBIX services
   */
  exposeOBIXServices(): CLIServiceExposure;
}

/**
 * Configuration interface for CLI Provider
 */
export interface CLIProviderConfig {
  /** Enable verbose logging for CLI operations */
  verbose?: boolean;
  
  /** Environment mode (development, production, testing) */
  environment?: 'development' | 'production' | 'testing';
  
  /** Enable React compatibility mode */
  reactCompatibility?: boolean;
  
  /** Custom service overrides */
  serviceOverrides?: Record<string, any>;
  
  /** CLI command configuration */
  commandConfig?: {
    /** Enable command validation */
    validateCommands?: boolean;
    /** Command execution timeout in milliseconds */
    executionTimeout?: number;
  };
}

/**
 * Interface for OBIX service exposure to CLI
 */
export interface CLIServiceExposure {
  /** Automaton state minimization services */
  automaton: {
    minimizer: any;
    stateManager: any;
    transitionCache: any;
  };
  
  /** DOP (Data-Oriented Programming) services */
  dop: {
    adapter: any;
    behaviorModel: any;
    validationIntegrator: any;
  };
  
  /** Parser services for HTML/CSS processing */
  parser: {
    htmlParser: any;
    cssParser: any;
    tokenizer: any;
  };
  
  /** Validation engine services */
  validation: {
    engine: any;
    ruleRegistry: any;
    errorHandler: any;
  };
  
  /** Policy engine services */
  policy: {
    ruleEngine: any;
    environmentManager: any;
    violationReporter: any;
  };
  
  /** AST optimization services */
  ast: {
    htmlOptimizer: any;
    cssOptimizer: any;
    nodeReducer: any;
  };
}

/**
 * CLI Provider implementation
 * Manages CLI service registration and OBIX service exposure
 */
export class CLIProviderImpl implements CLIProvider {
  private container: ServiceContainer | null = null;
  private config: CLIProviderConfig | null = null;
  private initialized = false;
  
  /**
   * Configure CLI services in IoC container
   */
  public configure(container: ServiceContainer): void {
    this.container = container;
    
    // Register CLI core services
    container.register('cli.provider', () => this);
    container.register('cli.commandRegistry', () => new CommandRegistry(container));
    
    // Register CLI service factories
    container.register('cli.services', () => ({
      analyzer: {
        analyze: () => new AnalyzeCommand(),
        metrics: () => new MetricsCommand()
      },
      bundler: {
        analyzeBundle: () => new AnalyzeBundleCommand(),
        bundle: () => new BundleCommand()
      },
      cache: {
        clear: () => new ClearCommand(),
        status: () => new StatusCommand()
      },
      compiler: {
        compile: () => new CompileCommand(),
        watch: () => new WatchCommand()
      },
      minifier: {
        minify: () => new MinifyCommand(),
        optimize: () => new OptimizeCommand()
      },
      profiler: {
        profile: () => new ProfileCommand(),
        report: () => new ReportCommand()
      },
      testModule: {
        hello: () => new HelloCommand()
      }
    }));
    
    // Register CLI utility services
    container.register('cli.logger', () => this.createLogger());
    container.register('cli.validator', () => this.createValidator());
    container.register('cli.errorHandler', () => this.createErrorHandler());
  }
  
  /**
   * Get list of services provided by CLI module
   */
  public getServices(): string[] {
    return [
      'cli.provider',
      'cli.commandRegistry',
      'cli.services',
      'cli.logger',
      'cli.validator',
      'cli.errorHandler',
      'cli.analyzer.analyze',
      'cli.analyzer.metrics',
      'cli.bundler.analyzeBundle',
      'cli.bundler.bundle',
      'cli.cache.clear',
      'cli.cache.status',
      'cli.compiler.compile',
      'cli.compiler.watch',
      'cli.minifier.minify',
      'cli.minifier.optimize',
      'cli.profiler.profile',
      'cli.profiler.report',
      'cli.testModule.hello'
    ];
  }
  
  /**
   * Get list of dependencies required by CLI module
   */
  public getDependencies(): string[] {
    return [
      'core.automaton.minimizer',
      'core.dop.adapter',
      'core.parser.html',
      'core.parser.css',
      'core.validation.engine',
      'core.policy.ruleEngine',
      'core.ast.htmlOptimizer',
      'core.ast.cssOptimizer',
      'core.ioc.container'
    ];
  }
  
  /**
   * Register CLI commands with command registry
   */
  public registerCommands(registry: CommandRegistry): void {
    // Analyzer commands
    registry.registerCommand('analyze', (container) => new AnalyzeCommand());
    registry.registerCommand('metrics', (container) => new MetricsCommand());
    
    // Bundler commands
    registry.registerCommand('analyze-bundle', (container) => new AnalyzeBundleCommand());
    registry.registerCommand('bundle', (container) => new BundleCommand());
    
    // Cache commands
    registry.registerCommand('clear', (container) => new ClearCommand());
    registry.registerCommand('status', (container) => new StatusCommand());
    
    // Compiler commands
    registry.registerCommand('compile', (container) => new CompileCommand());
    registry.registerCommand('watch', (container) => new WatchCommand());
    
    // Minifier commands
    registry.registerCommand('minify', (container) => new MinifyCommand());
    registry.registerCommand('optimize', (container) => new OptimizeCommand());
    
    // Profiler commands
    registry.registerCommand('profile', (container) => new ProfileCommand());
    registry.registerCommand('report', (container) => new ReportCommand());
    
    // Test module commands
    registry.registerCommand('hello', (container) => new HelloCommand());
  }
  
  /**
   * Initialize CLI provider with runtime configuration
   */
  public async initialize(config: CLIProviderConfig = {}): Promise<void> {
    this.config = {
      verbose: false,
      environment: 'development',
      reactCompatibility: false,
      serviceOverrides: {},
      commandConfig: {
        validateCommands: true,
        executionTimeout: 30000
      },
      ...config
    };
    
    if (this.config.verbose) {
      console.log('[CLI Provider] Initializing with config:', this.config);
    }
    
    // Validate dependencies if enabled
    if (this.config.commandConfig?.validateCommands) {
      await this.validateDependencies();
    }
    
    this.initialized = true;
    
    if (this.config.verbose) {
      console.log('[CLI Provider] Initialization complete');
    }
  }
  
  /**
   * Expose OBIX services for CLI consumption
   */
  public exposeOBIXServices(): CLIServiceExposure {
    if (!this.container) {
      throw new Error('CLI Provider not configured. Call configure() first.');
    }
    
    try {
      return {
        automaton: {
          minimizer: this.container.get('core.automaton.minimizer'),
          stateManager: this.container.get('core.automaton.stateManager'),
          transitionCache: this.container.get('core.automaton.transitionCache')
        },
        dop: {
          adapter: this.container.get('core.dop.adapter'),
          behaviorModel: this.container.get('core.dop.behaviorModel'),
          validationIntegrator: this.container.get('core.dop.validationIntegrator')
        },
        parser: {
          htmlParser: this.container.get('core.parser.html'),
          cssParser: this.container.get('core.parser.css'),
          tokenizer: this.container.get('core.parser.tokenizer')
        },
        validation: {
          engine: this.container.get('core.validation.engine'),
          ruleRegistry: this.container.get('core.validation.ruleRegistry'),
          errorHandler: this.container.get('core.validation.errorHandler')
        },
        policy: {
          ruleEngine: this.container.get('core.policy.ruleEngine'),
          environmentManager: this.container.get('core.policy.environmentManager'),
          violationReporter: this.container.get('core.policy.violationReporter')
        },
        ast: {
          htmlOptimizer: this.container.get('core.ast.htmlOptimizer'),
          cssOptimizer: this.container.get('core.ast.cssOptimizer'),
          nodeReducer: this.container.get('core.ast.nodeReducer')
        }
      };
    } catch (error) {
      throw new Error(`Failed to expose OBIX services: ${error instanceof Error ? error.message : String(error)}`);
    }
  }
  
  /**
   * Create logger service for CLI operations
   */
  private createLogger() {
    return {
      log: (message: string) => {
        if (this.config?.verbose) {
          console.log(`[CLI] ${message}`);
        }
      },
      error: (message: string) => {
        console.error(`[CLI Error] ${message}`);
      },
      warn: (message: string) => {
        console.warn(`[CLI Warning] ${message}`);
      },
      debug: (message: string) => {
        if (this.config?.verbose) {
          console.debug(`[CLI Debug] ${message}`);
        }
      }
    };
  }
  
  /**
   * Create validator service for CLI operations
   */
  private createValidator() {
    return {
      validateCommand: (commandName: string) => {
        const services = this.getServices();
        const commandServiceName = `cli.${commandName.replace('-', '.')}`;
        return services.includes(commandServiceName);
      },
      validateConfiguration: (config: CLIProviderConfig) => {
        const validEnvironments = ['development', 'production', 'testing'];
        return validEnvironments.includes(config.environment || 'development');
      }
    };
  }
  
  /**
   * Create error handler service for CLI operations
   */
  private createErrorHandler() {
    return {
      handleError: (error: Error, context: string) => {
        console.error(`[CLI Error in ${context}] ${error.message}`);
        if (this.config?.verbose) {
          console.error(error.stack);
        }
      },
      handleValidationError: (error: Error, commandName: string) => {
        console.error(`[CLI Validation Error in ${commandName}] ${error.message}`);
      }
    };
  }
  
  /**
   * Validate CLI dependencies
   */
  private async validateDependencies(): Promise<void> {
    if (!this.container) {
      throw new Error('Container not available for dependency validation');
    }
    
    const dependencies = this.getDependencies();
    const missingDependencies: string[] = [];
    
    for (const dependency of dependencies) {
      try {
        this.container.get(dependency);
      } catch (error) {
        missingDependencies.push(dependency);
      }
    }
    
    if (missingDependencies.length > 0) {
      throw new Error(`Missing CLI dependencies: ${missingDependencies.join(', ')}`);
    }
  }
  
  /**
   * Check if CLI provider is initialized
   */
  public isInitialized(): boolean {
    return this.initialized;
  }
  
  /**
   * Get current configuration
   */
  public getConfiguration(): CLIProviderConfig | null {
    return this.config;
  }
}

/**
 * Factory function for creating CLI Provider instance
 */
export function createCLIProvider(): CLIProvider {
  return new CLIProviderImpl();
}

/**
 * Default CLI Provider instance for immediate use
 */
export const cliProvider = createCLIProvider();

/**
 * Legacy compatibility export
 * @deprecated Use CLIProvider interface instead
 */
export { CLIProvider as cliProvider };
export { CLIProviderImpl as cliProviderImpl };
