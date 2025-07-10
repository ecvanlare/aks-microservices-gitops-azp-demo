#!/bin/bash

# Infrastructure Installation Script
# This script installs all infrastructure components including ArgoCD

set -e

echo "🚀 Installing Infrastructure Components..."

# Add required Helm repositories
echo "📦 Adding Helm repositories..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add jetstack https://charts.jetstack.io
helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Install infrastructure components
echo "🔧 Installing Infrastructure Components..."
helm dependency update
helm upgrade --install infra . --namespace infra --create-namespace --wait --timeout=15m

# Wait for ArgoCD to be ready
echo "⏳ Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argo-cd-server -n infra --timeout=300s

# Get initial admin password
echo "🔑 Getting ArgoCD admin password..."
ARGOCD_PASSWORD=$(kubectl -n infra get secret infra-argo-cd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "ArgoCD admin password: $ARGOCD_PASSWORD"

# Apply ArgoCD Application
echo "📋 Applying ArgoCD Application..."
kubectl apply -f argocd/application.yaml

echo "✅ Infrastructure installation complete!"
echo ""
echo "🌐 Access ArgoCD UI:"
echo "   kubectl port-forward svc/infra-argo-cd-server -n infra 9090:80"
echo "   Then visit: http://localhost:9090"
echo "   Username: admin"
echo "   Password: $ARGOCD_PASSWORD"
echo ""
echo "🔍 Check application status:"
echo "   kubectl get applications -n infra"
echo "   kubectl get pods -n online-boutique"
echo ""
echo "🌐 Access Application:"
echo "   https://ecvlsolutions.com" 