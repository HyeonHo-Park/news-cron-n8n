#!/bin/bash

echo "🧹 n8n kind 클러스터 정리 중..."

# n8n 리소스 삭제
kubectl delete namespace n8n --ignore-not-found=true

echo "✅ n8n 네임스페이스가 삭제되었습니다."

read -p "🗑️  kind 클러스터도 완전히 삭제하시겠습니까? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    kind delete cluster --name n8n-cluster
    echo "✅ kind 클러스터가 삭제되었습니다."
else
    echo "💡 클러스터는 유지되었습니다. 다시 배포하려면 ./deploy-kind.sh를 실행하세요."
fi 