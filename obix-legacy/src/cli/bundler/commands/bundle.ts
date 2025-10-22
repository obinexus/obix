<<<<<<< HEAD
/**
 * OBIX Framework Bundler Bundle Command
 * Refactored to use proper service abstraction and maintain DOP boundaries
 */

import { BundlerService, BundlerServiceOptions } from '@core/bundler';
import { ServiceContainer } from '@core/ioc/containers/ServiceContainer';

export interface BundleCommandOptions extends BundlerServiceOptions {
  // Command-specific options can extend service options
}

/**
 * Bundle Command Implementation
 * Thin shell that delegates to service layer
 */
export class BundleCommand {
  private readonly bundlerService: BundlerService;
  
  constructor(serviceContainer: ServiceContainer) {
    this.bundlerService = serviceContainer.resolve('bundlerService');
  }
  
  /**
   * Execute bundle command
   */
  async execute(options: BundleCommandOptions = {}): Promise<void> {
    try {
      console.log(`Executing bundler bundle operation...`);
      
      const result = await this.bundlerService.execute(options);
      
      if (result.success) {
        console.log(`✅ ${result.message}`);
        
        if (options.verbose && result.metrics) {
          console.log(`📊 Execution time: ${result.metrics.executionTime.toFixed(2)}ms`);
          console.log(`💾 Memory usage: ${(result.metrics.memoryUsage / 1024 / 1024).toFixed(2)}MB`);
        }
        
        if (result.data && options.verbose) {
          console.log(`📋 Result:`, JSON.stringify(result.data, null, 2));
        }
      } else {
        console.error(`❌ ${result.message}`);
        process.exit(1);
      }
      
    } catch (error) {
      console.error(`💥 Command execution failed:`, error instanceof Error ? error.message : 'Unknown error');
      process.exit(1);
    }
  }
}

/**
 * Command factory function
 */
export function createBundleCommand(serviceContainer: ServiceContainer): BundleCommand {
  return new BundleCommand(serviceContainer);
}
=======
/**
 * src/cli/bundler/commands/bundle.ts
 * 
 * Command handler for bundler bundle operation
 */

import { Command } from 'commander';
import { ServiceContainer } from '@core/ioc/containers/ServiceContainer';
import { CommandHandler } from '../../command/CommandRegistry';
import chalk from 'chalk';

/**
 * Command handler for bundle
 */
export class BundleCommand implements CommandHandler {
  /**
   * Register the command with Commander
   * 
   * @param program Commander program
   * @param container Service container
   */
  public register(program: Command, container: ServiceContainer): void {
    program
      .command('bundle')
      .description('bundler bundle operation')
      .action((options) => {
        this.execute(options, container);
      });
  }
  
  /**
   * Execute the command
   * 
   * @param options Command options
   * @param container Service container
   */
  private execute(options: any, container: ServiceContainer): void {
    try {
      console.log(chalk.green('Executing bundler bundle command...'));
      
      // TODO: Implement command logic using services from container
      
    } catch (error) {
      console.error(chalk.red('Error executing bundler bundle command:'), error);
    }
  }
}
>>>>>>> dev
