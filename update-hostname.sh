#!/bin/bash

set -e  # 确保脚本在遇到错误时停止执行

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

# 询问用户输入制造商名称
read -p "请输入制造商名称（例如 vendor）： " MANUFACTURER

if [ -z "$MANUFACTURER" ]; then
    echo "制造商名称不能为空。"
    exit 1
fi

# 提取 IP 地址
IP_ADDRESS=$(hostname -I | awk '{print $1}')
echo "提取的 IP 地址: $IP_ADDRESS"

# 获取国家代码
echo "获取国家代码..."
API_RESPONSE=$(curl -s "http://ip-api.com/json/$IP_ADDRESS")
echo "API 响应: $API_RESPONSE"
COUNTRY_CODE=$(echo "$API_RESPONSE" | jq -r '.countryCode')

if [ -z "$COUNTRY_CODE" ] || [ "$COUNTRY_CODE" == "null" ]; then
    echo "无法提取国家代码。"
    exit 1
fi

# 生成新的主机名
NEW_HOSTNAME="${MANUFACTURER}-${COUNTRY_CODE}"
echo "新的主机名: $NEW_HOSTNAME"

# 修改主机名
sudo hostnamectl set-hostname "$NEW_HOSTNAME"

# 更新 /etc/hosts 文件
echo "更新 /etc/hosts 文件..."

# 确保 /etc/hosts 文件中包含 127.0.0.1    localhost
if ! grep -q "127.0.0.1[[:space:]]localhost" /etc/hosts; then
    echo "127.0.0.1    localhost" | sudo tee -a /etc/hosts
fi

# 确保 /etc/hosts 文件中包含新的主机名
if grep -q "127.0.0.1[[:space:]]" /etc/hosts; then
    # 更新已有的 127.0.0.1 条目
    sudo sed -i -e "/^127.0.0.1[[:space:]]/d" /etc/hosts
fi

# 添加新的主机名条目
echo -e "127.0.0.1\t$NEW_HOSTNAME" | sudo tee -a /etc/hosts

echo "主机名已更新为 $NEW_HOSTNAME"
