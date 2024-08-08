#!/bin/bash

set -e  # 确保脚本在遇到错误时停止执行

DEFAULT_PORT=60001  # 默认端口号

# 显示帮助信息
function show_help() {
    echo "用法: $0 [选项]"
    echo
    echo "选项:"
    echo "  -h, --help         显示此帮助信息"
}

# 解析命令行选项
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help) show_help; exit 0 ;;
        *) echo "未知选项: $1"; show_help; exit 1 ;;
    esac
    shift
done

# 检查 Docker 是否已安装
if ! command -v docker &> /dev/null; then
    echo "错误: Docker 未安装。请先安装 Docker。"
    echo "可以使用以下命令安装 Docker："
    echo "  wget -qO- https://get.docker.com | sudo bash"
    exit 1
fi

# 检查 Docker Compose 是否已安装
if ! command -v docker-compose &> /dev/null; then
    echo "错误: Docker Compose 未安装。请先安装 Docker Compose。"
    echo "可以使用以下命令安装 Docker Compose："
    echo "  sudo curl -L \"https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose"
    echo "  sudo chmod +x /usr/local/bin/docker-compose"
    exit 1
fi

# 创建 Lsky Pro 数据目录
echo "创建 Lsky Pro 数据目录..."
sudo mkdir -p /root/data/docker_data/lsky-pro

# 进入数据目录
cd /root/data/docker_data/lsky-pro

# 询问用户输入端口号
read -p "请输入 Lsky Pro 管理界面端口（默认为 ${DEFAULT_PORT}）： " PORT

# 使用默认端口，如果用户没有输入
PORT=${PORT:-$DEFAULT_PORT}

# 确保用户输入的是有效的端口号
if ! [[ "$PORT" =~ ^[0-9]+$ ]] || [ "$PORT" -lt 1 ] || [ "$PORT" -gt 65535 ]; then
    echo "错误: 无效的端口号。请提供一个介于 1 到 65535 之间的端口号。"
    exit 1
fi

# 创建 docker-compose.yml 文件
echo "创建 docker-compose.yml 文件..."
cat > docker-compose.yml <<EOF
services:
  lskypro:
    image: halcyonazure/lsky-pro-docker:latest
    restart: unless-stopped
    hostname: lskypro
    container_name: lskypro
    environment:
      - WEB_PORT=8089
    volumes:
      - $PWD/web:/var/www/html/
    ports:
      - "9080:8089"
    networks:
      - lsky-net

  # 注：arm64的无法使用该镜像，请选择sqlite或自建数据库
  mysql-lsky:
    image: mysql:5.7.22
    restart: unless-stopped
    # 主机名，可作为"数据库连接地址"
    hostname: mysql-lsky
    # 容器名称
    container_name: mysql-lsky
    # 修改加密规则
    command: --default-authentication-plugin=mysql_native_password
    volumes:
      - $PWD/mysql/data:/var/lib/mysql
      - $PWD/mysql/conf:/etc/mysql
      - $PWD/mysql/log:/var/log/mysql
    environment:
      MYSQL_ROOT_PASSWORD: lAsWjb6rzSzENUYg # 数据库root用户密码，自行修改
      MYSQL_DATABASE: lsky-data # 可作为"数据库名称/路径"
    networks:
      - lsky-net

networks:
  lsky-net: {}
EOF

# 启动 Lsky Pro 和 MySQL 服务
echo "启动 Lsky Pro 和 MySQL 服务..."
if ! sudo docker-compose up -d; then
    echo "错误: 启动服务失败。"
    exit 1
fi

# 检查 Docker Compose 状态
echo "检查 Docker Compose 状态..."
if ! sudo docker-compose ps; then
    echo "错误: 检查服务状态失败。"
    exit 1
fi

echo "Lsky Pro 和 MySQL 服务已成功启动。"
