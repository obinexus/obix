export interface parserProvider {
  configure(container: ServiceContainer): void;
  getServices(): string[];
  getDependencies(): string[];
}

export class parserProviderImpl implements parserProvider {
  configure(container: ServiceContainer): void {
    // IoC service registration implementation
    container.register("parser", () => new parserProviderImpl());
  }
  
  getServices(): string[] {
    return [];
  }
  
  getDependencies(): string[] {
    return [];
  }
}
