<<<<<<< HEAD
/**
 * OBIX Framework Analyzer Analyze Command
 * Refactored to use proper service abstraction and maintain DOP boundaries
 */

import { AnalyzerService, AnalyzerServiceOptions } from '@core/analyzer';
import { ServiceContainer } from '@core/ioc/containers/ServiceContainer';

export interface AnalyzeCommandOptions extends AnalyzerServiceOptions {
  // Command-specific options can extend service options
}

/**
 * Analyze Command Implementation
 * Thin shell that delegates to service layer
 */
export class AnalyzeCommand {
  private readonly analyzerService: AnalyzerService;
  
  constructor(serviceContainer: ServiceContainer) {
    this.analyzerService = serviceContainer.resolve('analyzerService');
  }
  
  /**
   * Execute analyze command
   */
  async execute(options: AnalyzeCommandOptions = {}): Promise<void> {
    try {
      console.log(`Executing analyzer analyze operation...`);
      
      const result = await this.analyzerService.execute(options);
      
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
export function createAnalyzeCommand(serviceContainer: ServiceContainer): AnalyzeCommand {
  return new AnalyzeCommand(serviceContainer);
}
=======
/**
 * src/cli/analyzer/commands/analyze.ts
 * 
 * Command handler for analyzer analyze operation
 */

import { Command } from 'commander';
import { ServiceContainer } from '@core/ioc/containers/ServiceContainer';
import { CommandHandler } from '../../command/CommandRegistry';
import chalk from 'chalk';

/**
 * Command handler for analyze
 */
export class AnalyzeCommand implements CommandHandler {
  /**
   * Register the command with Commander
   * 
   * @param program Commander program
   * @param container Service container
   */
  public register(program: Command, container: ServiceContainer): void {
    program
      .command('analyze')
      .description('analyzer analyze operation')
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
      console.log(chalk.green('Executing analyzer analyze command...'));
      
      // TODO: Implement command logic using services from container
      
    } catch (error) {
      console.error(chalk.red('Error executing analyzer analyze command:'), error);
    }
  }
}
>>>>>>> dev
