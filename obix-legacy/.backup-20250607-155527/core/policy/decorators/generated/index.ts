/**
 * OBIX Policy Decorator Registry
 * Generated: $(date)
 */

export { enforce_banking_policy } from './enforce_banking_policy';
export { enforce_fintech_policy } from './enforce_fintech_policy';
export { enforce_healthcare_policy } from './enforce_healthcare_policy';
export { enforce_generic_policy } from './enforce_generic_policy';

// Policy domain configuration
export const POLICY_DOMAINS = {
  BANKING: 'banking',
  FINTECH: 'fintech', 
  HEALTHCARE: 'healthcare',
  GENERIC: 'generic'
} as const;

export type PolicyDomain = typeof POLICY_DOMAINS[keyof typeof POLICY_DOMAINS];
