#!/bin/bash

set -e  # 确保脚本在遇到错误时停止执行

# 检查并安装 jq
if ! command -v jq &> /dev/null; then
    echo "jq 工具未安装，正在安装..."
    sudo apt-get update
    sudo apt-get install -y jq
fi

# 获取公网 IP 地址
IP_ADDRESS=$(curl -s https://api.ipify.org)

# 使用 ipinfo.io API 获取 IP 地址的归属地
LOCATION=$(curl -s https://ipinfo.io/${IP_ADDRESS}/json)

# 提取国家和厂家信息
COUNTRY=$(echo "$LOCATION" | jq -r '.country')
ORG=$(echo "$LOCATION" | jq -r '.org')

# 提示用户输入制造商名称
read -p "请输入制造商名称（例如 'ExampleVendor'）： " VENDOR

# 构造主机名
HOSTNAME="${VENDOR}-${COUNTRY}"

# 设置主机名
echo "设置主机名为 ${HOSTNAME}..."
sudo hostnamectl set-hostname "${HOSTNAME}"

# 更新 /etc/hosts 文件，保留 localhost 条目
echo "更新 /etc/hosts 文件..."
sudo sed -i "/127.0.0.1\s*localhost/d" /etc/hosts
echo "127.0.0.1 ${HOSTNAME} localhost" | sudo tee -a /etc/hosts > /dev/null

echo "主机名已更新为 ${HOSTNAME} 并成功写入 /etc/hosts 文件。"
