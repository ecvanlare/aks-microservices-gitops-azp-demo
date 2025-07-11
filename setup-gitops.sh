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

# Step 2: Install Argo CD
echo ""
echo "🔧 Step 2: Installing Argo CD"
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

# Step 3: Wait for Argo CD
echo ""
echo "⏳ Step 3: Waiting for Argo CD to be Ready"
echo "------------------------------------------"
kubectl wait --for=condition=available --timeout=300s deployment/infra-server -n infra
echo "✅ Argo CD is ready!"

# Step 4: Show Credentials
echo ""
echo "🔑 Step 4: Argo CD Credentials"
echo "-------------------------------"
echo "🌐 URL: https://argocd.ecvlsolutions.com"
echo "👤 Username: admin"
echo "🔐 Password:"
kubectl -n infra get secret infra-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo ""

# Step 5: Deploy Infrastructure
echo ""
echo "🏗️  Step 5: Deploying Infrastructure via GitOps"
echo "-----------------------------------------------"
echo "Applying bootstrap application..."
kubectl apply -f gitops-bootstrap.yaml

# Step 6: Monitor Infrastructure Deployment
echo ""
echo "📊 Step 6: Monitoring Infrastructure Deployment"
echo "---------------------------------------------"
echo "Waiting for infrastructure to deploy..."
sleep 10

echo ""
echo "🔍 Checking application status:"
kubectl get applications -n infra

echo ""
echo "📋 Components being deployed:"
echo "   Infrastructure:"
echo "     - cert-manager (SSL certificates)"
echo "     - ingress-nginx (Traffic routing)"
echo "     - external-dns (DNS management)"
echo "     - cluster-issuer (SSL authority)"
echo "   Applications:"
echo "     - online-boutique (Microservices)"

echo ""
echo "✅ GitOps setup complete!"
echo "🌐 Access Argo CD: https://argocd.ecvlsolutions.com"
echo "📖 Monitor deployments in Argo CD UI" 