import { ServiceContainer } from '../src/core/ioc/containers/ServiceContainer';

function run() {
  const container = new ServiceContainer();
  const result = container.validateSinphaseCompliance();
  if (!result.compliant) {
    console.error(`Sinphase cost threshold exceeded: ${result.cost}`);
    process.exit(1);
  }
  console.log(`Sinphase compliance validated. Cost: ${result.cost}`);
}

run();
