# 下载 Docker Compose 并安装
if curl -sL "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose; then
    sudo chmod +x /usr/local/bin/docker-compose
    echo "Docker Compose 安装成功"
else
    echo "Docker Compose 下载失败"
    exit 1
fi

# 验证 Docker Compose 安装版本
VERSION=$(docker-compose --version)
echo "已安装 Docker Compose 版本: $VERSION"
