import { ImplementationComparisonResult } from "@core/dop/ImplementationComparisonResult";
import { ValidationResult } from "@core/dop/ValidationResult";
import { BaseDOPAdapter } from "@core/dop/BaseDOPAdapter";
import { TestDataModel } from "./DataModel.test";
import { TestBehaviorModel } from "./BehaviorModel.test";
import * as jest from 'jest-mock';

// Test adapter implementation
class TestAdapter extends BaseDOPAdapter<TestDataModel, TestBehaviorModel> {
    // Match the parent class property definition instead of using a getter
    override data: TestDataModel = this.getDataModel();
    
    constructor(dataModel: TestDataModel, behaviorModel: TestBehaviorModel) {
        super(dataModel, behaviorModel);
    }
    validate(dataModel: TestDataModel): ValidationResult<TestDataModel> {
        return new ValidationResult(true, dataModel);
    }

    process(dataModel: TestDataModel): TestDataModel {
        return { ...dataModel, processed: true };
    }

    id = "testBehaviorModel";
    description = "Test behavior model for unit tests";
    processingDelay = 0;
    value = 0;

}

describe('BaseDOPAdapter', () => {
    // Test fixtures
    let dataModel: TestDataModel;
    let behaviorModel: TestBehaviorModel;
    let adapter: TestAdapter;
    
    beforeEach(() => {
        dataModel = new TestDataModel({ value: 10 });
        behaviorModel = new TestBehaviorModel();
        adapter = new TestAdapter(dataModel, behaviorModel);
    });
    
    describe('Initialization', () => {
        it('should initialize with data and behavior models', () => {
            // Verify data model and behavior model are stored correctly
            expect(adapter.getDataModel()).toBe(dataModel);
            expect(adapter.getBehaviorModel()).toBe(behaviorModel);
            expect(adapter.isValid).toBe(false); // Should initialize as invalid
            expect(adapter.data).toBe(dataModel);
        });
    });
    
    describe('Validation', () => {
        it('should validate data model', () => {
            // Spy on behavior model validate method
            const validateSpy = jest.spyOn(behaviorModel, 'validate');
            
            // Call validate
            const result = adapter.validate();
            
            // Verify validate was called with the correct data model
            expect(validateSpy).toHaveBeenCalledWith(dataModel);
            
            // Verify result is correct
            expect(result.isValid).toBe(true);
            
            // Verify adapter state is updated
            expect(adapter.isValid).toBe(true);
        });
        
        it('should update isValid state based on validation result', () => {
            // Mock validation to return invalid result
            jest.spyOn(behaviorModel, 'validate').mockImplementation(() => {
                return new ValidationResult<TestDataModel>(false, dataModel);
            });
            
            const result = adapter.validate();
            
            expect(result.isValid).toBe(false);
            expect(adapter.isValid).toBe(false);
        });
    });
    
    describe('Adaptation', () => {
        it('should adapt data model using behavior model', () => {
            // Spy on behavior model process method
            const processSpy = jest.spyOn(behaviorModel, 'process');
            
            // Call adapt
            const result = adapter.adapt(dataModel);
            
            // Verify process was called with the correct data
            expect(processSpy).toHaveBeenCalledWith(dataModel);
            
            // Verify result contains processed data
            const resultObj = result.toObject();
            expect(resultObj).toHaveProperty('value', 10);
            expect(resultObj).toHaveProperty('processed', true);
        });
        
        it('should pass different data to behavior model', () => {
            const newData = new TestDataModel({ value: 20 });
            const processSpy = jest.spyOn(behaviorModel, 'process');
            
            adapter.adapt(newData);
            
            expect(processSpy).toHaveBeenCalledWith(newData);
        });
    });
    
    describe('Comparison', () => {
        it('should compare with another ValidationResult', () => {
            const otherResult = new ValidationResult<TestDataModel>(true, dataModel);
            // Use type assertion to ensure compatibility with expected ValidationResult type
            const result = adapter.compareWith(otherResult as any);
            
            expect(result).toBeInstanceOf(ImplementationComparisonResult);
            expect(result.equivalent).toBe(true);
        });
        
        it('should detect non-equivalent results', () => {
            const differentData = new TestDataModel({ value: 99 });
            const otherResult = new ValidationResult<TestDataModel>(false, differentData);
            
            // Use type assertion to ensure compatibility with expected ValidationResult type
            const result = adapter.compareWith(otherResult as any);
            
            expect(result.equivalent).toBe(false);
        });
    });
    
    describe('Caching', () => {
        it('should enable caching through API', () => {
            // Spy on console.log since base implementation logs
            const consoleSpy = jest.spyOn(console, 'log');
            
            const result = adapter.enableCaching(true);
            
            expect(consoleSpy).toHaveBeenCalledWith('Caching enabled: true');
            expect(result).toBe(adapter); // Should return this for chaining
            
            consoleSpy.mockRestore();
        });
        
        it('should throw error when clearing cache on base implementation', () => {
            expect(() => {
                adapter.clearCache();
            }).toThrow('Method not implemented.');
        });
    });
    
    describe('Accessor Methods', () => {
        it('should get the data model', () => {
            expect(adapter.getDataModel()).toBe(dataModel);
        });
        
        it('should get the behavior model', () => {
            expect(adapter.getBehaviorModel()).toBe(behaviorModel);
        });
    });
});