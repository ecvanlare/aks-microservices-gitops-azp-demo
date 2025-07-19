# Linting and Code Quality

This project uses comprehensive linting to ensure code quality and consistency.

## 🚀 Quick Start

### For Developers
```bash
# Run all linting checks locally (PR validation)
./scripts/lint-local.sh

# Fix formatting issues locally
./scripts/fix-formatting.sh

# Or run individual checks
yamllint -c .yamllint cluster/root/ cluster/infrastructure/ .azure/
helm lint cluster/workloads/online-boutique
prettier --check ".azure/**/*.yml" "cluster/root/*.yaml" "cluster/infrastructure/**/*.yaml"
cd terraform && tflint --init && tflint --format=compact && cd ..
terraform fmt -check -recursive terraform/
```

### For CI/CD
Linting is automatically run on every PR and build pipeline.

**Dedicated Code Quality Pipeline:**
- **`code-quality.yml`** - Comprehensive checks with test results publishing

## 🔧 What Gets Linted

### 1. **YAML Files** (`yamllint`)
- **Azure DevOps pipelines** (`.azure/**/*.yml`)
- **Kubernetes manifests** (`cluster/root/*.yaml`)
- **Infrastructure configs** (`cluster/infrastructure/**/*.yaml`)
- **Note**: Helm workloads are excluded due to Go templating syntax conflicts

### 2. **Helm Charts** (`helm lint`)
- **Chart structure validation**
- **Template syntax checking**
- **Values validation**

### 3. **Code Formatting** (`prettier`)
- **Format validation** of YAML files
- **Consistent indentation** and spacing
- **Standardized quote usage**

### 4. **Terraform** (`tflint` + `terraform fmt`)
- **Terraform code linting** (`tflint`)
- **Infrastructure code formatting** (`terraform fmt`)
- **Consistent variable naming**
- **Proper indentation**
- **Azure-specific rules** (via tflint-azurerm plugin)

## 📋 Pipeline Integration

### Build Pipeline Integration
The linting runs as part of the `LintAndFormat` stage in your build pipeline:

```yaml
- stage: LintAndFormat
  displayName: "Lint and Format Check"
  jobs:
    - job: Lint
      steps:
        - script: yamllint -c .yamllint cluster/root/ cluster/infrastructure/ .azure/
        - script: helm lint cluster/workloads/online-boutique
        - script: prettier --check ".azure/**/*.yml" "cluster/root/*.yaml"
        - script: |
            cd terraform
            # Fix deprecated syntax if needed
            if [ -f ".tflint.hcl" ] && grep -q "module = true" .tflint.hcl; then
              sed -i 's/module = true/call_module_type = "local"/' .tflint.hcl
            fi
            tflint --init
            tflint --format=compact
            cd ..
        - script: terraform fmt -check -recursive terraform/
```

### Dedicated Code Quality Pipeline
For focused PR checks, use the dedicated code quality pipeline:

```yaml
# .azure/pipelines/code-quality.yml
trigger: none
pr:
  branches: [main, dev]
  paths: [.azure/**, cluster/**, terraform/**]

jobs:
  - job: LintAndFormat
    displayName: "Lint & Format Check"
    steps:
      - script: yamllint -c .yamllint cluster/root/ cluster/infrastructure/ .azure/
      - script: helm lint cluster/workloads/online-boutique
      - script: prettier --check ".azure/**/*.yml" "cluster/root/*.yaml"
      - script: |
          cd terraform
          # Fix deprecated syntax if needed
          if [ -f ".tflint.hcl" ] && grep -q "module = true" .tflint.hcl; then
            sed -i 's/module = true/call_module_type = "local"/' .tflint.hcl
          fi
          tflint --init
          tflint --format=compact
          cd ..
      - script: terraform fmt -check -recursive terraform/
```

## ⚙️ Configuration Files

- **`.yamllint`** - YAML linting rules
- **`.editorconfig`** - Editor formatting rules
- **`scripts/lint-local.sh`** - Local development script

## 🚨 Common Issues

### Helm Template Errors
If you see errors like:
```
ERROR: template: executing at <.Values.global.image.registry>: nil pointer
```

**Solution**: Add missing values to your `values.yaml` files.

### YAML Linting Conflicts with Helm
Helm chart templates contain Go templating syntax (`{{ }}`) that conflicts with YAML linting rules.

**Solution**: Helm workloads are excluded from YAML linting but still validated with `helm lint`.

### YAML Formatting Issues
If you see indentation or spacing errors:
```bash
# Fix with prettier
prettier --write "path/to/file.yaml"
# Or use the fix script
./scripts/fix-formatting.sh
```

### Terraform Format Issues
```bash
# Auto-fix with terraform fmt
terraform fmt -recursive terraform/
```

## 📝 Best Practices

1. **Run linting before pushing** - Use `./scripts/lint-local.sh`
2. **Fix formatting issues** - Let prettier auto-format your YAML
3. **Check Helm templates** - Ensure all required values are defined
4. **Validate Terraform** - Use `terraform validate` for syntax checking

## 🔍 Troubleshooting

### Missing Tools
```bash
# Install required tools
brew install yamllint helm tflint
npm install -g prettier
```

### Pipeline Failures
- Check the `LintAndFormat` stage logs
- Fix issues locally before pushing
- Use the local script to catch issues early 