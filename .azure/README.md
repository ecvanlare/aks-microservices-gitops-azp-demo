# Azure DevOps Pipelines

This directory contains all Azure DevOps pipeline configurations for the Online Boutique project.

## Structure

```
.azure/
├── templates/                   # Centralized, reusable templates
│   ├── docker/
│   │   └── acr-build-template.yml
│   ├── helm/
│   │   └── helm-deploy-template.yml
│   ├── terraform/
│   │   └── terraform-template.yml
│   ├── version-job.yml         # Semantic versioning job
│   ├── package-job.yml         # Docker build job
│   ├── validate-job.yml        # Helm validation job
│   ├── deploy-job.yml          # Helm deployment job
│   └── verify-job.yml          # Health check job
├── application/                 # Application-specific pipelines
│   └── main-pipeline.yml       # Complete CI/CD entry point
├── infrastructure/              # Infrastructure pipelines
│   ├── terraform-plan.yml      # Plan infrastructure changes
│   ├── terraform-apply.yml     # Apply infrastructure changes
│   └── terraform-destroy.yml   # Destroy infrastructure
└── README.md                    # This file
```

## Pipeline Types

### Application Pipelines
- **main-pipeline.yml**: Complete CI/CD pipeline with stages:
  - **Version**: Calculate semantic versioning
  - **Package**: Build and push Docker images
  - **Validate**: Validate Helm chart
  - **Deploy**: Deploy to Kubernetes
  - **Verify**: Health checks and verification

### Infrastructure Pipelines
- **terraform-plan.yml**: Plans infrastructure changes
- **terraform-apply.yml**: Applies infrastructure changes
- **terraform-destroy.yml**: Destroys infrastructure

### Templates
- **version-job.yml**: Semantic versioning job template
- **package-job.yml**: Docker image build job template
- **validate-job.yml**: Helm chart validation job template
- **deploy-job.yml**: Helm deployment job template
- **verify-job.yml**: Health check job template
- **acr-build-template.yml**: Docker image build template
- **helm-deploy-template.yml**: Helm deployment template
- **terraform-template.yml**: Terraform execution template

## Usage

1. **Application Deployment**: Run `main-pipeline.yml` for complete CI/CD
2. **Infrastructure Changes**: Use appropriate Terraform pipeline based on action needed

## Best Practices

- Templates are centralized for reusability
- Clear separation between application and infrastructure
- Stage-based organization for better visibility
- Consistent naming conventions with `-template.yml` and `-job.yml` suffixes 