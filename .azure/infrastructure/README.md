# Infrastructure Pipelines

This directory contains infrastructure-specific Azure DevOps pipelines using Terraform.

## Pipelines

### terraform-plan.yml
Plans infrastructure changes without applying them.

**Purpose**: 
- Validates Terraform configuration
- Shows what changes would be made
- Safe to run without making actual changes

**Usage**: Run before applying infrastructure changes to review what will be modified.

### terraform-apply.yml
Applies infrastructure changes.

**Purpose**:
- Creates or updates Azure resources
- Deploys the complete infrastructure stack
- Should be run after successful plan

**Usage**: Run to deploy or update infrastructure after reviewing the plan.

### terraform-destroy.yml
Destroys infrastructure resources.

**Purpose**:
- Removes all Azure resources created by Terraform
- Use with caution - this will delete all infrastructure

**Usage**: Run when you need to completely remove the infrastructure (e.g., for cleanup or recreation).

## Best Practices

- Always run `terraform-plan.yml` before `terraform-apply.yml`
- Use `terraform-destroy.yml` with extreme caution
- Review plan output before applying changes
- Use appropriate approvals and branch policies for production infrastructure 