export interface automatonProvider {
  configure(container: ServiceContainer): void;
  getServices(): string[];
  getDependencies(): string[];
}

export class automatonProviderImpl implements automatonProvider {
  configure(container: ServiceContainer): void {
    // IoC service registration implementation
    container.register("automaton", () => new index.d());
  }
  
  getServices(): string[] {
    return ['index.d'];
  }
  
  getDependencies(): string[] {
    return [];
  }
}
