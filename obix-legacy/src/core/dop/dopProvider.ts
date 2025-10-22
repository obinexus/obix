export interface dopProvider {
  configure(container: ServiceContainer): void;
  getServices(): string[];
  getDependencies(): string[];
}

export class dopProviderImpl implements dopProvider {
  configure(container: ServiceContainer): void {
    // IoC service registration implementation
    container.register("dop", () => new dopProviderImpl());
  }
  
  getServices(): string[] {
    return [];
  }
  
  getDependencies(): string[] {
    return [];
  }
}
