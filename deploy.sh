#!/bin/bash

# deploy.sh - Script to deploy Kubernetes manifests and run DB migrations

set -e

# Default namespace
NAMESPACE=${1:-todo}

echo "🚀 Deploying Kubernetes resources to namespace '$NAMESPACE'..."

# Create namespace if it doesn't exist
kubectl get ns $NAMESPACE >/dev/null 2>&1 || kubectl create ns $NAMESPACE

# Apply PVCs
kubectl apply -f k8s/pg-app-pvc.yml -n $NAMESPACE
kubectl apply -f k8s/node-app-pvc.yml -n $NAMESPACE

# Apply Services
kubectl apply -f k8s/pg-app-svc.yml -n $NAMESPACE
kubectl apply -f k8s/node-app-svc.yml -n $NAMESPACE

# Apply PostgreSQL pod
kubectl apply -f k8s/pg-app-pod.yml -n $NAMESPACE

echo "⏳ Waiting for PostgreSQL to become ready..."
kubectl wait --for=condition=Ready pod/postgres -n $NAMESPACE --timeout=90s

# Apply Node.js pod
kubectl apply -f k8s/node-app-pod.yml -n $NAMESPACE

echo "⏳ Waiting for node-app to become ready..."
kubectl wait --for=condition=Ready pod/node-app -n $NAMESPACE --timeout=90s

echo "🧬 Running database migrations..."
kubectl exec -n $NAMESPACE node-app -- npm run migrate:up

echo "✅ Deployment and migrations completed."
