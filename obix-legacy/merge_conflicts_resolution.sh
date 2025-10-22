#!/bin/bash
# OBIX Merge Conflict Resolution Guide

echo "🛠️ OBIX Merge Conflict Resolution Protocol"
echo "=========================================="

echo "Priority Resolution Order:"
echo "1. IoC container implementations (preserve local Sinphasé)"
echo "2. CLI module consumer (preserve local functionality)"  
echo "3. Sinphasé validator (preserve local validation logic)"
echo "4. Abstract class migrations (apply concrete implementations)"

echo "Conflict Resolution Commands:"
echo "# Accept local for IoC implementation:"
echo "git checkout --ours src/core/ioc/"
echo ""
echo "# Accept local for CLI consumer:"
echo "git checkout --ours src/cli/consumer/CLIModuleConsumer.ts"
echo ""
echo "# Accept local for Sinphasé validator:"
echo "git checkout --ours scripts/sinphase-validator.ts"
echo ""
echo "# Review and merge other conflicts manually"
echo "git status"
