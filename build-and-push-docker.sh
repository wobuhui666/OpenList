#!/bin/bash
set -e

# 配置
GHCR_REGISTRY="ghcr.io"
GHCR_USERNAME="${GHCR_USERNAME:-your-github-username}"
IMAGE_NAME="openlist"
VERSION="${VERSION:-custom-$(date +%Y%m%d-%H%M%S)}"

echo "=========================================="
echo "OpenList Docker 本地构建和推送脚本"
echo "=========================================="
echo "镜像名称: ${GHCR_REGISTRY}/${GHCR_USERNAME}/${IMAGE_NAME}"
echo "版本标签: ${VERSION}"
echo "=========================================="

# 步骤1: 构建前端资源
echo ""
echo "[1/5] 下载前端资源..."
bash build.sh dev web

# 步骤2: 构建Go二进制文件
echo ""
echo "[2/5] 构建Docker二进制文件..."
bash build.sh dev docker

# 步骤3: 构建Docker镜像
echo ""
echo "[3/5] 构建Docker镜像..."
docker build \
  --platform linux/amd64 \
  -t ${GHCR_REGISTRY}/${GHCR_USERNAME}/${IMAGE_NAME}:${VERSION} \
  -t ${GHCR_REGISTRY}/${GHCR_USERNAME}/${IMAGE_NAME}:latest \
  -f Dockerfile \
  .

# 步骤4: 登录到ghcr.io
echo ""
echo "[4/5] 登录到 GitHub Container Registry..."
echo "请输入您的GitHub Personal Access Token (需要 write:packages 权限):"
docker login ${GHCR_REGISTRY} -u ${GHCR_USERNAME}

# 步骤5: 推送镜像
echo ""
echo "[5/5] 推送镜像到 ghcr.io..."
docker push ${GHCR_REGISTRY}/${GHCR_USERNAME}/${IMAGE_NAME}:${VERSION}
docker push ${GHCR_REGISTRY}/${GHCR_USERNAME}/${IMAGE_NAME}:latest

echo ""
echo "=========================================="
echo "✅ 构建和推送完成!"
echo "=========================================="
echo "镜像地址:"
echo "  ${GHCR_REGISTRY}/${GHCR_USERNAME}/${IMAGE_NAME}:${VERSION}"
echo "  ${GHCR_REGISTRY}/${GHCR_USERNAME}/${IMAGE_NAME}:latest"
echo ""
echo "使用方法:"
echo "  docker pull ${GHCR_REGISTRY}/${GHCR_USERNAME}/${IMAGE_NAME}:latest"
echo "=========================================="