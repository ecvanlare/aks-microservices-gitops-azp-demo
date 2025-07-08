# Online Boutique Helm Chart

# Complete Deployment Guide

## Prerequisites
- AKS cluster with external IP
- Domain name pointing to cluster IP
- Cloudflare account (for ExternalDNS automation)

## What Gets Deployed

- ✅ **Cert-Manager** (cluster-wide SSL certificate management)
- ✅ **NGINX Ingress** (load balancer)
- ✅ **All microservices** (frontend, cart, checkout, etc.)
- ✅ **ClusterIssuer** (Let's Encrypt configuration)
- ✅ **SSL certificates** (automatic via Let's Encrypt)
- ✅ **ExternalDNS** (automatic DNS management with Cloudflare)

## Step 1: Initial Deployment

```bash
# 1. Add repositories
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add jetstack https://charts.jetstack.io
helm repo update

# 2. Install Cert-Manager CRDs (required first)
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.18.2/cert-manager.crds.yaml

# 3. Install Cert-Manager cluster-wide (required for SSL certificates)
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=false \
  --wait --timeout=5m

# 4. Deploy the application
cd helm-chart
helm dependency update
helm upgrade --install test . --namespace test --create-namespace --wait --timeout=15m
```

## Step 2: Configure DNS

**⚠️ IMPORTANT: DNS must be configured BEFORE SSL certificates can be issued**

### Get Your Cluster's External IP
```bash
kubectl get svc -n test | grep ingress-nginx-controller
```

### Configure DNS A Record
- **Type:** A record
- **Name:** Your domain (e.g., `ecvlsolutions.com` or `@` for root domain)
- **Value:** External IP from step above (e.g., `74.177.247.49`)
- **TTL:** 300 seconds (or default)

### Wait for DNS Propagation
- Allow 5-10 minutes for DNS changes to propagate globally

### Verify DNS Resolution
```bash
nslookup yourdomain.com
# Should return your cluster's external IP
```

## Step 3: Deploy ExternalDNS (Optional - Automated DNS)

### Create Cloudflare API Token
1. Go to [Cloudflare API Tokens](https://dash.cloudflare.com/profile/api-tokens)
2. Click "Create Token"
3. Choose "Custom token" template
4. Configure permissions:
   - **Zone**: `Zone:Zone:Edit` (for your domain)
   - **Zone**: `Zone:DNS:Edit` (for DNS record management)
5. Set Zone Resources to "Include: Specific zone" and select your domain
6. Click "Continue to summary" and "Create Token"
7. **Copy the token** (you won't see it again!)

### Get Your Zone ID
1. Go to [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. Select your domain
3. Look at the URL: `https://dash.cloudflare.com/zone/abc123def456`
4. **The Zone ID** is the `abc123def456` part

### Configure ExternalDNS
Edit `helm-chart/infra/external-dns/external-dns-values.yaml`:

```yaml
# Environment variables for Cloudflare configuration
env:
  - name: CF_API_KEY
    value: "your-cloudflare-api-key"  # Replace with your API key
  - name: CF_API_EMAIL
    value: "your-email@example.com"  # Replace with your Cloudflare email
  - name: CF_ZONE_ID
    value: "your-zone-id"  # Replace with your zone ID
```

### Deploy ExternalDNS
```bash
# Add ExternalDNS Helm repository
helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
helm repo update

# Create namespace
kubectl create namespace external-dns --dry-run=client -o yaml | kubectl apply -f -

# Deploy ExternalDNS
helm upgrade --install external-dns external-dns/external-dns \
  --namespace external-dns \
  --values infra/external-dns/external-dns-values.yaml \
  --wait --timeout=5m
```

## Step 4: Enable SSL

### Verify DNS Configuration
```bash
# Get your cluster's external IP
kubectl get svc -n test | grep ingress-nginx-controller

# Verify DNS points to your cluster
nslookup yourdomain.com
# Should return your cluster's external IP
```

### Enable SSL in values.yaml
Edit `helm-chart/values.yaml`:
```yaml
ssl:
  enabled: true
  clusterIssuer: "letsencrypt-prod"
```

### Deploy SSL Configuration
```bash
helm upgrade test . --namespace test --wait --timeout=5m
```

### Monitor Certificate Issuance
```bash
# Watch certificate status
kubectl get certificates -n test -w
# Wait for READY=True

# Check certificate details
kubectl describe certificate test-helm-chart-tls -n test
```

### Verify HTTPS Access
```bash
# Test HTTPS
curl -I https://yourdomain.com

# Open in browser: https://yourdomain.com
# Should show valid SSL certificate (no warnings)
```

## Step 5: Verify Complete Deployment

```bash
# Check Cert-Manager (cluster-wide)
kubectl get pods -n cert-manager
kubectl get clusterissuers

# Check application in test namespace
kubectl get pods -n test
kubectl get svc -n test
kubectl get ingress -n test

# Check SSL certificates (if SSL is enabled)
kubectl get certificates -n test
kubectl describe certificate test-helm-chart-tls -n test

# Check ExternalDNS (if deployed)
kubectl get pods -n external-dns
kubectl logs deployment/external-dns -n external-dns

# Test HTTP access
curl -I http://yourdomain.com

# Test HTTPS access (if SSL is enabled)
curl -I https://yourdomain.com
```

## Success Indicators
- ✅ Certificate shows `READY=True`
- ✅ `https://yourdomain.com` loads without warnings
- ✅ Browser shows valid SSL certificate
- ✅ ExternalDNS pods running (if deployed)
- ✅ DNS records automatically managed (if ExternalDNS deployed)

## Troubleshooting

### SSL Issues

#### Certificate Not Ready
```bash
# Check certificate status
kubectl describe certificate test-helm-chart-tls -n test

# Check Let's Encrypt orders
kubectl get orders -n test
kubectl describe order <order-name> -n test

# Check challenges
kubectl get challenges -n test
kubectl describe challenge <challenge-name> -n test
```

#### Retry Certificate Issuance
```bash
# Delete failed certificate to retry
kubectl delete certificate test-helm-chart-tls -n test
# Certificate will be recreated automatically
```

#### Common SSL Issues
- **DNS not propagated**: Wait 5-10 minutes, verify with `nslookup`
- **Port 80 blocked**: Ensure NSG allows inbound HTTP from Internet
- **Challenge timeout**: Check ingress is routing ACME challenges correctly

### ExternalDNS Issues

#### ExternalDNS not creating records
```bash
# Check logs
kubectl logs deployment/external-dns -n external-dns

# Check if API credentials are working
kubectl describe pod -l app.kubernetes.io/name=external-dns -n external-dns
```

#### API Token Issues
- Verify token has correct permissions
- Check if domain is properly added to Cloudflare
- Ensure token is not expired

#### DNS Propagation
- Cloudflare changes are usually instant
- External DNS propagation may take 5-10 minutes

### Test ExternalDNS Automation

Create a test ingress to verify ExternalDNS is working:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: test-ingress
  namespace: test
  annotations:
    external-dns.alpha.kubernetes.io/hostname: test.yourdomain.com
spec:
  rules:
  - host: test.yourdomain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend
            port:
              number: 80
```

## Verify Deployment

```bash
# Check Cert-Manager (cluster-wide)
kubectl get pods -n cert-manager
kubectl get clusterissuers

# Check application in test namespace
kubectl get pods -n test
kubectl get svc -n test
kubectl get ingress -n test

# Check SSL certificates (if SSL is enabled)
kubectl get certificates -n test
kubectl describe certificate test-helm-chart-tls -n test

# Test HTTP access
curl -I http://yourdomain.com

# Test HTTPS access (if SSL is enabled)
curl -I https://yourdomain.com
```

## Architecture

This deployment follows infrastructure-as-code best practices:

- **Cert-Manager**: Installed cluster-wide for SSL certificate management
- **NGINX Ingress**: Installed via Helm dependency for load balancing
- **ExternalDNS**: Automatically manages DNS records in Cloudflare
- **Application**: All microservices deployed in the `test` namespace
- **Infrastructure**: ClusterIssuer and other cluster-wide resources

## Configuration

Edit `values.yaml` to customize:
- Domain name (`ingress.host`)
- SSL settings (`ssl.enabled`)
- Service configurations
- Resource limits (optimized for production workloads)

### Resource Allocation

The chart includes optimized resource requests and limits for each service:

- **High-traffic services** (adservice, cartservice): 200m CPU, 128-180Mi memory
- **Core services** (frontend, checkout, shipping): 100m CPU, 64-128Mi memory  
- **Data services** (recommendationservice): 100m CPU, 220Mi memory
- **Redis cache**: 100m CPU, 128Mi memory

These settings balance performance with cost efficiency for typical e-commerce workloads.

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
   # Port-forward ingress controller
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