# Online Boutique Helm Chart

# Complete Deployment Guide

## Prerequisites
- AKS cluster with external IP
- Domain name pointing to cluster IP
- Cloudflare account (for ExternalDNS automation)

## GitOps with ArgoCD

This setup uses ArgoCD for GitOps deployment. The ArgoCD Application is defined in `argocd-application.yaml` at the repository root, not within the Helm chart to avoid circular dependencies.

### ArgoCD Deployment Flow
1. **Infrastructure components** (ingress-nginx, cert-manager, external-dns) are deployed via the deployment script
2. **ArgoCD** is installed and configured
3. **ArgoCD Application** is applied to manage the application deployment
4. **Application** is automatically deployed and managed by ArgoCD

## What Gets Deployed

- ✅ **All microservices** (frontend, cart, checkout, etc.)
- ✅ **Redis cache** (session storage)
- ✅ **HPA** (Horizontal Pod Autoscaler)
- ✅ **Ingress** (application routing)

**Note**: Infrastructure components (Cert-Manager, NGINX Ingress, External-DNS, ArgoCD) are now managed by the `infra-chart`.

## Quick Deployment

### Step 1: Deploy Infrastructure First
```bash
# 1. Deploy infrastructure components
cd infra-chart
helm dependency update
helm upgrade --install infra . --namespace infra --create-namespace --wait --timeout=15m
cd ..
```

### Step 2: Deploy Application
```bash
# 2. Deploy the application
cd cluster/helm/online-boutique
helm dependency update
helm upgrade --install online-boutique . --namespace online-boutique --create-namespace --wait --timeout=15m
```

### Step 3: Enable SSL (Optional)
```bash
# SSL is automatically managed by the infra-chart
# Certificates are created automatically via cert-manager
```

### Step 4: Verify Deployment
```bash
# Check infrastructure components
kubectl get pods -n infra                 # Verify infrastructure pods
kubectl get pods -n online-boutique       # Check application pods
kubectl get ingress -n online-boutique    # Check ingress configuration

# Check SSL certificates (if enabled)
kubectl get certificates -n online-boutique  # Verify SSL certificate status

# Test access
curl -I http://ecvlsolutions.com          # Test HTTP access
curl -I https://ecvlsolutions.com         # Test HTTPS access (if SSL enabled)
```

## Success Indicators
- ✅ Certificate shows `READY=True` (if SSL enabled)
- ✅ `https://yourdomain.com` loads without warnings
- ✅ ExternalDNS pods running
- ✅ DNS records automatically managed

## Troubleshooting

### SSL Issues

#### Certificate Not Ready
```bash
kubectl describe certificate test-helm/online-boutique-tls -n test    # Check certificate details and errors
kubectl get orders -n test                                  # Check Let's Encrypt orders
kubectl get challenges -n test                              # Check ACME challenges
```

#### Retry Certificate Issuance
```bash
kubectl delete certificate test-helm/online-boutique-tls -n test      # Delete failed certificate
# Certificate will be recreated automatically
```

#### Common SSL Issues
- **DNS not propagated**: Wait 5-10 minutes, verify with `nslookup`
- **Port 80 blocked**: Ensure NSG allows inbound HTTP from Internet
- **Challenge timeout**: Check ingress is routing ACME challenges correctly

### ExternalDNS Issues
```bash
kubectl logs deployment/external-dns -n external-dns        # Check ExternalDNS logs
kubectl describe pod -l app.kubernetes.io/name=external-dns -n external-dns  # Check pod details
```

## Architecture

This deployment follows infrastructure-as-code best practices:

- **Infrastructure Chart**: Manages ingress-nginx, cert-manager, external-dns, and argocd
- **Application Chart**: Manages all microservices and application components
- **GitOps**: ArgoCD automatically deploys and manages the application
- **SSL**: Automatic certificate management via cert-manager
- **DNS**: Automated DNS management via external-dns

## Configuration

Edit `values.yaml` to customize:
- Domain name (`ingress.host`)
- SSL settings (`ssl.enabled`)
- Service configurations
- Resource limits

### Resource Allocation

The chart includes optimized resource requests and limits for each service:

- **High-traffic services** (adservice, cartservice): 200m CPU, 128-180Mi memory
- **Core services** (frontend, checkout, shipping): 100m CPU, 64-128Mi memory  
- **Data services** (recommendationservice): 100m CPU, 220Mi memory
- **Redis cache**: 100m CPU, 128Mi memory

## Ingress Host Rules & Local Testing

By default, the ingress is configured to only respond to requests with the `Host` header matching your domain (e.g., `ecvlsolutions.com`). This is best practice for production, but can cause confusion when testing locally or accessing via the cluster's external IP.

### Production Behavior
- The ingress rule matches only requests with `Host: yourdomain.com`.
- Browsers and real users will send the correct Host header when accessing `https://yourdomain.com`.
- Direct access via IP (e.g., `http://<external-ip>`) will return 404 Not Found.

### Local Testing & Debugging
If you want to test via port-forward or direct IP, you have two options:

1. **Use the correct Host header in your requests:**
   ```bash
   # Port-forward ingress controller to local machine
   kubectl port-forward -n test svc/test-ingress-nginx-controller 8080:80

   # Test with Host header (should return 200 OK)
   curl -I -H "Host: ecvlsolutions.com" http://localhost:8080

   # Test without Host header (should return 404 Not Found)
   curl -I http://localhost:8080
   ```

2. **Add a default ingress rule (no host) for local testing:**
   - Edit `templates/ingress.yaml` to include a rule without `host:`
   - This will route all requests (even those without a Host header) to your frontend service.

   Example:
   ```yaml
   rules:
     - host: ecvlsolutions.com
       http:
         paths: ...
     - http:
         paths: ...
   ```

### Troubleshooting 404 Errors
- **404 Not Found when accessing via IP or localhost:**
  - This is expected if the ingress only matches your domain.
  - Use the correct Host header or add a default rule for local testing.
- **200 OK with Host header:**
  - Ingress is working as intended.

### Best Practice
- For production, only match your real domain in ingress rules.
- For local testing, add a default rule or use the Host header as shown above.

---

## Setup References

### ExternalDNS Configuration

#### Create Cloudflare API Token
1. Go to [Cloudflare API Tokens](https://dash.cloudflare.com/profile/api-tokens)
2. Click "Create Token"
3. Choose "Custom token" template
4. Configure permissions:
   - **Zone**: `Zone:Zone:Edit` (for your domain)
   - **Zone**: `Zone:DNS:Edit` (for DNS record management)
5. Set Zone Resources to "Include: Specific zone" and select your domain
6. Click "Continue to summary" and "Create Token"
7. **Copy the token** (you won't see it again!)

#### Get Your Zone ID
1. Go to [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. Select your domain
3. Look at the URL: `https://dash.cloudflare.com/zone/abc123def456`
4. **The Zone ID** is the `abc123def456` part

#### Configure ExternalDNS Values
Edit `cluster/helm/online-boutique/infra/external-dns/external-dns-values.yaml`:

```yaml
# Environment variables for Cloudflare configuration
env:
  - name: CF_API_TOKEN
    value: "your-cloudflare-api-token"  # Replace with your API token
  - name: CF_ZONE_ID
    value: "your-zone-id"  # Replace with your zone ID
```

### Manual DNS Configuration (Alternative - Only if NOT using ExternalDNS)

#### Get Your Cluster's External IP
```bash
kubectl get svc -n test | grep ingress-nginx-controller
```

#### Configure DNS A Record
- **Type:** A record
- **Name:** Your domain (e.g., `ecvlsolutions.com` or `@` for root domain)
- **Value:** External IP from step above (e.g., `74.177.247.49`)
- **TTL:** 300 seconds (or default)

#### Wait for DNS Propagation
- Allow 5-10 minutes for DNS changes to propagate globally

#### Verify DNS Resolution
```bash
nslookup yourdomain.com
# Should return your cluster's external IP
``` 