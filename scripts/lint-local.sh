#!/bin/bash

# Local linting script for developers
# Run this before pushing to catch issues early

set -e

echo "🔍 Running local linting checks..."

# Check if required tools are installed
if ! command -v yamllint &> /dev/null; then
    echo "❌ yamllint not found. Install with: brew install yamllint"
    exit 1
fi

if ! command -v prettier &> /dev/null; then
    echo "❌ prettier not found. Install with: npm install -g prettier"
    exit 1
fi

if ! command -v helm &> /dev/null; then
    echo "❌ helm not found. Install with: brew install helm"
    exit 1
fi

if ! command -v tflint &> /dev/null; then
    echo "❌ tflint not found. Install with: brew install tflint"
    exit 1
fi

# Lint YAML files
echo "🔍 Linting YAML files..."
yamllint -c .yamllint cluster/ .azure/

# Lint Helm charts
echo "🔍 Linting Helm charts..."
helm lint cluster/workloads/online-boutique

# Check YAML formatting
echo "🔍 Checking YAML formatting..."
prettier --check ".azure/**/*.yml" "cluster/root/*.yaml" "cluster/infrastructure/**/*.yaml"

# Lint Terraform files
echo "🔍 Linting Terraform files..."
cd terraform

# Fix deprecated syntax if needed
if [ -f ".tflint.hcl" ] && grep -q "module = true" .tflint.hcl; then
  echo "Fixing deprecated module syntax..."
  sed -i 's/module = true/call_module_type = "local"/' .tflint.hcl
fi

tflint --init
tflint --format=compact
cd ..

# Check Terraform formatting
echo "🔍 Checking Terraform formatting..."
terraform fmt -check -recursive terraform/

echo "✅ All linting checks passed!" 