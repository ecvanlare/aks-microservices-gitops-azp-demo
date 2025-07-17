# GitOps Setup for Online Boutique

This directory contains the GitOps configuration for the Online Boutique application using ArgoCD.

## 📁 Structure

```
gitops/
├── root/
│   └── root-app.yaml                    # Main "App of Apps" - bootstraps everything
├── infrastructure/                       # Infrastructure components
│   ├── cert-manager/
│   │   ├── app.yaml                     # cert-manager installation
│   │   ├── cluster-issuer-app.yaml      # ClusterIssuer (dependsOn: cert-manager)
│   │   └── cluster-issuer.yaml          # ClusterIssuer manifest
│   ├── ingress-nginx/
│   │   └── app.yaml                     # ingress-nginx (dependsOn: cert-manager)
│   ├── external-dns/
│   │   └── app.yaml                     # external-dns (dependsOn: ingress-nginx)
│   └── argocd/
│       ├── app.yaml                     # ArgoCD self-management
│       └── values.yaml                  # ArgoCD Helm values (LoadBalancer config)
└── applications/
    └── app-of-apps-online-boutique.yaml # Application workloads
```

## 🔄 Sync Order

The infrastructure components deploy in the following order due to `dependsOn` relationships:

1. **cert-manager** (no dependencies)
   - Installs CRDs and controllers
   - Must be healthy before others proceed

2. **cluster-issuer** (dependsOn: cert-manager)
   - Creates ClusterIssuer for Let's Encrypt
   - Waits for cert-manager to be ready

3. **ingress-nginx** (dependsOn: cert-manager)
   - Deploys ingress controller
   - Can use cert-manager for SSL certificates

4. **argocd** (dependsOn: cert-manager)
   - Updates ArgoCD configuration
   - Uses cert-manager for ingress SSL

5. **external-dns** (dependsOn: ingress-nginx)
   - Manages DNS records for ingress
   - Needs ingress controller to be running

6. **online-boutique** (no explicit dependencies)
   - Deploys application workloads
   - Can use all infrastructure services

## 🚀 Usage

### Stage 1: Basic ArgoCD Setup
```bash
# 1. Create argocd namespace
kubectl create namespace argocd

# 2. Install ArgoCD (basic installation)
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 3. Port-forward for access (until DNS is ready)
kubectl port-forward -n argocd svc/argocd-server 8080:443

# 4. Access ArgoCD at https://localhost:8080
# Username: admin
# Password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# 5. Add SSH key for private repository access
kubectl -n argocd create secret generic argocd-repo-credentials --from-file=sshPrivateKey=/Users/edem/.ssh/argo-cd

# 6. Login to ArgoCD CLI
argocd login localhost:8080 --username admin --password <ADMIN_PASSWORD> --insecure

# 7. Register your private repo with ArgoCD CLI
argocd repo add git@github.com:ecvanlare/aks-microservices-gitops-demo.git --ssh-private-key-path ~/.ssh/argo-cd

# 8. Add external repositories for infrastructure components
argocd repo add https://charts.jetstack.io --type helm --name jetstack
argocd repo add https://github.com/kubernetes/ingress-nginx.git --type git
argocd repo add https://github.com/kubernetes-sigs/external-dns.git --type git
```

### Stage 2: Deploy Root App and Infrastructure
```bash
# 1. Apply the root app (this will deploy all infrastructure)
kubectl apply -f cluster/root/root-app.yaml

# 2. Wait for infrastructure to deploy (cert-manager, ingress-nginx, external-dns)

# 3. Once DNS resolves, access ArgoCD at https://argocd.ecvlsolutions.com
```


```

### Deploy GitOps Applications
```bash
# Option 1: Apply root app directly with kubectl
kubectl apply -f cluster/root/root-app.yaml

# Option 2: Create via ArgoCD CLI
argocd app create root-app \
  --repo git@github.com:ecvanlare/aks-microservices-gitops-demo.git \
  --path gitops/ \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace argocd \
  --directory-recurse \
  --sync-policy automated \
  --revision argocd

# Sync the root application (if using CLI method)
argocd app sync root-app

# Or create via ArgoCD UI:
# 1. Go to Applications → + New App
# 2. Set Repository URL: git@github.com:ecvanlare/aks-microservices-gitops-demo.git
# 3. Set Path: gitops/
# 4. Enable Directory Recurse
# 5. Set Revision: argocd
# 6. Enable Auto-Sync
```

### Monitor Progress
```bash
# List all applications
argocd app list

# Check sync status
argocd app get root-app
```

## 🔧 Configuration

### Repository
- **URL**: `git@github.com:ecvanlare/aks-microservices-gitops-demo.git`
- **Branch**: `argocd`
- **SSH Key**: Uses `~/.ssh/argo-cd` for authentication
- **SSH Setup**: Add SSH key to ArgoCD for private repo access

### Infrastructure Components
- **cert-manager**: v1.14.4 with CRDs
- **ingress-nginx**: controller-v1.10.1 with Azure LoadBalancer
- **external-dns**: v0.14.2 with Cloudflare
- **ArgoCD**: Self-managed with LoadBalancer service type

### Dependencies
All `dependsOn` relationships ensure proper installation order and prevent race conditions.

### Git Repositories
The infrastructure applications use public Git repositories and Helm repositories which must be added to ArgoCD:
- **cert-manager**: `https://charts.jetstack.io` (Helm repository)
- **ingress-nginx**: `https://github.com/kubernetes/ingress-nginx.git`
- **external-dns**: `https://github.com/kubernetes-sigs/external-dns.git`

These repositories are added via ArgoCD CLI during the bootstrap process.

## 🎯 Benefits

- ✅ **Clear separation** between infrastructure and applications
- ✅ **Proper dependency management** with `dependsOn`
- ✅ **Automated sync** with self-healing
- ✅ **Simple structure** with one root app
- ✅ **Easy maintenance** and troubleshooting 