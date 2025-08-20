# AKS Microservices GitOps Azure Pipeline Demo

## Overview

This project implements Google's Online Boutique, a cloud-native microservices demo application for an e-commerce website, on a production-grade **Azure Kubernetes Service (AKS)** cluster. It showcases modern cloud-native practices using **Azure Pipelines** for CI/CD, **Terraform** for infrastructure management, and **ArgoCD** for GitOps-based deployments. The implementation includes **Azure Container Registry (ACR)** for container management, **NGINX Ingress Controller** for traffic routing, **Cert-Manager** for SSL automation, **ExternalDNS** for DNS management, and **Prometheus** & **Grafana** for comprehensive monitoring.

## Table of Contents

- [Overview](#overview)
- [Online Boutique Demo Application](#online-boutique-demo-application)
- [Solution Architecture](#solution-architecture)
- [Key Components](#key-components)
- [Project Structure](#project-structure)
- [Platform Implementation](#platform-implementation)
  - [Infrastructure](#infrastructure)
  - [Security](#security)
  - [Application](#application)
  - [GitOps](#gitops)
  - [DNS Management](#dns-management)
  - [Monitoring](#monitoring)
- [Local Development](#local-development)
- [License](#license)

## Online Boutique Demo Application

![Online Boutique Demo](/docs/images/online-boutique-prod-demo.gif)

## Solution Architecture

![Architecture](/docs/images/architecture.png)

## Key Components

### Cloud & Infrastructure Components

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

### Development Tools

| Tool | Purpose |
|------|----------|
| Trivy | Container vulnerability scanning |
| TFLint | Terraform static analysis |
| Checkov | Infrastructure-as-Code security scanning |
| yamllint | YAML syntax validation |
| shellcheck | Shell script analysis |
| Prettier | Code formatting |
| Helm lint | Helm chart validation |
| GitVersion | Semantic versioning |
| Docker Compose | Local development environment |

## Project Structure

```
.
├── .azure/                 # Azure DevOps Pipeline Configurations
├── cluster/               # Kubernetes & Helm Configurations
│   ├── helm/             # Helm charts for all services
│   ├── infrastructure/   # Platform components (ArgoCD, Monitoring)
│   └── root/            # Root application configs
├── docs/                 # Documentation and images
├── src/                 # Microservices source code
│   ├── frontend/       # Web UI (Go)
│   ├── cartservice/   # Cart management (C#)
│   ├── checkoutservice/ # Order processing (Go)
│   └── ...            # Other microservices
├── terraform/          # Infrastructure as Code
│   ├── modules/       # Reusable Terraform modules
│   └── bootstrap/    # State storage setup
└── scripts/          # Utility scripts for development
```

### Documentation

Each major component has its own detailed documentation:

- [`.azure/`](./.azure/README.md): Pipeline configurations and CI/CD setup
- [`cluster/`](./cluster/README.md): Kubernetes deployment and platform setup
- [`src/`](./src/README.md): Microservice implementations and local development
- [`terraform/`](./terraform/README.md): Infrastructure provisioning
- [`scripts/`](./scripts/README.md): Development utilities

## Platform Implementation

The platform follows a comprehensive approach integrating infrastructure, security, deployment, and monitoring to ensure a robust and reliable system.

### Infrastructure

The foundation is built on Azure cloud services, provisioned and managed through Infrastructure as Code practices.

#### Infrastructure Provisioning

The infrastructure pipeline handles the creation and management of all Azure resources:

![Infrastructure Apply](/docs/images/infra-apply.png)

### Security

Security is embedded throughout the platform using DevSecOps practices, ensuring protection at every layer.

#### DevSecOps Pipeline

The comprehensive security pipeline ensures infrastructure and application security at every stage:

![DevSecOps](/docs/images/devsecops.png)

### Application

The application layer manages the deployment and operation of microservices through automated pipelines.

#### CI/CD Pipeline Overview

The end-to-end CI/CD pipeline orchestrates the entire deployment process:

![Application CICD](/docs/images/application-cicd.png)

### Build Pipeline

The build pipeline intelligently handles container image creation and security scanning:

- **Conditional Builds**: Only rebuilds services with code changes
- **Smart Caching**: Uses layer caching for faster builds
- **Security Scans**: Runs container vulnerability scanning

![App Build](/docs/images/app-build.png)

### Deployment Pipeline

The deployment pipeline manages the GitOps-based deployment process with built-in safeguards:

- **Development**: Direct deployment to dev environment
- **Production**: 
  - Pre-deployment approval gate
  - Security compliance checks
  - Configuration validation
- **GitOps**: ArgoCD-managed deployments
- **Rollback**: Automated rollback on failure

![App Deploy](/docs/images/app-deploy.png)

### GitOps

GitOps practices ensure that infrastructure and application deployments are version controlled and automated.

#### ArgoCD Deployment

Continuous deployment is managed through ArgoCD, providing GitOps-based application delivery:

![ArgoCD](/docs/images/argocd.gif)

### DNS Management

Automated DNS management ensures reliable access to services through proper domain configuration.

#### Cloudflare Integration

Automated DNS management through Cloudflare ensures proper routing and domain configuration:

![Cloudflare](/docs/images/cloudflare.png)

### Monitoring

Comprehensive monitoring provides visibility into the health and performance of the platform.

#### Prometheus Metrics

Comprehensive metrics collection and alerting through Prometheus:

![Prometheus](/docs/images/prometheus.png)

#### Grafana Dashboards

Advanced visualization and monitoring through Grafana:

![Grafana Overview](/docs/images/grafana.png)

![Grafana Detailed](/docs/images/grafana2.png)

## Local Development

For local development and testing of individual microservices, please refer to the [`src`](./src/README.md) directory which contains detailed instructions for each service.

Quick Start:
1. Copy `env.template` to `.env` in the root directory
2. Configure environment variables
3. Run `docker-compose up` to start all services

## Next Steps

The next steps I will be implementing to enhance this platform for enterprise production workloads:

- **Availability Zones** - Configure AKS node pools across multiple zones for regional redundancy
- **Azure Policy** - Enable Kubernetes policy add-on for governance and compliance
- **Uptime SLA** - Enable AKS uptime SLA for 99.95% availability guarantees
- **Azure Backup** - Implement backup for cluster configurations and application data
- **Network Policies** - Enable Kubernetes network policies for pod-to-pod communication control

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.
