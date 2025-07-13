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
│       ├── values.yaml                  # ArgoCD Helm values
│       └── ingress.yaml                 # ArgoCD ingress config
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

### Bootstrap Everything
```bash
# Create the root application in ArgoCD
argocd app create root-app \
  --repo git@github.com:ecvanlare/online-boutique-private.git \
  --path gitops/ \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace argocd \
  --directory-recurse \
  --sync-policy automated \
  --revision argocd

# Sync the root application
argocd app sync root-app
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

### Infrastructure Components
- **cert-manager**: v1.14.4 with CRDs
- **ingress-nginx**: controller-v1.10.1 with Azure LoadBalancer
- **external-dns**: v0.14.2 with Cloudflare
- **ArgoCD**: Self-managed with custom values

### Dependencies
All `dependsOn` relationships ensure proper installation order and prevent race conditions.

## 🎯 Benefits

- ✅ **Clear separation** between infrastructure and applications
- ✅ **Proper dependency management** with `dependsOn`
- ✅ **Automated sync** with self-healing
- ✅ **Simple structure** with one root app
- ✅ **Easy maintenance** and troubleshooting 