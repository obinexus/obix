/**
 * OBIX Framework Compiler Watch Command
 * Refactored to use proper service abstraction and maintain DOP boundaries
 */

import { CompilerService, CompilerServiceOptions } from '@core/compiler';
import { ServiceContainer } from '@core/ioc/containers/ServiceContainer';

export interface WatchCommandOptions extends CompilerServiceOptions {
  // Command-specific options can extend service options
}

/**
 * Watch Command Implementation
 * Thin shell that delegates to service layer
 */
export class WatchCommand {
  private readonly compilerService: CompilerService;
  
  constructor(serviceContainer: ServiceContainer) {
    this.compilerService = serviceContainer.resolve('compilerService');
  }
  
  /**
   * Execute watch command
   */
  async execute(options: WatchCommandOptions = {}): Promise<void> {
    try {
      console.log(`Executing compiler watch operation...`);
      
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
export function createWatchCommand(serviceContainer: ServiceContainer): WatchCommand {
  return new WatchCommand(serviceContainer);
}
