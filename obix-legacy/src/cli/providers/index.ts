/**
 * src/cli/providers/index.ts
 * 
 * Standardized CLI Provider Interface Exposure
 * Implements systematic OBIX service registration and command orchestration
 * Supports waterfall methodology with structured API contracts
 * 
 * Copyright © 2025 OBINexus Computing
 */

export { 
  CLIProvider, 
  CLIProviderImpl, 
  CLIProviderConfig,
  CLIServiceExposure,
  createCLIProvider,
  cliProvider 
} from '../cliProvider';

// Re-export command interfaces for CLI consumer integration
export { CommandHandler, CommandRegistry, BaseCommand } from '@cli/command/CommandRegistry';

// Expose CLI service factories for external consumption
export { AnalyzeCommand } from '@cli/analyzer/commands/analyze';
export { MetricsCommand } from '@cli/analyzer/commands/metrics';
export { AnalyzeBundleCommand } from '@cli/bundler/commands/analyze-bundle';
export { BundleCommand } from '@cli/bundler/commands/bundle';
export { ClearCommand } from '@cli/cache/commands/clear';
export { StatusCommand } from '@cli/cache/commands/status';
export { CompileCommand } from '@cli/compiler/commands/compile';
export { WatchCommand } from '@cli/compiler/commands/watch';
export { MinifyCommand } from '@cli/minifier/commands/minify';
export { OptimizeCommand } from '@cli/minifier/commands/optimize';
export { ProfileCommand } from '@cli/profiler/commands/profile';
export { ReportCommand } from '@cli/profiler/commands/report';
export { HelloCommand } from '@cli/test-module/commands/hello';

/**
 * CLI Module Metadata for systematic registration
 */
export const CLI_MODULE_METADATA = {
  moduleName: 'cli',
  version: '0.1.0',
  priority: 1,
  dependencies: [
    'core.automaton',
    'core.dop',
    'core.parser',
    'core.validation',
    'core.policy',
    'core.ast'
  ],
  services: [
    'cli.provider',
    'cli.commandRegistry',
    'cli.services'
  ],
  commands: [
    'analyze',
    'metrics',
    'analyze-bundle', 
    'bundle',
    'clear',
    'status',
    'compile',
    'watch',
    'minify',
    'optimize',
    'profile',
    'report',
    'hello'
  ]
} as const;

/**
 * Default export for immediate CLI provider access
 */
export default {
  ...CLI_MODULE_METADATA,
  provider: cliProvider
};
