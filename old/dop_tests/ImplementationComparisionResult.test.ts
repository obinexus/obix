import { ImplementationComparisonResult, ImplementationDifference, ImplementationComparisonMetrics } from "@core/dop/ImplementationComparisonResult";
import { ImplementationMismatchError } from "@core/dop/ImplementationMismatchError";
import { ValidationResult } from "@core/dop/ValidationResult";
import { ErrorSeverity } from "@core/validation/errors/ErrorHandler";
import { TraceComparisonResult } from "@core/validation/errors/ExecutionTrace";


describe('ImplementationComparisonResult', () => {
  describe('Basic Functionality', () => {
    it('should initialize with default values', () => {
      const comparison = new ImplementationComparisonResult();
      
      expect(comparison.equivalent).toBe(true);
      expect(comparison.mismatches).toEqual([]);
      expect(comparison.summary).toEqual({}));
      expect(comparison.metrics).toBeDefined();
      expect(comparison.metrics.totalDifferences).toBe(0);
    }));
    
    it('should initialize with provided values', () => {
      const mismatch: ImplementationDifference = {
        path: 'test.path',
        expected: 'expected-value',
        actual: 'actual-value',
        message: 'Values differ',
        severity: ErrorSeverity.ERROR
      };
      
      const metrics: Partial<ImplementationComparisonMetrics> = {
        totalFunctionsCalled: 5,
        totalStateMutations: 3,
        comparisonTime: 100
      };
      
      const comparison = new ImplementationComparisonResult(
        false,
        [mismatch],
        { testSummary: 'test' },
        metrics
      );
      
      expect(comparison.equivalent).toBe(false);
      expect(comparison.mismatches).toEqual([mismatch]);
      expect(comparison.summary).toEqual({ testSummary: 'test' }));
      expect(comparison.metrics.totalFunctionsCalled).toBe(5);
      expect(comparison.metrics.totalStateMutations).toBe(3);
      expect(comparison.metrics.comparisonTime).toBe(100);
      expect(comparison.metrics.totalDifferences).toBe(1);
    }));
  }));
  
  describe('Report Generation', () => {
    it('should generate a success report when equivalent', () => {
      const comparison = new ImplementationComparisonResult(true);
      
      const report = comparison.generateReport();
      
      expect(report).toContain('passed');
      expect(report).toContain('equivalent');
    }));
    
    it('should generate a detailed failure report when not equivalent', () => {
      const mismatch: ImplementationDifference = {
        path: 'test.path',
        expected: 'expected-value',
        actual: 'actual-value',
        message: 'Values differ',
        severity: ErrorSeverity.ERROR
      };
      
      const summary = {
        thisResult: { isValid: true },
        otherResult: { isValid: false }
      };
      
      const comparison = new ImplementationComparisonResult(
        false,
        [mismatch],
        summary
      );
      
      const report = comparison.generateReport();
      
      expect(report).toContain('failed');
      expect(report).toContain('differ');
      expect(report).toContain('test.path');
      expect(report).toContain('expected-value');
      expect(report).toContain('actual-value');
      expect(report).toContain('ERROR');
      expect(report).toContain('Summary');
      expect(report).toContain('First implementation');
      expect(report).toContain('Second implementation');
      expect(report).toContain('Metrics');
    }));
  }));
  
  describe('Difference Visualization', () => {
    it('should return a simple message when equivalent', () => {
      const comparison = new ImplementationComparisonResult(true);
      
      const visualization = comparison.visualizeDifferences();
      
      expect(visualization).toContain('No differences to visualize');
    }));
    
    it('should generate a visual diff for string values', () => {
      const mismatch: ImplementationDifference = {
        path: 'string.value',
        expected: 'Hello',
        actual: 'Hallo',
        message: 'Greeting differs',
        severity: ErrorSeverity.WARNING
      };
      
      const comparison = new ImplementationComparisonResult(false, [mismatch]);
      
      const visualization = comparison.visualizeDifferences();
      
      expect(visualization).toContain('Implementation Difference Visualization');
      expect(visualization).toContain('string.value');
      expect(visualization).toContain('Hello');
      expect(visualization).toContain('Hallo');
      expect(visualization).toContain('Diff:');
      expect(visualization).toContain('^'); // Character difference indicator
    }));
    
    it('should visualize multiple mismatches', () => {
      const mismatches: ImplementationDifference[] = [
        {
          path: 'value1',
          expected: 10,
          actual: 20,
          message: 'Value1 differs',
          severity: ErrorSeverity.ERROR
        },
        {
          path: 'value2',
          expected: 'abc',
          actual: 'def',
          message: 'Value2 differs',
          severity: ErrorSeverity.WARNING
        }
      ];
      
      const comparison = new ImplementationComparisonResult(false, mismatches);
      
      const visualization = comparison.visualizeDifferences();
      
      expect(visualization).toContain('Mismatch #1');
      expect(visualization).toContain('Mismatch #2');
      expect(visualization).toContain('value1');
      expect(visualization).toContain('value2');
    }));
    
    it('should visualize trace divergences', () => {
      // Create trace comparison with divergence
      const valueDifferences = new Map<string, [any, any]>();
      valueDifferences.set('state.value', [10, 20]);
      
      const traceComparisons = [
        {
          index: 0,
          comparison: new TraceComparisonResult(
            false,
            ['state.value', 'method.result'],
            valueDifferences
          )
        }
      ];
      
      const comparison = new ImplementationComparisonResult(
        false,
        [],
        {},
        {},
        traceComparisons
      );
      
      const visualization = comparison.visualizeDifferences();
      
      expect(visualization).toContain('Execution Trace Divergences');
      expect(visualization).toContain('Trace #1');
      expect(visualization).toContain('Divergence points');
      expect(visualization).toContain('state.value');
      expect(visualization).toContain('method.result');
    }));
  }));
  
  describe('Validation Error Conversion', () => {
    it('should convert mismatches to implementation mismatch errors', () => {
      const mismatches: ImplementationDifference[] = [
        {
          path: 'value1',
          expected: 10,
          actual: 20,
          message: 'Value1 differs',
          severity: ErrorSeverity.ERROR
        },
        {
          path: 'value2',
          expected: true,
          actual: false,
          message: 'Value2 differs',
          severity: ErrorSeverity.WARNING
        }
      ];
      
      const comparison = new ImplementationComparisonResult(false, mismatches);
      
      const errors = comparison.toValidationErrors('TestComponent');
      
      expect(errors.length).toBe(2);
      expect(errors[0]).toBeInstanceOf(ImplementationMismatchError);
      expect(errors[0].message).toBe('Value1 differs');
      expect(errors[1].message).toBe('Value2 differs');
    }));
    
    it('should return an empty array when equivalent', () => {
      const comparison = new ImplementationComparisonResult(true);
      
      const errors = comparison.toValidationErrors('TestComponent');
      
      expect(errors).toEqual([]);
    }));
  }));
  
  describe('ValidationResult Conversion', () => {
    const component = 'TestComponent';
    const functionalImpl = 'functionalTest';
    const oopImpl = 'oopTest';

    it('should convert to ValidationResult when equivalent', () => {
      const result = new ImplementationComparisonResult(
        true, // equivalent
        [], // no mismatches
        {}, // empty summary
        {
          totalFunctionsCalled: 5,
          totalStateMutations: 2,
          totalPropertyAccesses: 10,
          totalDifferences: 0,
          comparisonTime: 100,
          tracesCompared: 1,
          tracesDiverged: 0
        }
      );

      const validationResult = result.toValidationResult(
        component,
        functionalImpl,
        oopImpl
      );

      expect(validationResult).toBeInstanceOf(ValidationResult);
      expect(validationResult.isValid).toBe(true);
      expect(validationResult.errors.length).toBe(0);
      expect(validationResult.metadata['implementationComparison']).toBeDefined();
    }));

    it('should convert to ValidationResult when not equivalent', () => {
      const mismatches = [{
        path: 'test.path',
        expected: 'expected value',
        actual: 'actual value',
        message: 'Test mismatch',
        severity: ErrorSeverity.ERROR,
        context: { test: 'context' }
      }];

      const result = new ImplementationComparisonResult(
        false, // not equivalent
        mismatches,
        { testSummary: 'test' },
        {
          totalFunctionsCalled: 5,
          totalStateMutations: 2,
          totalPropertyAccesses: 10,
          totalDifferences: 1,
          comparisonTime: 100,
          tracesCompared: 1,
          tracesDiverged: 1
        }
      );

      const validationResult = result.toValidationResult(
        component,
        functionalImpl,
        oopImpl
      );

      expect(validationResult).toBeInstanceOf(ValidationResult);
      expect(validationResult.isValid).toBe(false);
      expect(validationResult.errors.length).toBeGreaterThan(0);
      expect(validationResult.errors[0]).toBeInstanceOf(ImplementationMismatchError);
      expect(validationResult.metadata['implementationComparison']).toBeDefined();
      expect(validationResult.metadata['implementationComparison'].mismatches).toHaveLength(1);
    }));

    it('should include metadata in ValidationResult', () => {
      const result = new ImplementationComparisonResult(
        true,
        [],
        { summary: 'test' },
        {
          totalFunctionsCalled: 5,
          totalStateMutations: 2,
          totalPropertyAccesses: 10,
          totalDifferences: 0,
          comparisonTime: 100,
          tracesCompared: 1,
          tracesDiverged: 0
        }
      );

      const validationResult = result.toValidationResult(
        component,
        functionalImpl,
        oopImpl
      );

      const metadata = validationResult.metadata['implementationComparison'];
      expect(metadata).toBeDefined();
      expect(metadata.equivalent).toBe(true);
      expect(metadata.summary).toEqual({ summary: 'test' }));
      expect(metadata.metrics).toBeDefined();
      expect(metadata.metrics.totalFunctionsCalled).toBe(5);
    }));

    it('should preserve trace information', () => {
      const result = new ImplementationComparisonResult(
        true,
        [],
        {},
        {
          totalFunctionsCalled: 1,
          totalStateMutations: 0,
          totalPropertyAccesses: 1,
          totalDifferences: 0,
          comparisonTime: 50,
          tracesCompared: 1,
          tracesDiverged: 0
        }
      );

      const validationResult = result.toValidationResult(
        component,
        functionalImpl,
        oopImpl
      );

      expect(validationResult.traces).toBeDefined();
      expect(Array.isArray(validationResult.traces)).toBe(true);
    }));

    it('should convert error severity correctly', () => {
      const mismatches = [{
        path: 'test.path',
        expected: 'expected',
        actual: 'actual',
        message: 'Test error',
        severity: ErrorSeverity.WARNING,
        context: {}
      }];

      const result = new ImplementationComparisonResult(
        false,
        mismatches,
        {},
        { totalDifferences: 1 }
      );

      const validationResult = result.toValidationResult(
        component,
        functionalImpl,
        oopImpl
      );

      expect(validationResult.errors[0]).toBeDefined();
      expect(validationResult.errors[0].severity).toBe(ErrorSeverity.WARNING);
    }));
  }));
}));
  describe('Static Factory Methods', () => {
    it('should create from ValidationResult with comparison data', () => {
      // Create a validation result with implementation comparison metadata
      const validationResult = new ValidationResult(
        true,
        [],
        [],
        [],
        [],
        true,
        'FunctionalImpl',
        'OOPImpl'
      );
      
      validationResult.addMetadata('implementationComparison', {
        equivalent: true,
        summary: { testSummary: 'test' },
        metrics: { 
          totalFunctionsCalled: 5,
          totalStateMutations: 3,
          totalPropertyAccesses: 2,
          totalDifferences: 0,
          comparisonTime: 100,
          tracesCompared: 1,
          tracesDiverged: 0
        },
        mismatches: []
      }));
      
      const comparison = ImplementationComparisonResult.fromValidationResult(validationResult);
      
      expect(comparison).toBeInstanceOf(ImplementationComparisonResult);
      expect(comparison?.equivalent).toBe(true);
      expect(comparison?.summary).toEqual({ testSummary: 'test' }));
      expect(comparison?.metrics.totalFunctionsCalled).toBe(5);
    }));
    
    it('should return null when ValidationResult has no comparison data', () => {
      const validationResult = new ValidationResult(
        true,
        [],
        [],
        [],
        [],
        true
      );
      
      const comparison = ImplementationComparisonResult.fromValidationResult(validationResult);
      
      expect(comparison).toBeNull();
    }));
    
    it('should extract mismatches from validation errors', () => {
      const validationResult = new ValidationResult(
        false,
        [],
        [],
        [],
        [],
        false
      );
      
      // Create an implementation mismatch error
      const error = new ImplementationMismatchError(
        'IMPLEMENTATION_MISMATCH',
        'Test differs',
        'TestComponent',
        'FunctionalImpl',
        'OOPImpl',
        { expected: 10 },
        { actual: 20 },
        new Map([['test.path', [10, 20]]])
      );
      
      validationResult.addError(error);
      validationResult.addMetadata('implementationComparison', {
        equivalent: false,
        summary: {},
        metrics: {},
        mismatches: []
      }));
      
      const comparison = ImplementationComparisonResult.fromValidationResult(validationResult);
      
      expect(comparison).not.toBeNull();
      expect(comparison?.equivalent).toBe(false);
      expect(comparison?.mismatches.length).toBeGreaterThan(0);
      expect(comparison?.mismatches[0].path).toBe('test.path');
    }));
    
    it('should create from a plain object', () => {
      const obj = {
        equivalent: false,
        mismatches: [
          {
            path: 'test.path',
            expected: 10,
            actual: 20,
            message: 'Values differ',
            severity: ErrorSeverity.ERROR
          }
        ],
        summary: { testSummary: 'test' },
        metrics: {
          totalFunctionsCalled: 5,
          totalDifferences: 1
        },
        traceComparisons: [
          {
            index: 0,
            comparison: {
              equivalent: false,
              divergencePoints: ['test.point'],
              valueDifferences: {
                'test.point': [10, 20]
              }
            }
          }
        ]
      };
      
      const comparison = ImplementationComparisonResult.fromObject(obj);
      
      expect(comparison).toBeInstanceOf(ImplementationComparisonResult);
      expect(comparison.equivalent).toBe(false);
      expect(comparison.mismatches.length).toBe(1);
      expect(comparison.summary).toEqual({ testSummary: 'test' }));
      expect(comparison.metrics.totalFunctionsCalled).toBe(5);
    }));
  }));
  
  describe('Object Conversion', () => {
    it('should convert to a plain object', () => {
      const mismatch: ImplementationDifference = {
        path: 'test.path',
        expected: 'expected-value',
        actual: 'actual-value',
        message: 'Values differ',
        severity: ErrorSeverity.ERROR
      };
      
      const valueDifferences = new Map<string, [any, any]>();
      valueDifferences.set('state.value', [10, 20]);
      
      const traceComparisons = [
        {
          index: 0,
          comparison: new TraceComparisonResult(
            false,
            ['state.value'],
            valueDifferences
          )
        }
      ];
      
      const comparison = new ImplementationComparisonResult(
        false,
        [mismatch],
        { testSummary: 'test' },
        { totalFunctionsCalled: 5 },
        traceComparisons
      );
      
      const obj = comparison.toObject();
      
      expect(obj).toHaveProperty('equivalent', false);
      expect(obj).toHaveProperty('mismatches');
      expect(obj).toHaveProperty('summary');
      expect(obj).toHaveProperty('metrics');
      expect(obj).toHaveProperty('traceComparisons');
      expect(obj.mismatches[0].path).toBe('test.path');
      expect(obj.summary.testSummary).toBe('test');
      expect(obj.metrics.totalFunctionsCalled).toBe(5);
      expect(obj.traceComparisons[0].index).toBe(0);
    }));
  }));
  
  describe('Edge Cases', () => {
    it('should handle empty mismatches array', () => {
      const comparison = new ImplementationComparisonResult(false, []);
      
      const report = comparison.generateReport();
      const visualization = comparison.visualizeDifferences();
      
      expect(report).toContain('failed');
      expect(report).toContain('Found 0 mismatch(es)');
      expect(visualization).toContain('Implementation Difference Visualization');
    }));
    
    it('should handle null values in mismatches', () => {
      const mismatch: ImplementationDifference = {
        path: 'test.path',
        expected: null,
        actual: 'value',
        message: 'Values differ',
        severity: ErrorSeverity.ERROR
      };
      
      const comparison = new ImplementationComparisonResult(false, [mismatch]);
      
      const report = comparison.generateReport();
      const visualization = comparison.visualizeDifferences();
      
      expect(report).toContain('null');
      expect(report).toContain('value');
    }));
    
    it('should handle complex object values in mismatches', () => {
      const mismatch: ImplementationDifference = {
        path: 'test.path',
        expected: { nested: { value: 10 } },
        actual: { nested: { value: 20 } },
        message: 'Objects differ',
        severity: ErrorSeverity.ERROR
      };
      
      const comparison = new ImplementationComparisonResult(false, [mismatch]);
      
      const report = comparison.generateReport();
      
      expect(report).toContain('Objects differ');
      expect(report).toContain('nested');
      }));
      }));
    }));
