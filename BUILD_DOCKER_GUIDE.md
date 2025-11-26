# OpenList Docker 本地构建和推送指南

本指南说明如何在本地构建修改后的 OpenList Docker 镜像并推送到 GitHub Container Registry (ghcr.io)。

## 前置要求

1. **Docker** - 已安装并运行
2. **Go 1.25.0+** - 用于构建二进制文件
3. **GitHub Personal Access Token** - 需要 `write:packages` 权限
   - 创建地址: https://github.com/settings/tokens
   - 需要勾选 `write:packages` 和 `read:packages` 权限

## 快速开始


### 方法一: 使用自动化脚本 (推荐)

```bash
# 1. 设置环境变量
export GHCR_USERNAME="your-github-username"
export VERSION="v1.0.0-custom"  # 可选,默认使用时间戳

# 2. 赋予执行权限
chmod +x build-and-push-docker.sh

# 3. 运行脚本
./build-and-push-docker.sh
```

### 方法二: 手动执行步骤

```bash
# 1. 下载前端资源
bash build.sh dev web

# 2. 构建 Docker 二进制文件
bash build.sh dev docker

# 3. 构建 Docker 镜像
docker build \
  --platform linux/amd64 \
  -t ghcr.io/your-username/openlist:latest \
  -f Dockerfile \
  .

# 4. 登录到 ghcr.io
echo "YOUR_GITHUB_TOKEN" | docker login ghcr.io -u your-username --password-stdin

# 5. 推送镜像
docker push ghcr.io/your-username/openlist:latest
```

## 多平台构建 (可选)

如果需要构建多平台镜像 (amd64, arm64 等):

```bash
# 1. 创建 buildx builder
docker buildx create --name multiplatform --use

# 2. 构建并推送多平台镜像
docker buildx build \
  --platform linux/amd64,linux/arm64,linux/arm/v7 \
  -t ghcr.io/your-username/openlist:latest \
  --push \
  -f Dockerfile \
  .
```

## 使用构建的镜像

```bash
# 拉取镜像
docker pull ghcr.io/your-username/openlist:latest

# 运行容器
docker run -d \
  --name openlist \
  -p 5244:5244 \
  -v /path/to/data:/opt/openlist/data \
  ghcr.io/your-username/openlist:latest
```

## 使用 docker-compose

修改 `docker-compose.yml` 中的镜像地址:

```yaml
services:
  openlist:
    image: 'ghcr.io/your-username/openlist:latest'
    # ... 其他配置保持不变
```

然后运行:

```bash
docker-compose up -d
```

## 验证修改

构建完成后,可以验证挂载限制是否已移除:

```bash
# 1. 运行容器
docker run -it --rm ghcr.io/your-username/openlist:latest /bin/sh

# 2. 检查版本信息
./openlist version

# 3. 测试挂载功能
# 启动服务并尝试添加 OpenList 存储驱动
```

## 故障排除

### 构建失败

如果构建过程中出现错误:

```bash
# 清理 Docker 缓存
docker builder prune -a

# 重新构建
./build-and-push-docker.sh
```

### 推送权限错误

确保您的 GitHub Token 具有正确的权限:
- `write:packages` - 推送镜像
- `read:packages` - 拉取镜像
- `delete:packages` - 删除镜像 (可选)

### 镜像大小过大

使用多阶段构建已经优化了镜像大小。如果需要进一步优化:

```bash
# 使用 lite 版本前端
bash build.sh dev lite web
bash build.sh dev docker
```

## 注意事项

1. **代码修改**: 本次构建包含了移除 OpenList 驱动挂载限制的修改
2. **版本管理**: 建议使用有意义的版本标签,如 `v1.0.0-no-mount-limit`
3. **安全性**: 不要在公共仓库中分享包含敏感信息的镜像
4. **更新**: 定期同步上游代码以获取最新功能和安全修复

## 相关链接

- [OpenList 官方文档](https://openlist.team)
- [GitHub Container Registry 文档](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [Docker 多平台构建](https://docs.docker.com/build/building/multi-platform/)