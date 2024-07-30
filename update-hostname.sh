#!/bin/bash

set -e  # 确保脚本在遇到错误时停止执行

# 显示帮助信息
function show_help() {
    echo "用法: $0 [选项]"
    echo
    echo "选项:"
    echo "  -h, --help         显示此帮助信息"
}

# 检查并安装 jq 工具
function check_and_install_jq() {
    if ! command -v jq &> /dev/null; then
        echo "jq 工具未安装，正在尝试安装..."
        if [ -x "$(command -v apt-get)" ]; then
            sudo apt-get update
            sudo apt-get install -y jq
        elif [ -x "$(command -v yum)" ]; then
            sudo yum install -y jq
        elif [ -x "$(command -v dnf)" ]; then
            sudo dnf install -y jq
        elif [ -x "$(command -v brew)" ]; then
            brew install jq
        else
            echo "未能自动安装 jq，请手动安装。"
            exit 1
        fi
    fi
}

# 解析命令行选项
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help) show_help; exit 0 ;;
        *) echo "未知选项: $1"; show_help; exit 1 ;;
    esac
    shift
done

# 检查并安装 jq 工具
check_and_install_jq

# 询问用户输入制造商名称
read -p "请输入制造商名称（例如 vendor）： " MANUFACTURER

if [ -z "$MANUFACTURER" ]; then
    echo "制造商名称不能为空。"
    exit 1
fi

# 提取 IP 地址
IP_ADDRESS=$(hostname -I | awk '{print $1}')
if [ -z "$IP_ADDRESS" ]; then
    echo "无法提取 IP 地址。"
    exit 1
fi
echo "提取的 IP 地址: $IP_ADDRESS"

# 获取国家代码
echo "获取国家代码..."
API_RESPONSE=$(curl -s "http://ip-api.com/json/$IP_ADDRESS")
if [ -z "$API_RESPONSE" ]; then
    echo "无法从 API 获取响应。"
    exit 1
fi
COUNTRY_CODE=$(echo "$API_RESPONSE" | jq -r '.countryCode')

if [ -z "$COUNTRY_CODE" ] || [ "$COUNTRY_CODE" == "null" ]; then
    echo "无法提取国家代码。"

    # 请求用户手动输入 IP 地址或国家代码
    while true; do
        read -p "请输入国家代码（例如 US）或 IP 地址以重试获取国家代码： " USER_INPUT

        if [[ "$USER_INPUT" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            # 如果输入是 IP 地址，重新获取国家代码
            IP_ADDRESS=$USER_INPUT
            API_RESPONSE=$(curl -s "http://ip-api.com/json/$IP_ADDRESS")
            if [ -z "$API_RESPONSE" ]; then
                echo "无法从 API 获取响应。"
                continue
            fi
            COUNTRY_CODE=$(echo "$API_RESPONSE" | jq -r '.countryCode')
            if [ -n "$COUNTRY_CODE" ] && [ "$COUNTRY_CODE" != "null" ]; then
                break
            else
                echo "无法提取国家代码。请重新输入 IP 地址或国家代码。"
            fi
        elif [[ "$USER_INPUT" =~ ^[A-Z]{2}$ ]]; then
            # 如果输入是国家代码，直接使用
            COUNTRY_CODE=$USER_INPUT
            break
        else
            echo "输入无效。请提供有效的 IP 地址或国家代码。"
        fi
    done
fi

# 生成新的主机名
NEW_HOSTNAME="${MANUFACTURER}-${COUNTRY_CODE}"
echo "新的主机名: $NEW_HOSTNAME"

# 修改主机名
sudo hostnamectl set-hostname "$NEW_HOSTNAME"

# 更新 /etc/hosts 文件
echo "更新 /etc/hosts 文件..."

# 确保 127.0.0.1    localhost 条目存在
if ! grep -q "127.0.0.1[[:space:]]localhost" /etc/hosts; then
    echo "127.0.0.1    localhost" | sudo tee -a /etc/hosts > /dev/null
fi

# 确保主机名条目存在
if grep -q "127.0.0.1[[:space:]]$NEW_HOSTNAME" /etc/hosts; then
    echo "主机名条目已存在，不需要更新。"
else
    sudo sed -i "/^127.0.0.1[[:space:]].*/d" /etc/hosts
    echo "127.0.0.1    $NEW_HOSTNAME" | sudo tee -a /etc/hosts > /dev/null
fi

# 打印最终的 /etc/hosts 内容以验证更改
echo "最终的 /etc/hosts 内容:"
cat /etc/hosts

echo "主机名已更新为 $NEW_HOSTNAME"
