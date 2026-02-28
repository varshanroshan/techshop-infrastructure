#!/bin/bash
set -e

echo "========================================="
echo " Setting up Observability Stack (Phase 4)"
echo "========================================="

# Create monitoring namespace
kubectl create namespace monitoring || true

# Add Helm Repositories
echo "Adding Helm repositories..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install Prometheus & Grafana Stack
echo "Installing Kube-Prometheus-Stack..."
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring

# Install Loki Stack for centralized logging
echo "Installing Loki-Stack..."
helm upgrade --install loki grafana/loki-stack \
  --namespace monitoring \
  --set grafana.enabled=false \
  --set prometheus.enabled=false \
  --set prometheus.alertmanager.persistentVolume.enabled=false \
  --set server.persistentVolume.enabled=false

echo "========================================="
echo "Observability Stack successfully deployed!"
echo "To access Grafana, run:"
echo "kubectl port-forward svc/prometheus-grafana 8080:80 -n monitoring"
echo "Credentials: admin / prom-operator (default)"
echo "========================================="
