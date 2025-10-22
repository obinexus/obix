export interface policyProvider {
  configure(container: ServiceContainer): void;
  getServices(): string[];
  getDependencies(): string[];
}

export class policyProviderImpl implements policyProvider {
  configure(container: ServiceContainer): void {
    // IoC service registration implementation
    container.register("policy", () => new policyProviderImpl());
  }
  
  getServices(): string[] {
    return [];
  }
  
  getDependencies(): string[] {
    return [];
  }
}
