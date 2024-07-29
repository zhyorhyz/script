#!/bin/bash

set -e  # 确保脚本在遇到错误时停止执行

# 显示帮助信息
function show_help() {
    echo "用法: $0 [选项]"
    echo
    echo "选项:"
    echo "  1   启用 BBR"
    echo "  2   创建交换分区"
    echo "  3   安装 Nezha"
    echo "  4   启用 Bash 自动补全"
    echo "  5   下载并安装 Docker Compose"
    echo "  6   安装和配置 Docker"
    echo "  7   安装 Nginx Proxy Manager"
    echo "  8   安装和配置 Lsky Pro"
    echo "  9   安装极光面板（Jiguang）"
    echo "  10  更新主机名"
    echo "  11  dd debian11"
    echo "  0   退出"
}

# 执行选择的操作
function execute_option() {
    case $1 in
        1)
            echo "启用 BBR..."
            curl -fsSL https://raw.githubusercontent.com/zhyorhyz/script/main/enable_bbr.sh | sudo bash || { echo "启用 BBR 失败"; exit 1; }
            ;;
        2)
            echo "创建交换分区..."
            curl -fsSL https://raw.githubusercontent.com/zhyorhyz/script/main/creat_swap.sh -o creat_swap.sh && sudo chmod +x creat_swap.sh && sudo rm -rf creat_swap.sh || { echo "创建交换分区失败"; exit 1; }
            ;;
        3)
            echo "安装 Nezha..."
            curl -L https://raw.githubusercontent.com/naiba/nezha/master/script/install.sh -o nezha.sh && chmod +x nezha.sh && sudo ./nezha.sh || { echo "安装 Nezha 失败"; exit 1; }
            ;;
        4)
            echo "启用 Bash 自动补全..."
            curl -fsSL https://raw.githubusercontent.com/zhyorhyz/script/main/enable_bash_completion.sh | sudo bash || { echo "启用 Bash 自动补全 失败"; exit 1; }
            ;;
        5)
            echo "下载并安装 Docker Compose..."
            curl -fsSL https://raw.githubusercontent.com/zhyorhyz/script/main/download_and_install_docker_compose.sh | sudo bash || { echo "下载并安装 Docker Compose 失败"; exit 1; }
            ;;
        6)
            echo "安装和配置 Docker..."
            curl -fsSL https://raw.githubusercontent.com/zhyorhyz/script/main/install_and_configure_docker.sh | sudo bash || { echo "安装和配置 Docker 失败"; exit 1; }
            ;;
        7)
            echo "安装 Nginx Proxy Manager..."
            curl -fsSL https://raw.githubusercontent.com/zhyorhyz/script/main/install_nginx_proxy_manager.sh | sudo bash || { echo "安装 Nginx Proxy Manager 失败"; exit 1; }
            ;;
        8)
            echo "安装和配置 Lsky Pro..."
            curl -fsSL https://raw.githubusercontent.com/zhyorhyz/script/main/install_and_configure_lsky_pro.sh | sudo bash || { echo "安装和配置 Lsky Pro 失败"; exit 1; }
            ;;
        9)
            echo "安装极光面板（Jiguang）..."
            bash <(curl -fsSL https://raw.githubusercontent.com/Aurora-Admin-Panel/deploy/main/install.sh) || { echo "安装极光面板失败"; exit 1; }
            ;;
        10)
            echo "更新主机名..."
            curl -fsSL https://raw.githubusercontent.com/zhyorhyz/script/main/update-hostname.sh -o update-hostname.sh && chmod +x update-hostname.sh && sudo ./update-hostname.sh && sudo rm -f update-hostname.sh || { echo "更新主机名失败"; exit 1; }
            ;;
        11)
            echo "dd debian11"
            bash <(wget --no-check-certificate -qO- 'https://raw.githubusercontent.com/zhyorhyz/dd/master/InstallNET.sh') -d 11 -v 64 -p "12345zxc" -port "22" || { echo "dd失败"; exit 1; }
            ;;
        0)
            echo "退出"
            exit 0
            ;;
        *)
            echo "无效选项"
            show_help
            ;;
    esac
}

# 主程序
while true; do
    clear
    show_help
    read -p "请选择一个选项: " option
    execute_option "$option"
    echo "按任意键继续..."
    read -n 1
done
