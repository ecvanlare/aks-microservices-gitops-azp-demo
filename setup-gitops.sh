#!/bin/bash

# GitOps Setup - Better Practice Flow
set -e  # Exit on any error

echo "🚀 GitOps Setup - Step by Step"
echo "================================"

# Step 1: Update Dependencies
echo ""
echo "📦 Step 1: Updating Infrastructure Dependencies"
echo "-----------------------------------------------"
cd helm-charts/infra-chart

# Add required Helm repositories
echo "➕ Adding Helm repositories..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add jetstack https://charts.jetstack.io
helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
helm repo add argo https://argoproj.github.io/argo-helm

# Update all repositories
echo "🔄 Updating repositories..."
helm repo update

# Download/update dependencies
echo "📥 Downloading dependencies..."
helm dependency update

# Verify dependencies
echo "✅ Verifying dependencies..."
helm dependency list

cd ../..

# Step 2: Cleanup Previous Installations
echo ""
echo "🧹 Step 2: Cleaning Up Previous Installations"
echo "---------------------------------------------"
echo "🔍 Checking for leftover Argo CD CRDs..."
if kubectl get crd applications.argoproj.io 2>/dev/null; then
    echo "🗑️  Removing Argo CD CRD..."
    kubectl patch crd applications.argoproj.io -p '{"metadata":{"finalizers":[]}}' --type=merge 2>/dev/null || true
    kubectl delete crd applications.argoproj.io 2>/dev/null || true
    echo "✅ Argo CD CRD cleaned up"
else
    echo "✅ No Argo CD CRD found"
fi

echo "🔍 Checking for leftover webhook configurations..."
# Remove any ingress-nginx related webhooks that might be stuck
kubectl get validatingwebhookconfigurations -o name | grep -i nginx | xargs -r kubectl delete 2>/dev/null || true
kubectl get mutatingwebhookconfigurations -o name | grep -i nginx | xargs -r kubectl delete 2>/dev/null || true
echo "✅ Webhook configurations cleaned up"

echo "🔍 Checking for leftover Helm releases..."
helm list -n infra | grep -E "(argocd|infra)" | awk '{print $1}' | xargs -r helm uninstall -n infra 2>/dev/null || true
echo "✅ Previous Helm releases cleaned up"

# Step 3: Install Argo CD
echo ""
echo "🔧 Step 3: Installing Argo CD"
echo "------------------------------"
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm install infra argo/argo-cd \
  --namespace infra \
  --create-namespace \
  --set server.ingress.enabled=true \
  --set server.ingress.host=argocd.ecvlsolutions.com \
  --set server.ingress.annotations."cert-manager\.io/cluster-issuer"="letsencrypt-prod" \
  --set server.ingress.annotations."nginx\.ingress\.kubernetes\.io/ssl-passthrough"="true" \
  --set server.ingress.annotations."nginx\.ingress\.kubernetes\.io/backend-protocol"="HTTPS" \
  --set server.ingress.annotations."nginx\.ingress\.kubernetes\.io/force-ssl-redirect"="true" \
  --set server.ingress.ingressClassName=nginx \
  --set server.ingress.tls[0].secretName=argocd-tls \
  --set server.ingress.tls[0].hosts[0]=argocd.ecvlsolutions.com

# Step 4: Wait for Argo CD
echo ""
echo "⏳ Step 4: Waiting for Argo CD to be Ready"
echo "------------------------------------------"
kubectl wait --for=condition=available --timeout=300s deployment/infra-argocd-server -n infra
echo "✅ Argo CD is ready!"

# Step 5: Show Credentials
echo ""
echo "🔑 Step 5: Argo CD Credentials"
echo "-------------------------------"
echo "🌐 URL: https://argocd.ecvlsolutions.com"
echo "👤 Username: admin"
echo "🔐 Password:"
kubectl -n infra get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo ""

echo ""
echo "✅ Argo CD setup complete!"
echo "🌐 Access Argo CD: https://argocd.ecvlsolutions.com"
echo "🔑 Username: admin"
echo "🔐 Password: (shown above)"
echo ""
echo "📋 Next steps:"
echo "   1. Log in to Argo CD UI"
echo "   2. Add your Git repository"
echo "   3. Manually run: kubectl apply -f gitops-bootstrap.yaml"
echo "   4. Monitor deployments in Argo CD UI"
echo ""
exit 0 