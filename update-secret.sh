#!/bin/bash

echo "🔐 n8n Secret 업데이트"
echo ""

# 사용자로부터 새로운 값들 입력받기
read -p "새로운 암호화 키를 입력하세요: " encryption_key
read -p "새로운 사용자명을 입력하세요: " username
read -s -p "새로운 비밀번호를 입력하세요: " password
echo ""

# Base64 인코딩
encoded_key=$(echo -n "$encryption_key" | base64)
encoded_user=$(echo -n "$username" | base64)
encoded_pass=$(echo -n "$password" | base64)

# Secret 업데이트
kubectl patch secret n8n-secret -n n8n --type='merge' -p="{
  \"data\": {
    \"N8N_ENCRYPTION_KEY\": \"$encoded_key\",
    \"N8N_BASIC_AUTH_USER\": \"$encoded_user\",
    \"N8N_BASIC_AUTH_PASSWORD\": \"$encoded_pass\"
  }
}"

echo "✅ Secret이 업데이트되었습니다."
echo "🔄 변경사항을 적용하려면 Pod를 재시작하세요:"
echo "   kubectl rollout restart deployment/n8n -n n8n" 