# Infrastructure Chart

This chart manages all infrastructure components for the Online Boutique application.

## Components

- **ingress-nginx**: Load balancer and ingress controller
- **cert-manager**: SSL certificate management with Let's Encrypt
- **external-dns**: Automated DNS management with Cloudflare
- **argo-cd**: GitOps deployment management

## Installation

```bash
# Add required Helm repositories
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add jetstack https://charts.jetstack.io
helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Install infrastructure components
cd infra-chart
helm dependency update
helm upgrade --install infra . --namespace infra --create-namespace --wait --timeout=15m
```

## Configuration

Edit `values.yaml` to customize:
- Domain names
- Resource limits
- SSL settings
- ArgoCD configuration
- ClusterIssuer settings

### ClusterIssuer Configuration

The ClusterIssuer is automatically created with these settings:
```yaml
clusterIssuer:
  enabled: true
  name: letsencrypt-prod
  server: https://acme-v02.api.letsencrypt.org/directory
  email: admin@ecvlsolutions.com
  ingressClass: nginx
```

### External-DNS Setup

For Cloudflare integration, create a secret with your API token:
```bash
kubectl create secret generic cloudflare-api-token \
  --from-literal=token=your-cloudflare-api-token \
  -n infra
```

## Dependencies

All components are managed as Helm dependencies:
- ingress-nginx: 4.7.1
- cert-manager: 1.18.2
- external-dns: 1.14.1
- argo-cd: 5.51.6

## SSL Setup

The ClusterIssuer is automatically created for Let's Encrypt SSL certificates.

## ArgoCD Access

After installation, access ArgoCD UI:
```bash
kubectl port-forward svc/infra-argo-cd-server -n infra 9090:80
# Visit: http://localhost:9090
# Username: admin
# Password: $(kubectl -n infra get secret infra-argo-cd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
``` 