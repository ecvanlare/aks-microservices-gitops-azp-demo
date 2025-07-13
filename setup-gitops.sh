#!/bin/bash

# GitOps Setup - Argo CD Only (No Ingress)
set -e  # Exit on any error

echo "🚀 GitOps Setup - Argo CD Installation (Port-Forward Access)"
echo "============================================================"

# Step 1: Add All Required Helm Repositories
echo ""
echo "📦 Step 1: Adding Helm Repositories"
echo "-----------------------------------"
echo "➕ Adding Helm repositories..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add jetstack https://charts.jetstack.io
helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
helm repo add argo https://argoproj.github.io/argo-helm

# Update all repositories
echo "🔄 Updating repositories..."
helm repo update

# Step 2: Cleanup Previous Installations
echo ""
echo "🧹 Step 2: Cleaning Up Previous Installations"
echo "---------------------------------------------"

# Clean up Argo CD CRDs
echo "🔍 Cleaning up Argo CD CRDs..."
kubectl patch crd applications.argoproj.io -p '{"metadata":{"finalizers":[]}}' --type=merge 2>/dev/null || true
kubectl delete crd applications.argoproj.io 2>/dev/null || true
kubectl patch crd applicationsets.argoproj.io -p '{"metadata":{"finalizers":[]}}' --type=merge 2>/dev/null || true
kubectl delete crd applicationsets.argoproj.io 2>/dev/null || true
kubectl patch crd appprojects.argoproj.io -p '{"metadata":{"finalizers":[]}}' --type=merge 2>/dev/null || true
kubectl delete crd appprojects.argoproj.io 2>/dev/null || true
echo "✅ Argo CD CRDs cleaned up"

# Clean up Helm releases
echo "🔍 Cleaning up Helm releases..."
helm uninstall infra -n infra 2>/dev/null || true
echo "✅ Helm releases cleaned up"

# Clean up stuck resources in infra namespace
echo "🔍 Cleaning up stuck resources..."
kubectl delete all --all -n infra --grace-period=0 --force 2>/dev/null || true
kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get -n infra --ignore-not-found -o name | xargs -r -n 1 kubectl delete -n infra --grace-period=0 --force 2>/dev/null || true
echo "✅ Stuck resources cleaned up"

# Skip namespace cleanup if stuck
echo "🔍 Checking namespace status..."
if kubectl get namespace infra 2>/dev/null | grep -q "Terminating"; then
    echo "⚠️  Namespace is stuck, skipping cleanup and proceeding..."
else
    echo "🔍 Cleaning up namespace..."
    kubectl delete namespace infra --ignore-not-found=true
    echo "✅ Namespace cleanup completed"
fi

# Step 3: Install Argo CD (No Ingress)
echo ""
echo "🔧 Step 3: Installing Argo CD (Port-Forward Access)"
echo "---------------------------------------------------"
helm install infra argo/argo-cd \
  --namespace infra \
  --create-namespace \
  --set server.ingress.enabled=false \
  --set server.extraArgs="{--insecure}" \
  --wait \
  --timeout=15m

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
echo "🌐 Access Argo CD:"
echo "   kubectl port-forward svc/infra-argocd-server -n infra 9090:80"
echo "   Then visit: http://localhost:9090"
echo "👤 Username: admin"
echo "🔐 Password:"
kubectl -n infra get secret infra-argo-cd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo ""

echo ""
echo "✅ Argo CD setup complete!"
echo ""
echo "📋 Next steps:"
echo "   1. Log in to Argo CD UI"
echo "   2. Add your Git repository"
echo "   3. Manually run: kubectl apply -f gitops-bootstrap.yaml"
echo "   4. Monitor deployments in Argo CD UI"
echo ""
echo "💡 Note: Using port-forward access. Ingress will be configured later via GitOps."
echo ""
exit 0 