# Azure DevOps Scripts

Simple scripts to manage Azure DevOps resources.

## Scripts

### 1. `get-azure-devops-values.sh`
Shows current Azure DevOps configuration.

```bash
./get-azure-devops-values.sh -o "https://dev.azure.com/myorg" -p "myproject" -s "subscription-id"
```

### 2. `create-service-connections.sh`
Creates Azure Resource Manager and Container Registry service connections.

```bash
./create-service-connections.sh -o "https://dev.azure.com/myorg" -p "myproject" -s "subscription-id"
```

### 3. `create-variable-groups.sh`
Creates build, deploy, and release variable groups.

```bash
./create-variable-groups.sh -o "https://dev.azure.com/myorg" -p "myproject" -s "subscription-id"
```

## Usage

```bash
# Check what you have
./get-azure-devops-values.sh -o "https://dev.azure.com/myorg" -p "myproject" -s "subscription-id"

# Create service connections
./create-service-connections.sh -o "https://dev.azure.com/myorg" -p "myproject" -s "subscription-id"

# Create variable groups
./create-variable-groups.sh -o "https://dev.azure.com/myorg" -p "myproject" -s "subscription-id"
```

## Prerequisites

- Azure CLI installed and authenticated
- Azure DevOps CLI extension (installed automatically)
- Azure subscription with resources deployed 