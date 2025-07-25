# Terraform Infrastructure

This directory contains all the Terraform configurations for provisioning the Azure infrastructure.

## Bootstrap Process

Bootstrap creates an Azure Storage Account to store Terraform state files remotely. This is a one-time setup required before deploying the main infrastructure.

```bash
# Initialize and create state storage
cd bootstrap
terraform init
terraform apply
```

The bootstrap will create:
- Resource Group for Terraform state
- Storage Account for state files
- Storage Container named 'tfstate'

## Main Infrastructure

After state storage is configured, deploy the main infrastructure:

1. **Initialize Terraform with Remote Backend**
   ```bash
   cd ..
   terraform init
   ```

2. **Deploy Infrastructure**
   ```bash
   # Review the plan
   terraform plan

   # Apply the configuration
   terraform apply
   ```

## Module Structure

- [`/acr`](./modules/acr) - Azure Container Registry
- [`/aks`](./modules/aks) - Azure Kubernetes Service
- [`/identity`](./modules/identity) - Managed Identities
- [`/keyvault`](./modules/keyvault) - Azure Key Vault
- [`/network`](./modules/network) - Network Infrastructure
  - [`/nsg`](./modules/network/nsg) - Network Security Groups
  - [`/subnet`](./modules/network/subnet) - Subnet Configuration
  - [`/vnet`](./modules/network/vnet) - Virtual Network
- [`/resource_group`](./modules/resource_group) - Resource Groups 