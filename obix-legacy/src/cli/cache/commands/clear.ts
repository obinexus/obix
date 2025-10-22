<<<<<<< HEAD
/**
 * OBIX Framework Cache Clear Command
 * Refactored to use proper service abstraction and maintain DOP boundaries
 */

import { CacheService, CacheServiceOptions } from '@core/cache';
import { ServiceContainer } from '@core/ioc/containers/ServiceContainer';

export interface ClearCommandOptions extends CacheServiceOptions {
  // Command-specific options can extend service options
}

/**
 * Clear Command Implementation
 * Thin shell that delegates to service layer
 */
export class ClearCommand {
  private readonly cacheService: CacheService;
  
  constructor(serviceContainer: ServiceContainer) {
    this.cacheService = serviceContainer.resolve('cacheService');
  }
  
  /**
   * Execute clear command
   */
  async execute(options: ClearCommandOptions = {}): Promise<void> {
    try {
      console.log(`Executing cache clear operation...`);
      
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
export function createClearCommand(serviceContainer: ServiceContainer): ClearCommand {
  return new ClearCommand(serviceContainer);
}
=======
/**
 * src/cli/cache/commands/clear.ts
 * 
 * Command handler for cache clear operation
 */

import { Command } from 'commander';
import { ServiceContainer } from '@core/ioc/containers/ServiceContainer';
import { CommandHandler } from '../../command/CommandRegistry';
import chalk from 'chalk';

/**
 * Command handler for clear
 */
export class ClearCommand implements CommandHandler {
  /**
   * Register the command with Commander
   * 
   * @param program Commander program
   * @param container Service container
   */
  public register(program: Command, container: ServiceContainer): void {
    program
      .command('clear')
      .description('cache clear operation')
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
      console.log(chalk.green('Executing cache clear command...'));
      
      // TODO: Implement command logic using services from container
      
    } catch (error) {
      console.error(chalk.red('Error executing cache clear command:'), error);
    }
  }
}
>>>>>>> dev
