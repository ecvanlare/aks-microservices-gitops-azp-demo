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
│   └── ci-cd-template.yml
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
- **main-pipeline.yml**: Complete CI/CD pipeline that builds, packages, validates, deploys, and verifies the application

### Infrastructure Pipelines
- **terraform-plan.yml**: Plans infrastructure changes
- **terraform-apply.yml**: Applies infrastructure changes
- **terraform-destroy.yml**: Destroys infrastructure

### Templates
- **ci-cd-template.yml**: Multi-stage CI/CD orchestration template
- **acr-build-template.yml**: Docker image build template
- **helm-deploy-template.yml**: Helm deployment template
- **terraform-template.yml**: Terraform execution template

## Usage

1. **Application Deployment**: Run `main-pipeline.yml` for complete CI/CD
2. **Infrastructure Changes**: Use appropriate Terraform pipeline based on action needed

## Best Practices

- Templates are centralized for reusability
- Clear separation between application and infrastructure
- Consistent naming conventions with `-template.yml` and `-pipeline.yml` suffixes 