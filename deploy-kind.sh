#!/bin/bash

echo "🐳 kind 클러스터에 n8n 배포 중..."

# kind 클러스터가 있는지 확인
if ! kind get clusters | grep -q "n8n-cluster"; then
    echo "📦 kind 클러스터 생성 중..."
    kind create cluster --config=config.yaml
else
    echo "✅ 기존 kind 클러스터 사용"
fi

# kubectl 컨텍스트 설정
kubectl cluster-info --context kind-n8n-cluster

echo "🚀 n8n 매니페스트 적용 중..."

# 네임스페이스 생성
kubectl apply -f manifests/namespace.yaml

# ConfigMap과 Secret 적용
kubectl apply -f manifests/configmap.yaml
kubectl apply -f manifests/secret.yaml

# PVC 생성
kubectl apply -f manifests/storageclass.yaml
kubectl apply -f manifests/data-volume.yaml
kubectl apply -f manifests/output-volume.yaml

# Deployment와 Service 생성
kubectl apply -f manifests/deployment.yaml
kubectl apply -f manifests/service.yaml

echo "⏳ n8n Pod가 준비될 때까지 대기 중..."
kubectl wait --for=condition=Ready pod -l app=n8n -n n8n --timeout=300s

echo "✅ n8n이 성공적으로 배포되었습니다!"
echo ""
echo "📱 웹 인터페이스: http://localhost:5678"
echo ""
echo "📊 유용한 명령어:"
echo "   kubectl get pods -n n8n"
echo "   kubectl logs -f deployment/n8n -n n8n"
echo "   kubectl port-forward svc/n8n-service 5678:5678 -n n8n"
echo ""
echo "🛑 삭제: ./cleanup-kind.sh" 