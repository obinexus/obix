# OBIX Framework Tool Placement Guide

## Directory Structure Requirements

Based on package.json script definitions, place tools as follows:

### Core Validation Tools
```
scripts/tools/
├── validate-namespace-tree.sh          # Basic namespace validation
├── obix-namespace-validator.sh         # Comprehensive validation system
├── import-migration-tool.ts             # Automated import migration
├── package-json-validator.sh           # Package.json compliance checker
└── debug-namespace-structure.sh        # Structure debugging tool
```

### Build and Setup Scripts
```
scripts/
├── validate-imports.sh                 # Import validation script
├── analyze-modules.sh                  # Module analysis tool
├── verify-outputs.js                   # Build output verification
├── setup/
│   ├── dev-workflow.sh                 # Development workflow
│   └── dev-setup.sh                    # Environment setup
└── build/
    └── compile/
        └── index.ts                     # Build compilation entry
```

### Testing Infrastructure
```
scripts/test/
├── performance/
│   ├── index.js                        # Performance testing
│   └── benchmarks.js                   # Benchmark execution
```

### Release Management
```
scripts/release/
├── prepare/
│   └── index.js                        # Release preparation
└── publish/
    └── index.js                        # Release publication
```

## Implementation Steps

1. Create directory structure: `bash scripts/structure-setup.sh`
2. Place tool files in designated locations
3. Verify placement: `bash scripts/tools/verify-placement.sh`
4. Execute QA validation: `npm run qa:full`

## Package.json Script Alignment

Ensure all script paths in package.json match the standardized structure above.
