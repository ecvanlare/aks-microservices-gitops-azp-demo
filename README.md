# AKS Microservices GitOps Azure Pipeline Demo

## Overview

This project implements Google's Online Boutique microservices demo application on a production-grade **Azure Kubernetes Service (AKS)** cluster. It showcases modern cloud-native practices using **Azure Pipelines** for CI/CD, **Terraform** for infrastructure management, and **ArgoCD** for GitOps-based deployments. The implementation includes **Azure Container Registry (ACR)** for container management, **NGINX Ingress Controller** for traffic routing, **Cert-Manager** for SSL automation, **ExternalDNS** for DNS management, and **Prometheus** & **Grafana** for comprehensive monitoring.

## End-to-End Architecture



## Key Components

| Component | Description |
|-----------|-------------|
| Azure Kubernetes Service (AKS) | Production-grade Kubernetes cluster hosting the microservices |
| Azure Container Registry (ACR) | Private registry for all service container images |
| Azure Key Vault | Secure storage for secrets and certificates |
| Azure Pipelines | Handles CI/CD automation for both infrastructure and application code |
| Terraform | Manages all Azure infrastructure through Infrastructure as Code |
| ArgoCD | Implements GitOps for continuous deployment and configuration management |
| NGINX Ingress | Manages external traffic routing with SSL termination |
| Cert-Manager | Automates SSL certificate management with Let's Encrypt |
| ExternalDNS | Handles dynamic DNS record updates |
| Prometheus & Grafana | Provides comprehensive monitoring and observability |
| Redis | In-memory database for cart service |
| Helm | Package manager for Kubernetes applications |
| Let's Encrypt | Certificate Authority for SSL certificates |

### Tools

| Tool | Purpose |
|------|----------|
| Trivy | Container vulnerability scanning |
| TFLint | Terraform static analysis |
| Checkov | Infrastructure-as-Code security scanning |
| Azure Policy | Kubernetes cluster security policies |
| yamllint | YAML syntax validation |
| shellcheck | Shell script analysis |
| Prettier | Code formatting |
| Helm lint | Helm chart validation |
| GitVersion | Semantic versioning |
| Docker Compose | Local development environment |

## Project Structure

The project is organized into several key directories, each with its own documentation:

- [`.azure`](./.azure/README.md) - Azure DevOps Pipeline Configurations
  - GitOps pipeline definitions
  - Security and compliance pipelines
  - Application build pipelines
  - Infrastructure pipelines

- [`cluster`](./cluster/README.md) - Kubernetes Configurations
  - Helm charts for services
  - Infrastructure components
  - Root application configs

- [`src`](./src/README.md) - Microservices Source Code
  - Web UI (Go)
  - Cart management (C#)
  - Order processing (Go)
  - Additional microservices

- [`terraform`](./terraform/README.md) - Infrastructure as Code
  - Reusable Terraform modules
  - Environment configurations

- [`scripts`](./scripts/README.md) - Utility Scripts
  - Development helpers
  - Maintenance utilities

## Deployment Process

The deployment process is fully automated and follows these stages:

1. **Infrastructure Provisioning**:
   - Terraform creates all required Azure resources
   - AKS cluster setup with necessary add-ons
   - Network and security configurations

2. **Application Deployment**:
   - Container images built and pushed to ACR
   - ArgoCD syncs Kubernetes manifests
   - Services deployed with proper configurations

3. **Configuration and Security**:
   - SSL certificates automatically provisioned
   - DNS records automatically updated
   - Security policies and network rules applied

4. **Monitoring Setup**:
   - Prometheus metrics collection
   - Grafana dashboards deployment
   - Alerting rules configuration


## Local Development

For local development of the microservices:

1. **Prerequisites**:
   - Docker
   - Docker Compose
   - Language-specific tools (Go, .NET, Node.js, Java, Python)

2. **Run Locally**:
   ```bash
   docker-compose up
   ```

## License

[Add your license information here]

## Support

For issues and questions:
1. Check existing GitHub issues
2. Review documentation
3. Create a new issue 