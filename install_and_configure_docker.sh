#!/bin/bash

set -e  # 确保脚本在遇到错误时停止执行

LOG_FILE="/var/log/install_and_configure_docker.log"

# 创建日志文件并记录开始时间
echo "脚本开始执行于 $(date)" | sudo tee -a "$LOG_FILE"

# 显示帮助信息
function show_help() {
    echo "用法: $0 [选项]"
    echo
    echo "选项:"
    echo "  -h, --help         显示此帮助信息"
    echo
    echo "示例:"
    echo "  $0"
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
if command -v docker &> /dev/null; then
    echo "Docker 已安装。" | sudo tee -a "$LOG_FILE"
else
    # 下载并安装 Docker
    echo "下载并安装 Docker..." | sudo tee -a "$LOG_FILE"
    wget -qO- https://get.docker.com | sudo bash

    # 验证 Docker 安装
    if docker -v &> /dev/null; then
        echo "Docker 安装成功：$(docker -v)" | sudo tee -a "$LOG_FILE"
    else
        echo "Docker 安装失败。" | sudo tee -a "$LOG_FILE"
        exit 1
    fi
fi

# 设置 Docker 开机自动启动
echo "设置 Docker 开机自动启动..." | sudo tee -a "$LOG_FILE"
sudo systemctl enable docker

# 配置 Docker
echo "配置 Docker..." | sudo tee -a "$LOG_FILE"

# 确保配置目录存在
if [ ! -d /etc/docker ]; then
    echo "配置目录 /etc/docker 不存在，创建中..." | sudo tee -a "$LOG_FILE"
    sudo mkdir -p /etc/docker
fi

# 创建 Docker 配置文件
cat > /etc/docker/daemon.json <<EOF
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "20m",
        "max-file": "3"
    },
    "ipv6": true,
    "fixed-cidr-v6": "fd00:dead:beef:c0::/80",
    "experimental": true,
    "ip6tables": true
}
EOF

# 重启 Docker 服务以应用配置更改
echo "重启 Docker 服务以应用配置更改..." | sudo tee -a "$LOG_FILE"
sudo systemctl restart docker

# 记录脚本结束时间
echo "脚本执行完成于 $(date)" | sudo tee -a "$LOG_FILE"

echo "Docker 安装和配置完成。"
