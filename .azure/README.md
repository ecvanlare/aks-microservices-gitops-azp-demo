# Azure DevOps Pipeline Configurations

## Pipeline Overview

### Infrastructure Pipeline
- Manages Azure infrastructure using Terraform
- Triggers on `/terraform` changes
- Handles infrastructure provisioning and updates

### GitOps Bootstrap Pipeline
- One-time cluster initialization
- Installs ArgoCD, Cert-Manager, NGINX Ingress, Monitoring stack
- Sets up cluster-wide dependencies

### Application Pipeline
- **Build**: Builds containers, runs tests, security scans
- **Deploy**: Updates configurations via GitOps
- Triggers on `/src` changes
- Uses Azure Container Registry

## Required Variables

### Common
```yaml
AZURE_SUBSCRIPTION: <subscription-id>
RESOURCE_GROUP: <resource-group-name>
```

### Infrastructure
```yaml
ARM_SUBSCRIPTION_ID: <subscription-id>
STORAGE_ACCOUNT_NAME: <terraform-state-storage>
CONTAINER_NAME: <terraform-state-container>
TERRAFORM_STATE_KEY: <terraform-state-key>
```

### Kubernetes
```yaml
AKS_CLUSTER_NAME: <cluster-name>
GITOPS_REPO_URL: <repository-url>
GITOPS_BRANCH: <target-branch>
ARGOCD_GIT_PRIVATE_KEY: <argocd-ssh-key>
```

### Docker
```yaml
ACR_NAME: <acr-name>
```

## Service Connections

1. **Azure Resource Manager** (`azure-subscription`)
   - For Azure resource management
   - Needs Contributor role

2. **Azure Container Registry** (`acr-connection`)
   - For container operations
   - Needs AcrPush role

3. **GitHub** (`github-connection`)
   - For GitOps operations
   - Needs repo scope

## Development Flow
1. Code changes in `/src`
2. Automatic build triggers
3. Deploy pipeline creates PR
4. Merge triggers ArgoCD sync 