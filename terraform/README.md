# Online Boutique Infrastructure

This directory contains Terraform configuration for the Online Boutique infrastructure.

## Prerequisites

- Azure CLI installed and configured
- Terraform installed (version >= 1.0.0)

## Configuration

The infrastructure consists of:
- Resource Group: `online-boutique` in UK South (London) region

## Usage

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Review the planned changes:
   ```bash
   terraform plan
   ```

3. Apply the configuration:
   ```bash
   terraform apply
   ```

## Outputs

- `resource_group_name`: The name of the resource group
- `resource_group_location`: The location of the resource group
- `resource_group_id`: The ID of the resource group

## State Management

The Terraform state is stored in Azure Storage Account:
- Storage Account: `onlineboutiquestate`
- Container: `tfstate`
- Key: `terraform.tfstate` 