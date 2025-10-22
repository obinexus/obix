/**
 * tests/qa/setup.js
 * 
 * QA Test Setup for OBIX CLI Provider Validation Framework
 * Configures testing environment for systematic CLI/Core integration validation
 * Implements collaborative testing utilities for waterfall methodology compliance
 * 
 * Copyright © 2025 OBINexus Computing
 */

// Extend Jest timeout for complex CLI Provider validation operations
jest.setTimeout(45000);

// Mock performance API for consistent testing across environments
if (typeof performance === 'undefined') {
  global.performance = {
    now: () => Date.now(),
    mark: () => {},
    measure: () => {},
    getEntriesByName: () => [],
    getEntriesByType: () => [],
    clearMarks: () => {},
    clearMeasures: () => {}
  };
}

// Mock process environment for CLI testing
if (typeof process.env.NODE_ENV === 'undefined') {
  process.env.NODE_ENV = 'test';
}

// CLI Provider testing globals
global.CLI_PROVIDER_TEST_MODE = true;
global.OBIX_QA_VALIDATION = true;

// Mock CLI output for testing
const originalConsole = { ...console };
global.mockConsoleOutput = () => {
  const logs = [];
  console.log = (...args) => logs.push(['log', ...args]);
  console.error = (...args) => logs.push(['error', ...args]);
  console.warn = (...args) => logs.push(['warn', ...args]);
  console.debug = (...args) => logs.push(['debug', ...args]);
  
  return {
    getLogs: () => logs,
    restore: () => {
      Object.assign(console, originalConsole);
    }
  };
};

// Extended custom matchers for CLI Provider validation
expect.extend({
  // Validation result matchers (extended from base setup)
  toBeValidResult(received) {
    const pass = received.isValid === true && received.errors.length === 0;
    return {
      pass,
      message: () => 
        pass ? 'Expected result to not be valid' : 'Expected result to be valid'
    };
  },
  
  toBeInvalidResult(received) {
    const pass = received.isValid === false && received.errors.length > 0;
    return {
      pass,
      message: () => 
        pass ? 'Expected result to not be invalid' : 'Expected result to be invalid'
    };
  },
  
  // CLI Provider specific matchers
  toHaveRegisteredService(provider, serviceName) {
    const services = provider.getServices();
    const pass = services.includes(serviceName);
    return {
      pass,
      message: () => 
        pass ? 
          `Expected provider not to have registered service '${serviceName}'` :
          `Expected provider to have registered service '${serviceName}'. Available services: ${services.join(', ')}`
    };
  },
  
  toHaveRegisteredDependency(provider, dependencyName) {
    const dependencies = provider.getDependencies();
    const pass = dependencies.includes(dependencyName);
    return {
      pass,
      message: () => 
        pass ? 
          `Expected provider not to have registered dependency '${dependencyName}'` :
          `Expected provider to have registered dependency '${dependencyName}'. Available dependencies: ${dependencies.join(', ')}`
    };
  },
  
  toExposeOBIXService(serviceExposure, servicePath) {
    const pathParts = servicePath.split('.');
    let current = serviceExposure;
    
    for (const part of pathParts) {
      if (current && typeof current === 'object' && part in current) {
        current = current[part];
      } else {
        current = undefined;
        break;
      }
    }
    
    const pass = current !== undefined;
    return {
      pass,
      message: () => 
        pass ? 
          `Expected service exposure not to contain path '${servicePath}'` :
          `Expected service exposure to contain path '${servicePath}'`
    };
  },
  
  toHaveCommandRegistered(registry, commandName) {
    const command = registry.getCommandByName(commandName);
    const pass = command !== undefined;
    return {
      pass,
      message: () => 
        pass ? 
          `Expected command registry not to have command '${commandName}'` :
          `Expected command registry to have command '${commandName}'`
    };
  },
  
  toBeInitialized(provider) {
    const pass = provider.isInitialized && provider.isInitialized();
    return {
      pass,
      message: () => 
        pass ? 
          'Expected provider not to be initialized' :
          'Expected provider to be initialized'
    };
  },
  
  toHaveValidConfiguration(provider, expectedConfig) {
    const actualConfig = provider.getConfiguration && provider.getConfiguration();
    if (!actualConfig) {
      return {
        pass: false,
        message: () => 'Expected provider to have configuration'
      };
    }
    
    const configMatches = Object.keys(expectedConfig).every(key => 
      actualConfig[key] === expectedConfig[key]
    );
    
    return {
      pass: configMatches,
      message: () => 
        configMatches ? 
          'Expected configuration not to match' :
          `Expected configuration to match. Expected: ${JSON.stringify(expectedConfig)}, Actual: ${JSON.stringify(actualConfig)}`
    };
  },
  
  // IoC Container specific matchers
  toHaveServiceInContainer(container, serviceName) {
    try {
      const service = container.get(serviceName);
      const pass = service !== undefined && service !== null;
      return {
        pass,
        message: () => 
          pass ? 
            `Expected container not to have service '${serviceName}'` :
            `Expected container to have service '${serviceName}'`
      };
    } catch (error) {
      return {
        pass: false,
        message: () => `Expected container to have service '${serviceName}', but got error: ${error.message}`
      };
    }
  },
  
  // Performance validation matchers
  toCompleteWithinTime(receivedPromise, maxTime) {
    const startTime = Date.now();
    
    return receivedPromise.then(
      (result) => {
        const executionTime = Date.now() - startTime;
        const pass = executionTime <= maxTime;
        
        return {
          pass,
          message: () => 
            pass ? 
              `Expected operation not to complete within ${maxTime}ms, but completed in ${executionTime}ms` :
              `Expected operation to complete within ${maxTime}ms, but took ${executionTime}ms`
        };
      },
      (error) => {
        return {
          pass: false,
          message: () => `Expected operation to complete but got error: ${error.message}`
        };
      }
    );
  },
  
  // Memory usage validation
  toNotLeakMemory(operation, maxMemoryIncrease = 1024 * 1024) { // 1MB default
    const initialMemory = process.memoryUsage().heapUsed;
    
    return Promise.resolve(operation()).then(() => {
      // Force garbage collection if available
      if (global.gc) {
        global.gc();
      }
      
      const finalMemory = process.memoryUsage().heapUsed;
      const memoryIncrease = finalMemory - initialMemory;
      const pass = memoryIncrease <= maxMemoryIncrease;
      
      return {
        pass,
        message: () => 
          pass ? 
            `Expected memory increase to be more than ${maxMemoryIncrease} bytes, but was ${memoryIncrease} bytes` :
            `Expected memory increase to be less than ${maxMemoryIncrease} bytes, but was ${memoryIncrease} bytes`
      };
    });
  }
});

// Mock factories for testing
global.createMockServiceContainer = () => {
  const services = new Map();
  
  return {
    register: (name, factory, options) => {
      services.set(name, { factory, options });
    },
    get: (name) => {
      const service = services.get(name);
      if (!service) {
        throw new Error(`Service '${name}' not found`);
      }
      return service.factory();
    },
    has: (name) => services.has(name),
    getRegisteredServices: () => Array.from(services.keys())
  };
};

global.createMockCommandRegistry = (container) => {
  const commands = new Map();
  
  return {
    registerCommand: (name, factory) => {
      commands.set(name, factory);
    },
    getCommandByName: (name) => {
      const factory = commands.get(name);
      return factory ? factory(container) : undefined;
    },
    getAllCommands: () => {
      return Array.from(commands.entries()).map(([name, factory]) => ({
        metadata: { name },
        execute: factory(container).execute || (() => {})
      }));
    },
    getCommandsByCategory: (category) => {
      return Array.from(commands.entries())
        .filter(([name, factory]) => {
          const command = factory(container);
          return command.metadata && command.metadata.category === category;
        })
        .map(([name, factory]) => factory(container));
    }
  };
};

// CLI Provider testing utilities
global.CLIProviderTestUtils = {
  createValidConfig: () => ({
    verbose: false,
    environment: 'testing',
    reactCompatibility: false,
    serviceOverrides: {},
    commandConfig: {
      validateCommands: true,
      executionTimeout: 30000
    }
  }),
  
  createMockCoreServices: (container) => {
    const mockServices = [
      'core.automaton.minimizer',
      'core.automaton.stateManager', 
      'core.automaton.transitionCache',
      'core.dop.adapter',
      'core.dop.behaviorModel',
      'core.dop.validationIntegrator',
      'core.parser.html',
      'core.parser.css',
      'core.parser.tokenizer',
      'core.validation.engine',
      'core.validation.ruleRegistry',
      'core.validation.errorHandler',
      'core.policy.ruleEngine',
      'core.policy.environmentManager',
      'core.policy.violationReporter',
      'core.ast.htmlOptimizer',
      'core.ast.cssOptimizer',
      'core.ast.nodeReducer'
    ];
    
    mockServices.forEach(serviceName => {
      const mockFunction = jest.fn();
      const mockService = { [serviceName.split('.').pop()]: mockFunction };
      container.register(serviceName, () => mockService);
    });
  },
  
  assertCLIProviderContract: (provider) => {
    expect(typeof provider.configure).toBe('function');
    expect(typeof provider.getServices).toBe('function');
    expect(typeof provider.getDependencies).toBe('function');
    expect(typeof provider.registerCommands).toBe('function');
    expect(typeof provider.initialize).toBe('function');
    expect(typeof provider.exposeOBIXServices).toBe('function');
  }
};

// React compatibility testing utilities
global.ReactCompatTestUtils = {
  mockReactEnvironment: () => {
    global.React = {
      createElement: jest.fn(),
      Fragment: 'Fragment'
    };
    
    global.ReactDOM = {
      render: jest.fn(),
      unmountComponentAtNode: jest.fn()
    };
  },
  
  restoreEnvironment: () => {
    delete global.React;
    delete global.ReactDOM;
  }
};

// Behavioral testing utilities  
global.BehavioralTestUtils = {
  assertBehavioralEquivalence: (functionalImpl, oopImpl, testData) => {
    const functionalResult = functionalImpl(testData);
    const oopResult = oopImpl(testData);
    
    expect(functionalResult).toEqual(oopResult);
  },
  
  assertStateConsistency: (stateMachine, operations) => {
    const initialState = stateMachine.getCurrentState();
    
    operations.forEach(operation => {
      const previousState = stateMachine.getCurrentState();
      operation(stateMachine);
      const currentState = stateMachine.getCurrentState();
      
      // Validate state transition consistency
      expect(currentState).toBeDefined();
      expect(typeof currentState).toBe(typeof previousState);
    });
  }
};

// Clean up between tests
beforeEach(() => {
  jest.clearAllMocks();
  jest.clearAllTimers();
});

afterEach(() => {
  // Clean up any global state
  delete global.testServiceContainer;
  delete global.testCommandRegistry;
  
  // Restore console if mocked
  if (global.mockConsoleOutput) {
    console.log = originalConsole.log;
    console.error = originalConsole.error;
    console.warn = originalConsole.warn;
    console.debug = originalConsole.debug;
  }
});

// Handle unhandled promise rejections in QA tests
process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Promise Rejection in QA test:', reason);
  console.error('Promise:', promise);
});

// Log QA setup completion
console.log('[QA Setup] OBIX CLI Provider QA validation environment initialized');
console.log('[QA Setup] Custom matchers and utilities registered');
console.log('[QA Setup] Test environment configured for waterfall methodology compliance');
