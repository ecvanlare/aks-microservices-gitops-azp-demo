#!/bin/bash

# Cleanup script to delete all namespaces
# Usage: ./scripts/cleanup-namespaces.sh

set -e

echo "🧹 Starting namespace cleanup..."

# Array of namespaces to delete
NAMESPACES=(
    "online-boutique"
    "cert-manager"
    "ingress-nginx"
    "external-dns"
    "argocd"
    "monitoring"
)

# Delete each namespace
for namespace in "${NAMESPACES[@]}"; do
    echo "🗑️  Deleting namespace: $namespace"
    
    # Check if namespace exists
    if kubectl get namespace "$namespace" >/dev/null 2>&1; then
        echo "   Found namespace $namespace, deleting..."
        kubectl delete namespace "$namespace" --wait=true --timeout=300s
        echo "   ✅ Namespace $namespace deleted successfully"
    else
        echo "   ⚠️  Namespace $namespace does not exist, skipping..."
    fi
done

echo ""
echo "🎉 Namespace cleanup completed!"
echo ""
echo "📋 Summary of deleted namespaces:"
for namespace in "${NAMESPACES[@]}"; do
    if ! kubectl get namespace "$namespace" >/dev/null 2>&1; then
        echo "   ✅ $namespace - Deleted"
    else
        echo "   ❌ $namespace - Still exists (may be stuck in terminating)"
    fi
done

echo ""
echo "💡 Note: If any namespaces are stuck in 'Terminating' state, you may need to:"
echo "   1. Check for finalizers: kubectl get namespace <namespace> -o yaml"
echo "   2. Remove finalizers manually if needed"
echo "   3. Force delete: kubectl delete namespace <namespace> --force --grace-period=0" 