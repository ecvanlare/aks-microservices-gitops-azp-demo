#!/bin/bash

# Get Azure DevOps Values - Simple version

set -e

show_usage() {
    echo "Usage: $0 -o <org-url> -p <project> [-s <subscription>]"
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

if [[ -z "$ORGANIZATION_URL" || -z "$PROJECT_NAME" ]]; then
    echo "Missing required parameters"
    show_usage
    exit 1
fi

# Install Azure DevOps extension if needed
if ! az extension list --query "[?name=='azure-devops'].name" -o tsv | grep -q "azure-devops"; then
    az extension add --name azure-devops
fi

az devops configure --defaults organization="$ORGANIZATION_URL" project="$PROJECT_NAME"

echo "=== Azure DevOps Values ==="
echo "Organization: $ORGANIZATION_URL"
echo "Project: $PROJECT_NAME"
echo "Project ID: $(az devops project show --project "$PROJECT_NAME" --query "id" -o tsv)"
echo

echo "=== Service Connections ==="
az devops service-endpoint list --query "[].{name:name, type:type}" -o table
echo

echo "=== Variable Groups ==="
az pipelines variable-group list --query "[].{name:name, description:description}" -o table
echo

if [[ -n "$SUBSCRIPTION_ID" ]]; then
    echo "=== Azure Resources ==="
    az account set --subscription "$SUBSCRIPTION_ID" >/dev/null
    
    RESOURCE_GROUP="rg-online-boutique"
    ACR_NAME="acronlineboutique"
    
    if az group show --name "$RESOURCE_GROUP" &>/dev/null; then
        echo "Resource Group: $RESOURCE_GROUP"
        
        if az acr show --name "$ACR_NAME" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
            echo "ACR: $ACR_NAME ($(az acr show --name "$ACR_NAME" --resource-group "$RESOURCE_GROUP" --query "loginServer" -o tsv))"
        fi
        
        AKS_CLUSTERS=$(az aks list --resource-group "$RESOURCE_GROUP" --query "[].{name:name, version:kubernetesVersion}" -o table 2>/dev/null || echo "No AKS clusters found")
        echo "AKS Clusters:"
        echo "$AKS_CLUSTERS"
    fi
fi

echo
echo "=== Usage Examples ==="
echo "./create-service-connections.sh -o \"$ORGANIZATION_URL\" -p \"$PROJECT_NAME\" -s \"$SUBSCRIPTION_ID\""
echo "./create-variable-groups.sh -o \"$ORGANIZATION_URL\" -p \"$PROJECT_NAME\" -s \"$SUBSCRIPTION_ID\"" 