# AKS Microservices GitOps Azure Pipeline Demo

## Overview

This project implements Google's Online Boutique microservices demo application on a production-grade **Azure Kubernetes Service (AKS)** cluster. It showcases modern cloud-native practices using **Azure Pipelines** for CI/CD, **Terraform** for infrastructure management, and **ArgoCD** for GitOps-based deployments. The implementation includes **Azure Container Registry (ACR)** for container management, **NGINX Ingress Controller** for traffic routing, **Cert-Manager** for SSL automation, **ExternalDNS** for DNS management, and **Prometheus** & **Grafana** for comprehensive monitoring.

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

[![Online Boutique Demo](/docs/images/online-boutique-prod-demo.gif)]

## Solution Architecture

[![Architecture](/docs/images/architecture.png)]

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

## Platform Implementation

Our platform follows a comprehensive approach integrating infrastructure, security, deployment, and monitoring to ensure a robust and reliable system.

### Infrastructure

#### Infrastructure Provisioning

The infrastructure pipeline handles the creation and management of all Azure resources:

[![Infrastructure Apply](/docs/images/infra-apply.png)]

### Security

#### DevSecOps Pipeline

Our comprehensive security pipeline ensures infrastructure and application security at every stage:

[![DevSecOps](/docs/images/devsecops.png)]

### Application

#### CI/CD Pipeline Overview

Our end-to-end CI/CD pipeline orchestrates the entire deployment process:

[![Application CICD](/docs/images/application-cicd.png)]

#### Build Pipeline

The build pipeline handles container image creation and security scanning:

[![App Build](/docs/images/app-build.png)]

#### Deployment Pipeline

The deployment pipeline manages the GitOps-based deployment process:

[![App Deploy](/docs/images/app-deploy.png)]

### GitOps

#### ArgoCD Deployment

Continuous deployment is managed through ArgoCD, providing GitOps-based application delivery:

[![ArgoCD](/docs/images/argocd.gif)]

### DNS Management

#### Cloudflare Integration

Automated DNS management through Cloudflare ensures proper routing and domain configuration:

[![Cloudflare](/docs/images/cloudflare.png)]

### Monitoring

#### Prometheus Metrics

Comprehensive metrics collection and alerting through Prometheus:

[![Prometheus](/docs/images/prometheus.png)]

#### Grafana Dashboards

Advanced visualization and monitoring through Grafana:

[![Grafana Overview](/docs/images/grafana.png)]

[![Grafana Detailed](/docs/images/grafana2.png)]

## Local Development

For local development and testing of individual microservices, please refer to the [`src`](./src/README.md) directory which contains detailed instructions for each service:

Quick Start:
1. Copy `env.template` to `.env` in the root directory
2. Configure environment variables
3. Run `docker-compose up` to start all services

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

Copyright 2024 [Your Organization]

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
