<<<<<<< HEAD
/**
 * OBIX Framework Profiler Report Command
 * Refactored to use proper service abstraction and maintain DOP boundaries
 */

import { ProfilerService, ProfilerServiceOptions } from '@core/profiler';
import { ServiceContainer } from '@core/ioc/containers/ServiceContainer';

export interface ReportCommandOptions extends ProfilerServiceOptions {
  // Command-specific options can extend service options
}

/**
 * Report Command Implementation
 * Thin shell that delegates to service layer
 */
export class ReportCommand {
  private readonly profilerService: ProfilerService;
  
  constructor(serviceContainer: ServiceContainer) {
    this.profilerService = serviceContainer.resolve('profilerService');
  }
  
  /**
   * Execute report command
   */
  async execute(options: ReportCommandOptions = {}): Promise<void> {
    try {
      console.log(`Executing profiler report operation...`);
      
      const result = await this.profilerService.execute(options);
      
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
export function createReportCommand(serviceContainer: ServiceContainer): ReportCommand {
  return new ReportCommand(serviceContainer);
}
=======
/**
 * src/cli/profiler/commands/report.ts
 * 
 * Command handler for profiler report operation
 */

import { Command } from 'commander';
import { ServiceContainer } from '@core/ioc/containers/ServiceContainer';
import { CommandHandler } from '../../command/CommandRegistry';
import chalk from 'chalk';

/**
 * Command handler for report
 */
export class ReportCommand implements CommandHandler {
  /**
   * Register the command with Commander
   * 
   * @param program Commander program
   * @param container Service container
   */
  public register(program: Command, container: ServiceContainer): void {
    program
      .command('report')
      .description('profiler report operation')
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
      console.log(chalk.green('Executing profiler report command...'));
      
      // TODO: Implement command logic using services from container
      
    } catch (error) {
      console.error(chalk.red('Error executing profiler report command:'), error);
    }
  }
}
>>>>>>> dev
