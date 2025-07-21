#!/bin/bash

echo "🔧 Fixing formatting issues..."

# Fix YAML formatting with Prettier (skip cluster/helm via .prettierignore)
if command -v prettier &> /dev/null; then
  echo "🎨 Fixing YAML formatting with Prettier (excluding cluster/helm)..."
  prettier --write .
else
  echo "❌ prettier not found. Install with: npm install -g prettier"
fi

# Fix Terraform formatting
if command -v terraform &> /dev/null; then
  echo "🔧 Fixing Terraform formatting..."
  terraform fmt -recursive terraform/
else
  echo "❌ terraform not found. Install with: brew install terraform"
fi

echo "✅ Formatting fixes applied! Run ./scripts/lint-local.sh to check for remaining issues."
echo "ℹ️  Helm chart and template YAML files must be fixed manually if linting reports issues." 