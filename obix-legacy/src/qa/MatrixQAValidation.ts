export interface MatrixQAValidation {
  testMatrix: {
    TP: number;
    TN: number;
    FP: number;
    FN: number;
  };
  qualityMetrics: {
    accuracy: number;
    precision: number;
    recall: number;
    f1Score: number;
  };
  sinphaseCompliance: {
    costThresholdCompliance: boolean;
    circularDependencyFree: boolean;
    phaseIsolationMaintained: boolean;
  };
}
