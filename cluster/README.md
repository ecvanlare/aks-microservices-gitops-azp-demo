# Cluster Configuration

This directory contains all Kubernetes and Helm configurations for the microservices deployment.

## Directory Structure

- [`/helm`](./helm) - Contains Helm charts for all microservices
  - [`/helm/online-boutique`](./helm/online-boutique) - Main Helm chart
  - Individual service charts in `/helm/online-boutique/charts`

- [`/infrastructure`](./infrastructure) - Infrastructure components
  - ArgoCD configuration
  - Cert-Manager setup
  - External DNS configuration
  - Ingress-Nginx controller
  - Monitoring stack

- [`/root`](./root) - Root application configurations
  - Apps-of-apps pattern for ArgoCD
  - Infrastructure components orchestration
