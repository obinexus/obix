export interface validationProvider {
  configure(container: ServiceContainer): void;
  getServices(): string[];
  getDependencies(): string[];
}

export class validationProviderImpl implements validationProvider {
  configure(container: ServiceContainer): void {
    // IoC service registration implementation
    container.register("validation", () => new validationProviderImpl());
  }
  
  getServices(): string[] {
    return [];
  }
  
  getDependencies(): string[] {
    return [];
  }
}
