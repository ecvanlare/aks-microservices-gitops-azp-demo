# Bootstrap Configuration

This directory contains the bootstrap configuration for creating the Azure Storage Account that will store the Terraform state for the main infrastructure.

## What this creates

- Resource Group: `online-boutique-bootstrap`
- Storage Account: `onlineboutiquestate`
- Storage Container: `tfstate`

## Usage

1. Make sure you're logged into Azure:
   ```bash
   az login
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Review the planned changes:
   ```bash
   terraform plan
   ```

4. Apply the configuration:
   ```bash
   terraform apply
   ```

After this is complete, you can proceed with the main infrastructure configuration in the parent directory. 