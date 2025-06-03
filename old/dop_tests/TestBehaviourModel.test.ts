import { BehaviorModel } from "@core/dop/BehaviourModel";
import { ImplementationComparisonResult } from "@core/dop/ImplementationComparisonResult";
import { ValidationResult } from "@core/dop/ValidationResult";
import { TestDataModel } from "../../tests/unit/core/dop/DataModel.test";

/**
 * Test implementation of BehaviorModel for testing BaseDOPAdapter
 */
class TestBehaviorModel implements BehaviorModel<TestDataModel, TestDataModel> {
    public id: string;
    public description: string;
    
    constructor(id: string = 'test-behavior', description: string = 'Test behavior') {
        this.id = id;
        this.description = description;
    }
    
    process(data: TestDataModel): TestDataModel {
        // Simulate processing by adding a flag
        const result = data.clone();
        return result.merge(new TestDataModel({ processed: true }));
    }
    
    validate(data: TestDataModel): ValidationResult<TestDataModel> {
        const result = new ValidationResult<TestDataModel>(true, data);
        // Override compareWith method to match the expected signature in the BehaviorModel interface
        result.compareWith = (other: ValidationResult<any>) => new ImplementationComparisonResult(true);
        return result;
    }
    
    getBehaviorId(): string {
        return this.id;
    }
    
    getDescription(): string {
        return this.description;
    }
    
    compareWith(other: any): ImplementationComparisonResult {
        return new ImplementationComparisonResult(true);
    }
}

export { TestBehaviorModel };