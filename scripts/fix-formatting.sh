#!/bin/bash

# Local formatting fix script for developers
# Run this to auto-fix formatting issues found by linting

set -e

echo "🔧 Fixing formatting issues..."

# Check if required tools are installed
if ! command -v prettier &> /dev/null; then
    echo "❌ prettier not found. Install with: npm install -g prettier"
    exit 1
fi

if ! command -v terraform &> /dev/null; then
    echo "❌ terraform not found. Install with: brew install terraform"
    exit 1
fi

# Fix YAML formatting
echo "🎨 Fixing YAML formatting..."
prettier --write ".azure/**/*.yml" "cluster/root/*.yaml" "cluster/infrastructure/**/*.yaml"

# Fix Terraform formatting
echo "🔧 Fixing Terraform formatting..."
terraform fmt -recursive terraform/

echo "✅ Formatting fixes applied!"
echo "💡 Run ./scripts/lint-local.sh to verify all issues are resolved." 