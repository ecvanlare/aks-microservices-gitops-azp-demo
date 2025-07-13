#!/bin/bash

# Test ArgoCD CLI Setup Locally
# This script helps verify ArgoCD CLI installation and connection

set -e

echo "🔧 ArgoCD CLI Local Test Script"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
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
echo "1. Checking kubectl..."
if command -v kubectl &> /dev/null; then
    print_status "kubectl is available"
    kubectl version --client
else
    print_error "kubectl not found. Please install kubectl first."
    exit 1
fi

# Check if ArgoCD CLI is available
echo ""
echo "2. Checking ArgoCD CLI..."
if command -v argocd &> /dev/null; then
    print_status "ArgoCD CLI is available"
    argocd version --client
else
    print_warning "ArgoCD CLI not found. Installing..."
    
    # Detect OS and architecture
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    ARCH=$(uname -m)
    
    if [ "$ARCH" = "x86_64" ]; then
        ARCH="amd64"
    elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
        ARCH="arm64"
    fi
    
    # Download and install ArgoCD CLI
    ARGOCD_VERSION=$(curl -s https://api.github.com/repos/argoproj/argo-cd/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
    echo "Downloading ArgoCD CLI version: $ARGOCD_VERSION"
    
    curl -sSL -o argocd-$OS-$ARCH "https://github.com/argoproj/argo-cd/releases/download/$ARGOCD_VERSION/argocd-$OS-$ARCH"
    chmod +x argocd-$OS-$ARCH
    
    # Install to local bin or system bin
    if [ -w /usr/local/bin ]; then
        sudo mv argocd-$OS-$ARCH /usr/local/bin/argocd
    else
        mkdir -p ~/.local/bin
        mv argocd-$OS-$ARCH ~/.local/bin/argocd
        export PATH="$HOME/.local/bin:$PATH"
        echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> ~/.bashrc
    fi
    
    print_status "ArgoCD CLI installed successfully"
    argocd version --client
fi

# Check cluster connection
echo ""
echo "3. Checking cluster connection..."
if kubectl cluster-info &> /dev/null; then
    print_status "Connected to Kubernetes cluster"
    kubectl cluster-info | head -1
else
    print_error "Cannot connect to Kubernetes cluster. Please check your kubeconfig."
    exit 1
fi

# Check if ArgoCD namespace exists
echo ""
echo "4. Checking ArgoCD installation..."
if kubectl get namespace argocd &> /dev/null; then
    print_status "ArgoCD namespace exists"
    
    # Check ArgoCD pods
    ARGOCD_PODS=$(kubectl get pods -n argocd --no-headers | wc -l)
    if [ "$ARGOCD_PODS" -gt 0 ]; then
        print_status "ArgoCD pods found: $ARGOCD_PODS"
        kubectl get pods -n argocd --no-headers | head -3
    else
        print_warning "No ArgoCD pods found. ArgoCD might not be fully installed."
    fi
else
    print_warning "ArgoCD namespace not found. ArgoCD is not installed in this cluster."
    echo "To install ArgoCD, run:"
    echo "  kubectl create namespace argocd"
    echo "  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
    exit 1
fi

# Test ArgoCD connection
echo ""
echo "5. Testing ArgoCD connection..."
ARGOCD_SERVER="argocd-server.argocd.svc.cluster.local"

# Try to get ArgoCD admin password
if kubectl get secret argocd-initial-admin-secret -n argocd &> /dev/null; then
    print_status "ArgoCD admin secret found"
    
    # Get password
    ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
    
    if [ ! -z "$ARGOCD_PASSWORD" ]; then
        print_status "Retrieved ArgoCD admin password"
        
        # Try to login
        echo "Attempting to login to ArgoCD..."
        if argocd login $ARGOCD_SERVER --username admin --password "$ARGOCD_PASSWORD" --insecure --grpc-web; then
            print_status "Successfully logged in to ArgoCD"
            
            # List applications
            echo ""
            echo "6. Testing ArgoCD operations..."
            echo "Applications in ArgoCD:"
            argocd app list
            
            print_status "ArgoCD CLI test completed successfully!"
            
        else
            print_warning "Direct connection failed, trying port-forward..."
            
            # Try port-forward method
            kubectl port-forward svc/argocd-server -n argocd 8080:443 &
            PF_PID=$!
            sleep 5
            
            if argocd login localhost:8080 --username admin --password "$ARGOCD_PASSWORD" --insecure; then
                print_status "Successfully logged in via port-forward"
                
                echo ""
                echo "6. Testing ArgoCD operations..."
                echo "Applications in ArgoCD:"
                argocd app list
                
                print_status "ArgoCD CLI test completed successfully!"
                
                # Cleanup
                kill $PF_PID 2>/dev/null || true
            else
                print_error "Failed to login to ArgoCD"
                kill $PF_PID 2>/dev/null || true
                exit 1
            fi
        fi
    else
        print_error "Could not retrieve ArgoCD admin password"
        exit 1
    fi
else
    print_warning "ArgoCD admin secret not found. ArgoCD might not be fully initialized."
    echo "Wait a few minutes for ArgoCD to initialize, then run this script again."
    exit 1
fi

echo ""
echo "🎉 All tests passed! ArgoCD CLI is working correctly."
echo ""
echo "Next steps:"
echo "1. Create your root app in ArgoCD"
echo "2. Test the pipeline with this verified setup" 