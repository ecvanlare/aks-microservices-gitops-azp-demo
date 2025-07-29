# Cluster Configuration

This directory contains Kubernetes and Helm configurations for the microservices deployment.

## Structure

### Helm Charts (`/helm`)
- **Main Chart** (`/helm/online-boutique`): Parent chart orchestrating all services
- **Service Charts** (`/charts/*`): Individual microservice configurations
  - Deployment specs
  - Service definitions
  - Resource limits
  - Health checks

### Infrastructure (`/infrastructure`)
- **ArgoCD**: GitOps deployment management
- **Cert-Manager**: SSL certificate automation
- **External DNS**: DNS record automation
- **Ingress-NGINX**: Load balancing and routing
- **Monitoring**: Prometheus & Grafana stack

### Root Applications (`/root`)
- **Apps-of-Apps**: ArgoCD application hierarchy
- **Infrastructure**: Core component orchestration
- **Dependencies**: Cross-cutting concerns
