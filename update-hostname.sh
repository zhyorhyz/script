#!/bin/bash

set -e  # 确保脚本在遇到错误时停止执行

# 确保已经安装 jq
if ! command -v jq &> /dev/null; then
    echo "jq 工具未安装，正在安装..."
    sudo apt-get update
    sudo apt-get install -y jq
fi

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

# 获取 IP 地址（假设是外部 IP 地址）
IP_ADDRESS="127.0.0.1"

# 询问用户输入制造商名称
read -p "请输入制造商名称（例如 ExampleCorp）： " MANUFACTURER

# 确保制造商名称有效
if [ -z "$MANUFACTURER" ]; then
    echo "制造商名称不能为空。"
    exit 1
fi

# 获取 IP 归属地信息
LOCATION=$(curl -s https://ipinfo.io/ip | xargs -I {} curl -s https://ipinfo.io/{}/json | jq -r '.country')

# 检查是否成功获取到国别信息
if [ -z "$LOCATION" ]; then
    echo "无法获取 IP 归属地信息。"
    exit 1
fi

# 生成新的主机名
NEW_HOSTNAME="${MANUFACTURER}-${LOCATION}"

# 备份现有的 /etc/hosts 文件
BACKUP_FILE="/etc/hosts.bak"
if [ -f "$BACKUP_FILE" ]; then
    echo "备份文件 $BACKUP_FILE 已存在，跳过备份创建。"
else
    echo "备份现有的 /etc/hosts 文件..."
    sudo cp /etc/hosts "$BACKUP_FILE"
fi

# 删除旧的 127.0.0.1 条目（排除 localhost）
echo "删除旧的主机名条目..."
sudo awk '!/^127\.0\.0\.1\s+localhost/' /etc/hosts | sudo tee /etc/hosts.tmp
sudo mv /etc/hosts.tmp /etc/hosts

# 添加新的主机名条目
echo "添加新的主机名条目..."
echo "127.0.0.1 ${NEW_HOSTNAME}" | sudo tee -a /etc/hosts

echo "主机名 ${NEW_HOSTNAME} 已成功添加到 /etc/hosts 文件中。"
