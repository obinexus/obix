

import { ServiceContainer } from '@core/ioc/containers/ServiceContainer';
import { MatrixQAValidation } from '@qa/MatrixQAValidation';

export interface CLIConsumer<T> {
  execute(): Promise<T>;
  validateQAMatrix(): MatrixQAValidation;
}

export abstract class CLIModuleConsumer<T> implements CLIConsumer<T> {
  constructor(protected readonly coreService: any) {}

  abstract execute(): Promise<T>;

  validateQAMatrix(): MatrixQAValidation {
    return {
      testMatrix: { TP: 0, TN: 0, FP: 0, FN: 0 },
      qualityMetrics: { accuracy: 0, precision: 0, recall: 0, f1Score: 0 },
      sinphaseCompliance: {
        costThresholdCompliance: true,
        circularDependencyFree: true,
        phaseIsolationMaintained: true,
      },
    };
  }
}
