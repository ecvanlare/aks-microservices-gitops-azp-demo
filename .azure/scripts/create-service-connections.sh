#!/bin/bash

# Create Azure DevOps Service Connections

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

# Confirmation prompt
echo "This will destroy and recreate service connections:"
echo "  - svcconn-online-boutique-rg (Azure Resource Manager)"
echo "  - $ACR_NAME (Azure Container Registry)"
echo
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled"
    exit 0
fi

echo "Creating service connections..."

# Create service principal
SP_NAME="AzureDevOps-OnlineBoutique-$PROJECT_NAME"
SCOPE="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP"
SP_JSON=$(az ad sp create-for-rbac --name "$SP_NAME" --role "Contributor" --scopes "$SCOPE" --years 2 --query "{appId:appId, password:password, tenant:tenant}" -o json)

APP_ID=$(echo "$SP_JSON" | jq -r '.appId')
PASSWORD=$(echo "$SP_JSON" | jq -r '.password')
TENANT=$(echo "$SP_JSON" | jq -r '.tenant')
SUBSCRIPTION_NAME=$(az account show --subscription "$SUBSCRIPTION_ID" --query "name" -o tsv)

# Delete existing service connections
az devops service-endpoint list --query "[?name=='svcconn-online-boutique-rg'].id" -o tsv 2>/dev/null | xargs -I {} az devops service-endpoint delete --id {} --yes 2>/dev/null || true
az devops service-endpoint list --query "[?name=='$ACR_NAME'].id" -o tsv 2>/dev/null | xargs -I {} az devops service-endpoint delete --id {} --yes 2>/dev/null || true

# Create Azure Resource Manager service connection
cat > /tmp/azure-sc.json << EOF
{
    "name": "svcconn-online-boutique-rg",
    "type": "azurerm",
    "authorization": {
        "parameters": {
            "tenantid": "$TENANT",
            "authenticationType": "spnKey",
            "serviceprincipalkey": "$PASSWORD"
        },
        "scheme": "ServicePrincipal"
    },
    "data": {
        "subscriptionId": "$SUBSCRIPTION_ID",
        "subscriptionName": "$SUBSCRIPTION_NAME",
        "environment": "AzureCloud",
        "scopeLevel": "Subscription",
        "creationMode": "Automatic"
    }
}
EOF

SC_ID=$(az devops service-endpoint create --service-endpoint-configuration /tmp/azure-sc.json --query "id" -o tsv)
az devops service-endpoint update --id "$SC_ID" --enable-for-all true

# Create ACR service connection
ACR_LOGIN_SERVER=$(az acr show --name "$ACR_NAME" --resource-group "$RESOURCE_GROUP" --query "loginServer" -o tsv 2>/dev/null || echo "${ACR_NAME}.azurecr.io")

cat > /tmp/acr-sc.json << EOF
{
    "name": "$ACR_NAME",
    "type": "dockerregistry",
    "authorization": {
        "parameters": {
            "registry": "$ACR_LOGIN_SERVER",
            "serviceprincipalid": "$APP_ID",
            "serviceprincipalkey": "$PASSWORD",
            "tenantid": "$TENANT"
        },
        "scheme": "ServicePrincipal"
    },
    "data": {
        "registrytype": "Others",
        "registryurl": "https://$ACR_LOGIN_SERVER"
    }
}
EOF

ACR_SC_ID=$(az devops service-endpoint create --service-endpoint-configuration /tmp/acr-sc.json --query "id" -o tsv)
az devops service-endpoint update --id "$ACR_SC_ID" --enable-for-all true

rm -f /tmp/azure-sc.json /tmp/acr-sc.json

# Wait for Azure Resource Manager service connection to be ready
echo "Waiting for service connection to be ready..."
for i in {1..30}; do
    STATUS=$(az devops service-endpoint show --id "$SC_ID" --query "isReady" -o tsv 2>/dev/null)
    if [[ "$STATUS" == "true" ]]; then
        echo "✅ Service connections created successfully"
        break
    elif [[ "$i" -eq 30 ]]; then
        echo "⚠️  Service connection still not ready after 60 seconds"
    else
        sleep 2
    fi
done

az devops service-endpoint list --query "[].{name:name, type:type, isReady:isReady}" -o table 