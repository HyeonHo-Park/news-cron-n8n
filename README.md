# n8n on KIND (Kubernetes in Docker)

kind 클러스터에서 n8n을 실행하기 위한 Kubernetes 매니페스트와 스크립트입니다.

## 🚀 Pre-Install
```shell
# 1. Docker 설치 확인
docker --version

# 2. kind 설치
# macOS
brew install kind
# 또는 직접 다운로드
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-darwin-arm64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# 3. kubectl 설치
# macOS
brew install kubectl
# 또는 직접 다운로드
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/arm64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

# 4. 필수 디렉토리 생성
mkdir -p data output

# 5. 실행 권한 부여
chmod +x deploy-kind.sh cleanup-kind.sh
```

## 1. Docker Run

```shell
export DOCKER_HOST=unix://$HOME/.colima/default/docker.sock
# n8n 데이터 영구 보존을 위한 호스트 디렉토리 마운트
colima start \
--runtime docker \
--arch aarch64 \
--cpu 4 --memory 8 \
--mount ${HOME}/notebooklm/n8n/data:w \
--mount ${HOME}/notebooklm/n8n/output:w
```

## 2. kind 클러스터 및 n8n 배포

### 📋 주요 명령어

| 스크립트 | 설명 |
|----------|------|
| `./deploy-kind.sh` | kind 클러스터 생성 및 n8n 배포 |
| `./cleanup-kind.sh` | n8n 삭제 (클러스터 삭제 옵션) |

## 3. 웹 인터페이스 접속
브라우저에서 http://localhost:5678 으로 접속

## 4. Volume 마운트 관련 디버깅
```bash
# Colima 상세 정보 확인
colima status --verbose

# 또는 Colima 설정 확인
cat ~/.colima/default/colima.yaml | grep -A 10 mounts

# docker로 워커노드 접속
docker exec -it n8n-cluster-worker sh
# cd ./data
# ls
# ls -al
total 8
drwxr-xr-x 1  501 dialout   64 Aug 24 13:07 .
drwxr-xr-x 4 root root    4096 Aug 24 13:42 ..
# echo "test" > test.txt
# ls
test.txt

# 다른 쉘에서 pod로 접속
# k exec -it n8n-6d6c45b9f7-h8xdb -- sh
/home/node/.n8n # ls -al
total 12
drwxr-xr-x    1 501      dialout         96 Aug 24 13:47 .
drwxr-sr-x    1 node     node          4096 Aug 24 13:43 ..
-rw-r--r--    1 501      dialout          5 Aug 24 13:47 test.txt
/home/node/.n8n # echo "test2" > test2.txt
/home/node/.n8n # ls
test.txt   test2.txt

# docker 워커노드 커맨드에서도 체크
# ls -al
total 12
drwxr-xr-x 1  501 dialout   96 Aug 24 13:47 .
drwxr-xr-x 4 root root    4096 Aug 24 13:42 ..
-rw-r--r-- 1  501 dialout    5 Aug 24 13:47 test.txt
# ls
test.txt  test2.txt

# 로컬 마운트 경로에서도 확인
> ls -al
total 16
drwxr-xr-x@ 4 hyeonho  staff  128 Aug 24 22:47 .
drwxr-xr-x@ 9 hyeonho  staff  288 Aug 24 22:07 ..
-rw-r--r--@ 1 hyeonho  staff    5 Aug 24 22:47 test.txt
-rw-r--r--@ 1 hyeonho  staff    6 Aug 24 22:47 test2.txt
```

## 5. 주요 SQLite 명령어

```sql
-- 테이블 목록 보기
.tables

-- 테이블 구조 보기
.schema workflow_entity

-- 워크플로우 데이터 조회
SELECT id, name, active, createdAt FROM workflow_entity;

-- 실행 기록 조회
SELECT id, workflowId, mode, startedAt, stoppedAt FROM execution_entity LIMIT 10;

-- 사용자 정보 조회
SELECT id, email, firstName, lastName FROM user LIMIT 10;

-- 자격증명 조회
SELECT id, name, type FROM credentials_entity;
```