<<<<<<< HEAD
/**
 * OBIX Framework Cache Status Command
 * Refactored to use proper service abstraction and maintain DOP boundaries
 */

import { CacheService, CacheServiceOptions } from '@core/cache';
import { ServiceContainer } from '@core/ioc/containers/ServiceContainer';

export interface StatusCommandOptions extends CacheServiceOptions {
  // Command-specific options can extend service options
}

/**
 * Status Command Implementation
 * Thin shell that delegates to service layer
 */
export class StatusCommand {
  private readonly cacheService: CacheService;
  
  constructor(serviceContainer: ServiceContainer) {
    this.cacheService = serviceContainer.resolve('cacheService');
  }
  
  /**
   * Execute status command
   */
  async execute(options: StatusCommandOptions = {}): Promise<void> {
    try {
      console.log(`Executing cache status operation...`);
      
      const result = await this.cacheService.execute(options);
      
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
export function createStatusCommand(serviceContainer: ServiceContainer): StatusCommand {
  return new StatusCommand(serviceContainer);
}
=======
/**
 * src/cli/cache/commands/status.ts
 * 
 * Command handler for cache status operation
 */

import { Command } from 'commander';
import { ServiceContainer } from '@core/ioc/containers/ServiceContainer';
import { CommandHandler } from '../../command/CommandRegistry';
import chalk from 'chalk';

/**
 * Command handler for status
 */
export class StatusCommand implements CommandHandler {
  /**
   * Register the command with Commander
   * 
   * @param program Commander program
   * @param container Service container
   */
  public register(program: Command, container: ServiceContainer): void {
    program
      .command('status')
      .description('cache status operation')
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
      console.log(chalk.green('Executing cache status command...'));
      
      // TODO: Implement command logic using services from container
      
    } catch (error) {
      console.error(chalk.red('Error executing cache status command:'), error);
    }
  }
}
>>>>>>> dev
