/**
 * OBIX Framework Policy List-rules Command
 * Refactored to use proper service abstraction and maintain DOP boundaries
 */

import { PolicyService, PolicyServiceOptions } from '@core/policy';
import { ServiceContainer } from '@core/ioc/containers/ServiceContainer';

export interface List-rulesCommandOptions extends PolicyServiceOptions {
  // Command-specific options can extend service options
}

/**
 * List-rules Command Implementation
 * Thin shell that delegates to service layer
 */
export class List-rulesCommand {
  private readonly policyService: PolicyService;
  
  constructor(serviceContainer: ServiceContainer) {
    this.policyService = serviceContainer.resolve('policyService');
  }
  
  /**
   * Execute list-rules command
   */
  async execute(options: List-rulesCommandOptions = {}): Promise<void> {
    try {
      console.log(`Executing policy list-rules operation...`);
      
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
export function createList-rulesCommand(serviceContainer: ServiceContainer): List-rulesCommand {
  return new List-rulesCommand(serviceContainer);
}
