export interface iocProvider {
  configure(container: ServiceContainer): void;
  getServices(): string[];
  getDependencies(): string[];
}

export class iocProviderImpl implements iocProvider {
  configure(container: ServiceContainer): void {
    // IoC service registration implementation
    container.register("ioc", () => new iocProviderImpl());
  }
  
  getServices(): string[] {
    return [];
  }
  
  getDependencies(): string[] {
    return [];
  }
}
