#!/bin/bash

# Create Azure DevOps Variable Groups

set -e

show_usage() {
    echo "Usage: $0 -o <org-url> -p <project> -s <subscription>"
    echo "Example: $0 -o https://dev.azure.com/myorg -p myproject -s subscription-id"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -o) ORGANIZATION_URL="$2"; shift 2 ;;
        -p) PROJECT_NAME="$2"; shift 2 ;;
        -s) SUBSCRIPTION_ID="$2"; shift 2 ;;
        -h|--help) show_usage; exit 0 ;;
        *) echo "Unknown option $1"; show_usage; exit 1 ;;
    esac
done

if [[ -z "$ORGANIZATION_URL" || -z "$PROJECT_NAME" || -z "$SUBSCRIPTION_ID" ]]; then
    echo "Missing required parameters"
    show_usage
    exit 1
fi

# Install Azure DevOps extension if needed
if ! az extension list --query "[?name=='azure-devops'].name" -o tsv | grep -q "azure-devops"; then
    az extension add --name azure-devops
fi

az devops configure --defaults organization="$ORGANIZATION_URL" project="$PROJECT_NAME"

# Default resource names
RESOURCE_GROUP="rg-online-boutique"
ACR_NAME="acronlineboutique"
AKS_NAME="aks-online-boutique"
LOCATION="uksouth"

# Confirmation prompt
echo "This will destroy and recreate variable groups:"
echo "  - online-boutique.common"
echo "  - online-boutique.docker"
echo "  - online-boutique.kubernetes"
echo "  - terraform.infrastructure"
echo
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled"
    exit 0
fi

echo "Creating variable groups..."

# Get actual resource names from Azure
az account set --subscription "$SUBSCRIPTION_ID" >/dev/null
ACR_LOGIN_SERVER=$(az acr show --name "$ACR_NAME" --resource-group "$RESOURCE_GROUP" --query "loginServer" -o tsv 2>/dev/null || echo "${ACR_NAME}.azurecr.io")
AKS_CLUSTER_NAME=$(az aks list --resource-group "$RESOURCE_GROUP" --query "[0].name" -o tsv 2>/dev/null || echo "$AKS_NAME")

# Delete existing variable groups
az pipelines variable-group list --query "[?name=='online-boutique.common'].id" -o tsv 2>/dev/null | xargs -I {} az pipelines variable-group delete --id {} --yes 2>/dev/null || true
az pipelines variable-group list --query "[?name=='online-boutique.docker'].id" -o tsv 2>/dev/null | xargs -I {} az pipelines variable-group delete --id {} --yes 2>/dev/null || true
az pipelines variable-group list --query "[?name=='online-boutique.kubernetes'].id" -o tsv 2>/dev/null | xargs -I {} az pipelines variable-group delete --id {} --yes 2>/dev/null || true
az pipelines variable-group list --query "[?name=='terraform.infrastructure'].id" -o tsv 2>/dev/null | xargs -I {} az pipelines variable-group delete --id {} --yes 2>/dev/null || true

# Create Common Variables Group
COMMON_VARS=$(cat << EOF
{
    "variables": {
        "AZURE_SUBSCRIPTION": {"value": "svcconn-online-boutique-rg", "isSecret": false},
        "RESOURCE_GROUP": {"value": "$RESOURCE_GROUP", "isSecret": false},
        "ACR_NAME": {"value": "$ACR_NAME", "isSecret": false},
        "AKS_CLUSTER_NAME": {"value": "$AKS_CLUSTER_NAME", "isSecret": false}
    }
}
EOF
)

az pipelines variable-group create --variables "$COMMON_VARS" --name "online-boutique.common" --description "Common variables for all pipelines" --authorize true --output none

# Create Docker Variables Group
DOCKER_VARS=$(cat << EOF
{
    "variables": {
        "ACR_LOGIN_SERVER": {"value": "$ACR_LOGIN_SERVER", "isSecret": false},
        "LOCATION": {"value": "$LOCATION", "isSecret": false}
    }
}
EOF
)

az pipelines variable-group create --variables "$DOCKER_VARS" --name "online-boutique.docker" --description "Docker build variables" --authorize true --output none

# Create Kubernetes Variables Group
KUBERNETES_VARS=$(cat << EOF
{
    "variables": {
        "NAMESPACE": {"value": "online-boutique", "isSecret": false},
        "RELEASE_NAME": {"value": "online-boutique", "isSecret": false},
        "HELM_CHART_PATH": {"value": "online-boutique-chart", "isSecret": false},
        "HELM_VERSION": {"value": "3.12.0", "isSecret": false},
        "POD_READY_TIMEOUT": {"value": "300", "isSecret": false}
    }
}
EOF
)

az pipelines variable-group create --variables "$KUBERNETES_VARS" --name "online-boutique.kubernetes" --description "Kubernetes deployment variables" --authorize true --output none

# Create Terraform Infrastructure Variables Group
TERRAFORM_VARS=$(cat << EOF
{
    "variables": {
        "STORAGE_ACCOUNT_NAME": {"value": "stonlineboutiquetf", "isSecret": false},
        "CONTAINER_NAME": {"value": "tfstate", "isSecret": false},
        "TERRAFORM_STATE_KEY": {"value": "terraform.tfstate", "isSecret": false},
        "RESOURCE_GROUP_NAME": {"value": "rg-online-boutique-tf", "isSecret": false}
    }
}
EOF
)

az pipelines variable-group create --variables "$TERRAFORM_VARS" --name "terraform.infrastructure" --description "Terraform infrastructure variables" --authorize true --output none

echo "✅ Variable groups created successfully"

az pipelines variable-group list --query "[].{name:name, description:description, variableCount:variableCount}" -o table 