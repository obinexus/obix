/**
 * OBIX Framework Policy Set-environment Command
 * Refactored to use proper service abstraction and maintain DOP boundaries
 */

import { PolicyService, PolicyServiceOptions } from '@core/policy';
import { ServiceContainer } from '@core/ioc/containers/ServiceContainer';

export interface Set-environmentCommandOptions extends PolicyServiceOptions {
  // Command-specific options can extend service options
}

/**
 * Set-environment Command Implementation
 * Thin shell that delegates to service layer
 */
export class Set-environmentCommand {
  private readonly policyService: PolicyService;
  
  constructor(serviceContainer: ServiceContainer) {
    this.policyService = serviceContainer.resolve('policyService');
  }
  
  /**
   * Execute set-environment command
   */
  async execute(options: Set-environmentCommandOptions = {}): Promise<void> {
    try {
      console.log(`Executing policy set-environment operation...`);
      
      const result = await this.policyService.execute(options);
      
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
export function createSet-environmentCommand(serviceContainer: ServiceContainer): Set-environmentCommand {
  return new Set-environmentCommand(serviceContainer);
}
