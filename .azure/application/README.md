# Application Pipelines

This directory contains application-specific Azure DevOps pipelines.

## Pipelines

### main-pipeline.yml
The main CI/CD pipeline for the Online Boutique application.

**Purpose**: Complete end-to-end CI/CD process including:
- Semantic versioning
- Docker image building and pushing to ACR
- Helm chart validation
- Kubernetes deployment
- Health verification

**Usage**: This is the primary pipeline to run for application deployments.

**Parameters**:
- `packageServices`: Whether to build and push images
- `deployEnvironment`: Environment to deploy to
- `deployNamespace`: Kubernetes namespace
- `chartPath`: Path to Helm chart
- `helmVersion`: Helm version to use

## Templates Used

This pipeline uses the following centralized templates:
- `../templates/ci-cd-template.yml`: Multi-stage orchestration
- `../templates/docker/acr-build-template.yml`: Docker builds
- `../templates/helm/helm-deploy-template.yml`: Helm deployments

## Best Practices

- Single entry point for application deployment
- Reuses centralized templates for consistency
- Environment-specific configuration through parameters 