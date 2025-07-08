# Online Boutique Helm Chart

## Quick Deploy

### Prerequisites
- AKS cluster with external IP
- Domain name pointing to cluster IP

### Deployment Steps

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

# 5. Configure DNS and Enable SSL (see sections below)
```

## What Gets Deployed

- ✅ **Cert-Manager** (cluster-wide SSL certificate management)
- ✅ **NGINX Ingress** (load balancer)
- ✅ **All microservices** (frontend, cart, checkout, etc.)
- ✅ **ClusterIssuer** (Let's Encrypt configuration)
- ✅ **SSL certificates** (automatic via Let's Encrypt)

## DNS Configuration

**⚠️ IMPORTANT: DNS must be configured BEFORE SSL certificates can be issued**

### Step 1: Get Your Cluster's External IP
```bash
kubectl get svc -n test | grep ingress-nginx-controller
```

### Step 2: Configure DNS A Record
- **Type:** A record
- **Name:** Your domain (e.g., `ecvlsolutions.com` or `@` for root domain)
- **Value:** External IP from step 1 (e.g., `74.177.247.49`)
- **TTL:** 300 seconds (or default)

### Step 3: Wait for DNS Propagation
- Allow 5-10 minutes for DNS changes to propagate globally

### Step 4: Verify DNS Resolution
```bash
nslookup yourdomain.com
# Should return your cluster's external IP
```

# SSL Setup with Let's Encrypt and Cert-Manager

## Prerequisites
- Application already deployed and accessible via HTTP
- Domain name pointing to your cluster's external IP
- Cert-Manager installed cluster-wide

---

## Step 1: Verify DNS Configuration
```bash
# Get your cluster's external IP
kubectl get svc -n test | grep ingress-nginx-controller

# Verify DNS points to your cluster
nslookup yourdomain.com
# Should return your cluster's external IP
```

---

## Step 2: Enable SSL in values.yaml
Edit `helm-chart/values.yaml`:
```yaml
ssl:
  enabled: true
  clusterIssuer: "letsencrypt-prod"
```

---

## Step 3: Deploy SSL Configuration
```bash
helm upgrade test . --namespace test --wait --timeout=5m
```

---

## Step 4: Monitor Certificate Issuance
```bash
# Watch certificate status
kubectl get certificates -n test -w
# Wait for READY=True

# Check certificate details
kubectl describe certificate test-helm-chart-tls -n test
```

---

## Step 5: Verify HTTPS Access
```bash
# Test HTTPS
curl -I https://yourdomain.com

# Open in browser: https://yourdomain.com
# Should show valid SSL certificate (no warnings)
```

---

## Troubleshooting SSL Issues

### Certificate Not Ready
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

### Retry Certificate Issuance
```bash
# Delete failed certificate to retry
kubectl delete certificate test-helm-chart-tls -n test
# Certificate will be recreated automatically
```

### Common Issues
- **DNS not propagated**: Wait 5-10 minutes, verify with `nslookup`
- **Port 80 blocked**: Ensure NSG allows inbound HTTP from Internet
- **Challenge timeout**: Check ingress is routing ACME challenges correctly

---

## Success Indicators
- ✅ Certificate shows `READY=True`
- ✅ `https://yourdomain.com` loads without warnings
- ✅ Browser shows valid SSL certificate

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

# SSL Setup with Let's Encrypt and Cert-Manager

## Prerequisites
- Application already deployed and accessible via HTTP
- Domain name pointing to your cluster's external IP
- Cert-Manager installed cluster-wide

---

## Step 1: Verify DNS Configuration
```bash
# Get your cluster's external IP
kubectl get svc -n test | grep ingress-nginx-controller

# Verify DNS points to your cluster
nslookup yourdomain.com
# Should return your cluster's external IP
```

---

## Step 2: Enable SSL in values.yaml
Edit `helm-chart/values.yaml`:
```yaml
ssl:
  enabled: true
  clusterIssuer: "letsencrypt-prod"
```

---

## Step 3: Deploy SSL Configuration
```bash
helm upgrade test . --namespace test --wait --timeout=5m
```

---

## Step 4: Monitor Certificate Issuance
```bash
# Watch certificate status
kubectl get certificates -n test -w
# Wait for READY=True

# Check certificate details
kubectl describe certificate test-helm-chart-tls -n test
```

---

## Step 5: Verify HTTPS Access
```bash
# Test HTTPS
curl -I https://yourdomain.com

# Open in browser: https://yourdomain.com
# Should show valid SSL certificate (no warnings)
```

---

## Troubleshooting SSL Issues

### Certificate Not Ready
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

### Retry Certificate Issuance
```bash
# Delete failed certificate to retry
kubectl delete certificate test-helm-chart-tls -n test
# Certificate will be recreated automatically
```

### Common Issues
- **DNS not propagated**: Wait 5-10 minutes, verify with `nslookup`
- **Port 80 blocked**: Ensure NSG allows inbound HTTP from Internet
- **Challenge timeout**: Check ingress is routing ACME challenges correctly

---

## Success Indicators
- ✅ Certificate shows `READY=True`
- ✅ `https://yourdomain.com` loads without warnings
- ✅ Browser shows valid SSL certificate 