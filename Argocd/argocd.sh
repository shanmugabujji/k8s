#!/bin/bash
set -e

echo "===== Creating argocd namespace ====="
kubectl create namespace argocd || echo "Namespace already exists"

echo "===== Installing Argo CD ====="
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "===== Waiting for Argo CD pods to be ready ====="
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

echo "===== Exposing Argo CD as NodePort ====="
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'

echo "===== Downloading Argo CD CLI ====="
wget -q https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64 -O argocd

echo "===== Installing Argo CD CLI ====="
chmod +x argocd
mv argocd /usr/local/bin/

echo "===== Verifying Argo CD CLI ====="
argocd version --client

echo "===== Argo CD installation completed successfully! ====="

echo "To get the admin password, run:"
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d && echo

echo "To get NodePort:"
echo "kubectl get svc argocd-server -n argocd"

ARGOCD COMMANDS
List Applications
argocd app list



kubectl rollout restart deployment coredns -n kube-system
kubectl rollout restart deployment argocd-repo-server -n argocd
kubectl rollout restart deployment argocd-server -n argocd
