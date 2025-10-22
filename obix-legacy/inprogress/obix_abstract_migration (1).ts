/**
 * OBIX Abstract Class Migration Strategy
 * Converts abstract inheritance patterns to concrete implementations
 * Maintains functional equivalence while satisfying architectural requirements
 */

// BEFORE: Abstract inheritance pattern (VIOLATION)
abstract class BaseValidationRule {
  abstract validate(input: any): boolean;
  protected formatError(message: string): string {
    return `Validation Error: ${message}`;
  }
}

// AFTER: Concrete implementation with composition (COMPLIANT)
interface ValidationRuleContract {
  validate(input: any): boolean;
  formatError(message: string): string;
}

class ValidationRuleImpl implements ValidationRuleContract {
  constructor(
    private validator: (input: any) => boolean,
    private errorFormatter: (message: string) => string = (msg) => `Validation Error: ${msg}`
  ) {}
  
  public validate(input: any): boolean {
    return this.validator(input);
  }
  
  public formatError(message: string): string {
    return this.errorFormatter(message);
  }
}

// Factory pattern for rule creation (maintains polymorphism without inheritance)
export class ValidationRuleFactory {
  public static createRule(
    type: 'email' | 'required' | 'minLength',
    options?: any
  ): ValidationRuleContract {
    switch (type) {
      case 'email':
        return new ValidationRuleImpl(
          (input) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(input),
          (msg) => `Email Validation: ${msg}`
        );
      case 'required':
        return new ValidationRuleImpl(
          (input) => input != null && input !== '',
          (msg) => `Required Field: ${msg}`
        );
      case 'minLength':
        return new ValidationRuleImpl(
          (input) => input && input.length >= (options?.min || 1),
          (msg) => `Length Validation: ${msg}`
        );
      default:
        throw new Error(`Unknown validation rule type: ${type}`);
    }
  }
}

// Migration template for DOPAdapter pattern
interface DOPAdapterContract<T, R> {
  adapt(input: T): R;
  clearCache(): void;
}

class ConcreteDOPAdapter<T, R> implements DOPAdapterContract<T, R> {
  constructor(
    private adaptationLogic: (input: T) => R,
    private cacheManager: Map<string, R> = new Map()
  ) {}
  
  public adapt(input: T): R {
    const key = JSON.stringify(input);
    if (this.cacheManager.has(key)) {
      return this.cacheManager.get(key)!;
    }
    
    const result = this.adaptationLogic(input);
    this.cacheManager.set(key, result);
    return result;
  }
  
  public clearCache(): void {
    this.cacheManager.clear();
  }
}

// Migration template for Parser hierarchies
interface ParserContract<T> {
  parse(input: string): T;
  validate(input: string): boolean;
}

class ConcreteParserImpl<T> implements ParserContract<T> {
  constructor(
    private parseLogic: (input: string) => T,
    private validationLogic: (input: string) => boolean
  ) {}
  
  public parse(input: string): T {
    if (!this.validate(input)) {
      throw new Error('Invalid input for parsing');
    }
    return this.parseLogic(input);
  }
  
  public validate(input: string): boolean {
    return this.validationLogic(input);
  }
}

// Migration utility for processor patterns
interface ProcessorContract<T, R> {
  process(input: T): R;
  canProcess(input: T): boolean;
}

class ConcreteProcessorImpl<T, R> implements ProcessorContract<T, R> {
  constructor(
    private processLogic: (input: T) => R,
    private canProcessLogic: (input: T) => boolean = () => true
  ) {}
  
  public process(input: T): R {
    if (!this.canProcess(input)) {
      throw new Error('Input cannot be processed by this processor');
    }
    return this.processLogic(input);
  }
  
  public canProcess(input: T): boolean {
    return this.canProcessLogic(input);
  }
}

/**
 * MIGRATION CHECKLIST:
 * 
 * 1. Replace abstract classes with interfaces + concrete implementations
 * 2. Use composition over inheritance for shared functionality
 * 3. Implement factory patterns for polymorphic creation
 * 4. Maintain contracts through interfaces, not abstract methods
 * 5. Ensure all dependencies are concrete and injectable
 * 
 * PRIORITY FILES FOR MIGRATION:
 * - src/core/validation/rules/ValidationRule.ts
 * - src/core/dop/factory/DOPAdapterFactory.ts  
 * - src/core/parser/html/processors/HTMLProcessor.ts
 * - src/core/parser/html/readers/HTMLReader.ts
 * - src/core/vdom/VirtualDOM.ts
 */