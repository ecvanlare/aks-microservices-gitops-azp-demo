#!/bin/bash

# Get Azure DevOps Values - Auto-discovery version

set -e

show_usage() {
    echo "Usage: $0 [-o <org-url>] [-p <project>] [-s <subscription>]"
    echo "Example: $0 -o https://dev.azure.com/myorg -p myproject -s subscription-id"
    echo "Or just run: $0 (will auto-discover values)"
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

# Install Azure DevOps extension if needed
if ! az extension list --query "[?name=='azure-devops'].name" -o tsv | grep -q "azure-devops"; then
    echo "Installing Azure DevOps CLI extension..."
    az extension add --name azure-devops
fi

# Auto-discover values if not provided
if [[ -z "$ORGANIZATION_URL" ]]; then
    echo "Auto-discovering Azure DevOps organization..."
    # Try to get from current Azure DevOps context
    ORG_CONFIG=$(az devops configure --list 2>/dev/null | grep "organization" | head -1 | cut -d'=' -f2 | tr -d ' ')
    if [[ -n "$ORG_CONFIG" ]]; then
        ORGANIZATION_URL="$ORG_CONFIG"
        echo "Found organization: $ORGANIZATION_URL"
    else
        echo "Could not auto-discover organization URL. Please provide with -o parameter."
        show_usage
        exit 1
    fi
fi

if [[ -z "$PROJECT_NAME" ]]; then
    echo "Auto-discovering Azure DevOps project..."
    # Try to get from current Azure DevOps context
    PROJ_CONFIG=$(az devops configure --list 2>/dev/null | grep "project" | head -1 | cut -d'=' -f2 | tr -d ' ')
    if [[ -n "$PROJ_CONFIG" ]]; then
        PROJECT_NAME="$PROJ_CONFIG"
        echo "Found project: $PROJECT_NAME"
    else
        # Try to list projects and pick the first one
        echo "Listing available projects..."
        PROJECTS=$(az devops project list --organization "$ORGANIZATION_URL" --query "[].name" -o tsv 2>/dev/null | head -1)
        if [[ -n "$PROJECTS" ]]; then
            PROJECT_NAME="$PROJECTS"
            echo "Using first available project: $PROJECT_NAME"
        else
            echo "Could not auto-discover project name. Please provide with -p parameter."
            show_usage
            exit 1
        fi
    fi
fi

if [[ -z "$SUBSCRIPTION_ID" ]]; then
    echo "Auto-discovering Azure subscription..."
    # Get current subscription
    SUBSCRIPTION_ID=$(az account show --query "id" -o tsv 2>/dev/null)
    if [[ -n "$SUBSCRIPTION_ID" ]]; then
        SUBSCRIPTION_NAME=$(az account show --query "name" -o tsv 2>/dev/null)
        echo "Found subscription: $SUBSCRIPTION_NAME ($SUBSCRIPTION_ID)"
    else
        echo "Could not auto-discover subscription. Please provide with -s parameter."
        show_usage
        exit 1
    fi
fi

# Configure Azure DevOps defaults
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
    else
        echo "Resource group $RESOURCE_GROUP not found"
    fi
fi

echo
echo "=== Usage Examples ==="
echo "./create-service-connections.sh -o \"$ORGANIZATION_URL\" -p \"$PROJECT_NAME\" -s \"$SUBSCRIPTION_ID\""
echo "./create-variable-groups.sh -o \"$ORGANIZATION_URL\" -p \"$PROJECT_NAME\" -s \"$SUBSCRIPTION_ID\"" 