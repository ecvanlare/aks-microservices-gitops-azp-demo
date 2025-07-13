#!/bin/bash

# Simple ArgoCD Installation Script
# This script installs ArgoCD in your Kubernetes cluster

set -e

echo "🚀 Installing ArgoCD..."
echo "========================"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl not found. Please install kubectl first."
    exit 1
fi

# Check cluster connection
if ! kubectl cluster-info &> /dev/null; then
    print_error "Cannot connect to Kubernetes cluster. Please check your kubeconfig."
    exit 1
fi

print_status "Connected to Kubernetes cluster"

# Check if ArgoCD namespace already exists
if kubectl get namespace argocd &> /dev/null; then
    print_warning "ArgoCD namespace already exists. Checking if ArgoCD is installed..."
    
    ARGOCD_PODS=$(kubectl get pods -n argocd --no-headers 2>/dev/null | wc -l)
    if [ "$ARGOCD_PODS" -gt 0 ]; then
        print_status "ArgoCD is already installed with $ARGOCD_PODS pods"
        echo "Skipping installation."
        exit 0
    else
        print_warning "ArgoCD namespace exists but no pods found. Reinstalling..."
        kubectl delete namespace argocd --ignore-not-found=true
        sleep 5
    fi
fi

# Install ArgoCD
echo ""
echo "Installing ArgoCD..."

# Create namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

print_status "ArgoCD installation started"

# Wait for ArgoCD to be ready
echo ""
echo "Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=Available deployment/argocd-server -n argocd --timeout=300s
kubectl wait --for=condition=Available deployment/argocd-repo-server -n argocd --timeout=300s
kubectl wait --for=condition=Ready statefulset/argocd-application-controller -n argocd --timeout=300s

print_status "ArgoCD is ready!"

# Get admin password
echo ""
echo "Getting ArgoCD admin password..."
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

if [ ! -z "$ARGOCD_PASSWORD" ]; then
    print_status "ArgoCD admin password: $ARGOCD_PASSWORD"
    echo ""
    echo "🔐 ArgoCD Login Information:"
    echo "   Username: admin"
    echo "   Password: $ARGOCD_PASSWORD"
    echo ""
    echo "🌐 To access ArgoCD UI:"
    echo "   kubectl port-forward svc/argocd-server -n argocd 8080:443"
    echo "   Then visit: https://localhost:8080"
    echo ""
    echo "📝 To login via CLI:"
    echo "   argocd login localhost:8080 --username admin --password '$ARGOCD_PASSWORD' --insecure"
else
    print_error "Could not retrieve ArgoCD admin password"
    exit 1
fi

print_status "ArgoCD installation completed successfully!"
echo ""
echo "Next steps:"
echo "1. Run: ./scripts/test-argocd-local.sh"
echo "2. Create your root app in ArgoCD"
echo "3. Test the pipeline" 