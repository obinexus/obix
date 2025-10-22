export interface CoreToCliIoCContract {
  coreServices: {
    automatonProvider: unknown;
    astProvider: unknown;
    dopProvider: unknown;
    validationProvider: unknown;
    policyProvider: unknown;
  };
  cliConsumers: {
    compilerConsumer: unknown;
    analyzerConsumer: unknown;
    minifierConsumer: unknown;
    profilerConsumer: unknown;
    policyConsumer: unknown;
  };
  sinphaseGovernance: {
    maxComplexityThreshold: number;
    circularDependencyPenalty: number;
    temporalPressureLimit: number;
    isolationTriggerPoint: number;
  };
}
