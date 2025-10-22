export interface apiProvider {
  configure(container: ServiceContainer): void;
  getServices(): string[];
  getDependencies(): string[];
}

export class apiProviderImpl implements apiProvider {
  configure(container: ServiceContainer): void {
    // IoC service registration implementation
    container.register("api", () => new apiProviderImpl());
  }
  
  getServices(): string[] {
    return [];
  }
  
  getDependencies(): string[] {
    return [];
  }
}
