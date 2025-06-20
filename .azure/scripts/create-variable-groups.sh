#!/bin/bash

# Create Azure DevOps Variable Groups - Simple version

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

# Get actual resource names from Azure
az account set --subscription "$SUBSCRIPTION_ID" >/dev/null
ACR_LOGIN_SERVER=$(az acr show --name "$ACR_NAME" --resource-group "$RESOURCE_GROUP" --query "loginServer" -o tsv 2>/dev/null || echo "${ACR_NAME}.azurecr.io")
AKS_CLUSTER_NAME=$(az aks list --resource-group "$RESOURCE_GROUP" --query "[0].name" -o tsv 2>/dev/null || echo "$AKS_NAME")

echo "Creating variable groups..."

# Create Build Variables Group
BUILD_VARS=$(cat << EOF
{
    "variables": {
        "AZURE_SUBSCRIPTION": {"value": "Azure-Service-Connection", "isSecret": false},
        "ACR_NAME": {"value": "$ACR_NAME", "isSecret": false},
        "ACR_LOGIN_SERVER": {"value": "$ACR_LOGIN_SERVER", "isSecret": false},
        "RESOURCE_GROUP": {"value": "$RESOURCE_GROUP", "isSecret": false},
        "LOCATION": {"value": "$LOCATION", "isSecret": false},
        "IMAGE_TAG": {"value": "\$(Build.BuildId)", "isSecret": false},
        "BUILD_SOURCE_BRANCH": {"value": "\$(Build.SourceBranch)", "isSecret": false},
        "BUILD_SOURCE_VERSION": {"value": "\$(Build.SourceVersion)", "isSecret": false}
    }
}
EOF
)

az pipelines variable-group create --variables "$BUILD_VARS" --name "online-boutique-build-vars" --description "Build variables" --authorize true --output none

# Create Deploy Variables Group
DEPLOY_VARS=$(cat << EOF
{
    "variables": {
        "AZURE_SUBSCRIPTION": {"value": "Azure-Service-Connection", "isSecret": false},
        "AKS_CLUSTER_NAME": {"value": "$AKS_CLUSTER_NAME", "isSecret": false},
        "RESOURCE_GROUP": {"value": "$RESOURCE_GROUP", "isSecret": false},
        "ACR_NAME": {"value": "$ACR_NAME", "isSecret": false},
        "ACR_LOGIN_SERVER": {"value": "$ACR_LOGIN_SERVER", "isSecret": false},
        "NAMESPACE": {"value": "online-boutique", "isSecret": false},
        "RELEASE_NAME": {"value": "online-boutique", "isSecret": false},
        "HELM_CHART_PATH": {"value": "online-boutique-chart", "isSecret": false},
        "HELM_VERSION": {"value": "3.12.0", "isSecret": false}
    }
}
EOF
)

az pipelines variable-group create --variables "$DEPLOY_VARS" --name "online-boutique-deploy-vars" --description "Deploy variables" --authorize true --output none

# Create Release Variables Group
RELEASE_VARS=$(cat << EOF
{
    "variables": {
        "AZURE_SUBSCRIPTION": {"value": "Azure-Service-Connection", "isSecret": false},
        "AKS_CLUSTER_NAME": {"value": "$AKS_CLUSTER_NAME", "isSecret": false},
        "RESOURCE_GROUP": {"value": "$RESOURCE_GROUP", "isSecret": false},
        "NAMESPACE": {"value": "online-boutique", "isSecret": false},
        "RELEASE_NAME": {"value": "online-boutique", "isSecret": false},
        "HELM_CHART_PATH": {"value": "online-boutique-chart", "isSecret": false},
        "HELM_VERSION": {"value": "3.12.0", "isSecret": false},
        "KUBERNETES_VERSION": {"value": "1.26", "isSecret": false}
    }
}
EOF
)

az pipelines variable-group create --variables "$RELEASE_VARS" --name "online-boutique-release-vars" --description "Release variables" --authorize true --output none

echo "Variable groups created: online-boutique-build-vars, online-boutique-deploy-vars, online-boutique-release-vars" 