export interface astProvider {
  configure(container: ServiceContainer): void;
  getServices(): string[];
  getDependencies(): string[];
}

export class astProviderImpl implements astProvider {
  configure(container: ServiceContainer): void {
    // IoC service registration implementation
    container.register("ast", () => new astProviderImpl());
  }
  
  getServices(): string[] {
    return [];
  }
  
  getDependencies(): string[] {
    return [];
  }
}
