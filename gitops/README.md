# GitOps Repository

This repository contains ArgoCD Application manifests for managing Kubernetes deployments using the App of Apps pattern.

## Structure

```
gitops/
├── applications/          # Application manifests
│   └── online-boutique.yaml
├── infrastructure/        # Infrastructure manifests
│   └── (future infra apps)
├── app-of-apps.yaml      # Bootstrap application
└── README.md
```

## App of Apps Pattern

### Bootstrap Application
- **File**: `app-of-apps.yaml`
- **Purpose**: Manages all other ArgoCD applications
- **Source**: Points to `gitops/applications/`
- **Sync Policy**: Automated with self-healing

### Applications

#### Online Boutique
- **File**: `applications/online-boutique.yaml`
- **Source**: `https://github.com/ecvanlare/online-boutique-private.git`
- **Path**: `helm-chart/`
- **Namespace**: `app`
- **Sync Policy**: Automated with self-healing

## Usage

1. **Apply bootstrap**: `kubectl apply -f gitops/app-of-apps.yaml`
2. **Add new applications**: Create YAML files in `applications/`
3. **Update existing**: Modify the YAML files and commit
4. **ArgoCD will automatically sync** changes to the cluster

## Best Practices

- ✅ Use App of Apps pattern for scalability
- ✅ Keep manifests declarative
- ✅ Use automated sync for production
- ✅ Include proper labels and annotations
- ✅ Document changes in commit messages 