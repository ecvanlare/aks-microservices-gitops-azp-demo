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

### Bootstrap ArgoCD (One-time Manual Setup)
```bash
# 1. Create argocd namespace
kubectl create namespace argocd

# 2. Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 3. Apply LoadBalancer service for external access
kubectl apply -f gitops/infrastructure/argocd/server-lb.yaml

# 2. Wait for external IP
kubectl get svc -n argocd

# 3. Access ArgoCD at https://<EXTERNAL-IP>
# Username: admin
# Password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# 4. Add SSH key for private repository access
kubectl -n argocd create secret generic argocd-repo-credentials --from-file=sshPrivateKey=/Users/edem/.ssh/argo-cd

# 5. Login to ArgoCD CLI (required for private repos)
argocd login <EXTERNAL-IP> --username admin --password <ADMIN_PASSWORD> --insecure

# 6. Register your private repo with ArgoCD CLI (required for private repos)
argocd repo add git@github.com:ecvanlare/online-boutique-private.git --ssh-private-key-path ~/.ssh/argo-cd


```

### Deploy GitOps Applications
```bash
# Option 1: Apply root app directly with kubectl
kubectl apply -f gitops/root/root-app.yaml

# Option 2: Create via ArgoCD CLI
argocd app create root-app \
  --repo git@github.com:ecvanlare/online-boutique-private.git \
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
# 2. Set Repository URL: git@github.com:ecvanlare/online-boutique-private.git
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
- **URL**: `git@github.com:ecvanlare/online-boutique-private.git`
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
The infrastructure applications use public Git repositories which ArgoCD can access without additional configuration:
- **cert-manager**: `https://github.com/cert-manager/cert-manager.git`
- **external-dns**: `https://github.com/kubernetes-sigs/external-dns.git`
- **ArgoCD**: `https://github.com/argoproj/argo-helm.git`

These are public repositories, so no additional repository configuration is needed in ArgoCD.

## 🎯 Benefits

- ✅ **Clear separation** between infrastructure and applications
- ✅ **Proper dependency management** with `dependsOn`
- ✅ **Automated sync** with self-healing
- ✅ **Simple structure** with one root app
- ✅ **Easy maintenance** and troubleshooting 