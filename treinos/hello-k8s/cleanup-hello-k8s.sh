#!/bin/bash

echo "🛑 Limpando recursos do Kubernetes..."
kubectl delete -f service.yaml --ignore-not-found
kubectl delete -f deployment.yaml --ignore-not-found

echo "🧹 Removendo imagem local do Docker..."
docker rmi seu_usuario_docker/hello-k8s:v1 --force

echo "✅ Limpeza concluída!"

