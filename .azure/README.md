# Azure DevOps Pipeline Configurations

This directory contains Azure DevOps pipeline configurations and related resources.

## Pipeline Structure

### GitOps Bootstrap Pipeline (`/gitops`)
- **Purpose**: One-time cluster initialization and dependency installation
- **Runs**: Manually triggered, only once during initial setup
- **Actions**:
  - Installs ArgoCD
  - Sets up Cert-Manager
  - Configures NGINX Ingress Controller
  - Deploys Prometheus/Grafana
  - Configures ExternalDNS
  - Sets up other cluster-wide dependencies

### Application Build Pipeline (`/application`)
- **Purpose**: Builds and tests microservice containers
- **Triggers**: 
  - On changes to `/src` directory
  - Manual triggers for rebuilds
- **Actions**:
  - Builds Docker images for modified services
  - Runs unit tests
  - Performs security scans
  - Pushes images to Azure Container Registry
  - Triggers the Deploy pipeline on completion

### Deploy Pipeline (`/application/deploy`)
- **Purpose**: Updates application configurations via GitOps
- **Triggers**: 
  - Automatically after successful Application Build
  - Manual triggers for specific deployments
- **Actions**:
  - Creates Pull Request to update image tags in Helm values
  - Updates deployment configurations with new build hashes
  - Triggers ArgoCD sync after PR merge

### Infrastructure Pipeline (`/infrastructure`)
- **Purpose**: Manages Azure infrastructure via Terraform
- **Triggers**:
  - On changes to `/terraform` directory
  - Manual triggers for infrastructure updates
- **Actions**:
  - Validates Terraform configurations
  - Plans infrastructure changes
  - Applies approved changes
  - Updates cluster configurations

## Pipeline Variables

### online-boutique.common
```
AZURE_SUBSCRIPTION=<subscription-id>
RESOURCE_GROUP=<resource-group-name>
```

### online-boutique.devsecops
```
SNYK_TOKEN=<snyk-token>
```

### online-boutique.docker
```
ACR_NAME=<acr-name>
RESOURCE_GROUP=<resource-group-name>
```

### online-boutique.infrastructure
```
ARM_SUBSCRIPTION_ID=<subscription-id>
CONTAINER_NAME=<terraform-state-container>
RESOURCE_GROUP_NAME=<resource-group-name>
STORAGE_ACCOUNT_NAME=<terraform-state-storage>
TERRAFORM_STATE_KEY=<terraform-state-key>
```

### online-boutique.kubernetes
```
AKS_CLUSTER_NAME=<cluster-name>
ARGOCD_GIT_PRIVATE_KEY=<argocd-ssh-key>
AZURE_DEVOPS_SSH_KEY=<azure-devops-ssh-key>
GITHUB_SERVICE_CONNECTION=<github-connection-id>
GITOPS_BRANCH=<target-branch>
GITOPS_REPO_URL=<repository-url>
```

## Service Connections

1. **Azure Resource Manager**
   - Name: `azure-subscription`
   - Used for: Azure resource management
   - Required Permissions: Contributor on subscription

2. **Azure Container Registry**
   - Name: `acr-connection`
   - Used for: Image push/pull operations
   - Required Permissions: AcrPush role

3. **GitHub**
   - Name: `github-connection`
   - Used for: PR creation and GitOps updates
   - Required Permissions: repo scope

## Usage

### Development Workflow
1. Make changes to service code in `/src`
2. Commit and push changes
3. Application Build pipeline triggers automatically
4. Deploy pipeline creates PR with new image tags
5. Merge PR to trigger ArgoCD sync
6. Monitor deployment in ArgoCD UI 