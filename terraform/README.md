# Terraform Infrastructure

## Quick Start

1. **Bootstrap State Storage**
   ```bash
   cd bootstrap
   terraform init
   terraform apply
   ```

2. **Deploy Infrastructure**
   ```bash
   cd ..
   terraform init
   terraform plan
   terraform apply
   ```

## Components

### Core Infrastructure
- **Resource Groups** (`/resource_group`): Resource organization
- **Network** (`/network`): VNet, Subnets, NSGs
- **Identity** (`/identity`): Managed Identities

### Application Platform
- **AKS** (`/aks`): Kubernetes cluster
- **ACR** (`/acr`): Container registry
- **Key Vault** (`/keyvault`): Secrets management

## State Management

The bootstrap process creates:
- Resource Group for state
- Storage Account
- Storage Container 'tfstate'

For state configuration details, see `backend.tf`. 