<<<<<<< HEAD
/**
 * OBIX Framework Compiler Compile Command
 * Refactored to use proper service abstraction and maintain DOP boundaries
 */

import { CompilerService, CompilerServiceOptions } from '@core/compiler';
import { ServiceContainer } from '@core/ioc/containers/ServiceContainer';

export interface CompileCommandOptions extends CompilerServiceOptions {
  // Command-specific options can extend service options
}

/**
 * Compile Command Implementation
 * Thin shell that delegates to service layer
 */
export class CompileCommand {
  private readonly compilerService: CompilerService;
  
  constructor(serviceContainer: ServiceContainer) {
    this.compilerService = serviceContainer.resolve('compilerService');
  }
  
  /**
   * Execute compile command
   */
  async execute(options: CompileCommandOptions = {}): Promise<void> {
    try {
      console.log(`Executing compiler compile operation...`);
      
      const result = await this.compilerService.execute(options);
      
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
export function createCompileCommand(serviceContainer: ServiceContainer): CompileCommand {
  return new CompileCommand(serviceContainer);
}
=======
/**
 * src/cli/compiler/commands/compile.ts
 * 
 * Command handler for compiler compile operation
 */

import { Command } from 'commander';
import { ServiceContainer } from '@core/ioc/containers/ServiceContainer';
import { CommandHandler } from '../../command/CommandRegistry';
import chalk from 'chalk';

/**
 * Command handler for compile
 */
export class CompileCommand implements CommandHandler {
  /**
   * Register the command with Commander
   * 
   * @param program Commander program
   * @param container Service container
   */
  public register(program: Command, container: ServiceContainer): void {
    program
      .command('compile')
      .description('compiler compile operation')
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
      console.log(chalk.green('Executing compiler compile command...'));
      
      // TODO: Implement command logic using services from container
      
    } catch (error) {
      console.error(chalk.red('Error executing compiler compile command:'), error);
    }
  }
}
>>>>>>> dev
