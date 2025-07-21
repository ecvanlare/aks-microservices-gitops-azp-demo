#!/bin/bash

# Local linting script for developers
# Run this before pushing to catch issues early

# Do not exit on first error; report all issues

echo "🔍 Running local linting checks..."

FAILED=0

# Check if required tools are installed
if ! command -v yamllint &> /dev/null; then
    echo "❌ yamllint not found. Install with: pip install yamllint"
fi

if ! command -v prettier &> /dev/null; then
    echo "❌ prettier not found. Install with: npm install -g prettier"
fi

if ! command -v helm &> /dev/null; then
    echo "❌ helm not found. Install with: brew install helm"
fi

if ! command -v tflint &> /dev/null; then
    echo "❌ tflint not found. Install with: brew install tflint"
fi

# Find all pure YAML files (exclude Helm charts and templates)
YAML_FILES=$(find . \
  -type f \
  \( -name "*.yaml" -o -name "*.yml" \) \
  ! -path "./cluster/helm/*" \
  ! -path "./cluster/helm/**" \
  ! -path "*/templates/*" \
)

# Lint YAML files (pure YAML only)
echo "🔍 Linting pure YAML files..."
if [ -n "$YAML_FILES" ]; then
  yamllint -c .yamllint $YAML_FILES || { echo "❌ yamllint failed"; FAILED=1; }
else
  echo "No pure YAML files found for yamllint."
fi

# Check YAML formatting with Prettier (entire repo, respects .prettierignore)
echo "🔍 Checking YAML formatting with Prettier (entire repo, using .prettierignore)..."
prettier --check . || { echo "❌ prettier formatting failed"; FAILED=1; }

# Lint Helm charts (no auto-fix, just report)
echo "🔍 Linting Helm charts..."
if command -v helm &> /dev/null; then
  helm lint cluster/helm/online-boutique || { echo "❌ helm lint failed"; FAILED=1; }
else
  echo "❌ helm not found. Install with: brew install helm"
fi

# Lint Terraform files
echo "🔍 Linting Terraform files..."
if [ -d "terraform" ]; then
  (cd terraform && tflint --init && tflint --format=compact) || { echo "❌ tflint failed"; FAILED=1; }
else
  echo "⚠️  No Terraform directory found to lint"
fi

# Check Terraform formatting
echo "🔍 Checking Terraform formatting..."
if command -v terraform &> /dev/null; then
  terraform fmt -check -recursive terraform/ || { echo "❌ terraform fmt failed"; FAILED=1; }
else
  echo "❌ terraform not found. Install with: brew install terraform"
fi

if [ "$FAILED" -eq 0 ]; then
  echo "✅ All linting checks passed!"
else
  echo "❌ Some linting checks failed. Please review the output above."
fi

echo "ℹ️  Helm chart and template YAML files must be fixed manually if linting reports issues." 