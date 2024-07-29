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

# 读取用户输入
read -p "请输入制造商名称（例如 vendor）： " MANUFACTURER

# 确保制造商名称不为空
if [ -z "$MANUFACTURER" ]; then
    echo "制造商名称不能为空。"
    exit 1
fi

# 获取 IP 地址
IP_ADDRESS=$(hostname -I | awk '{print $1}')

# 如果 IP 地址为空，使用回环地址
if [ -z "$IP_ADDRESS" ]; then
    IP_ADDRESS="127.0.0.1"
fi

# 获取地理位置
GEO_INFO=$(curl -s https://ipinfo.io/$IP_ADDRESS?token=YOUR_API_TOKEN)

# 提取国家代码
COUNTRY_CODE=$(echo $GEO_INFO | jq -r '.country')

# 检查是否成功提取到国家代码
if [ "$COUNTRY_CODE" == "null" ]; then
    echo "无法提取国家代码。"
    exit 1
fi

# 生成主机名
NEW_HOSTNAME="${MANUFACTURER}-${COUNTRY_CODE}"

# 更新 /etc/hostname 文件
echo "$NEW_HOSTNAME" | sudo tee /etc/hostname

# 更新 /etc/hosts 文件
sudo sed -i "/^127.0.0.1\s\+rn-us/d" /etc/hosts
echo "127.0.0.1   $NEW_HOSTNAME" | sudo tee -a /etc/hosts

# 应用更改
sudo hostnamectl set-hostname "$NEW_HOSTNAME"

echo "主机名已更改为 $NEW_HOSTNAME"
