#!/bin/bash

set -e  # 确保脚本在遇到错误时停止执行

# 显示帮助信息
function show_help() {
    LIGHT_GREEN='\033[1;32m'
    CYAN='\033[1;36m'
    BOLD='\033[1m'
    UNDERLINE='\033[4m'
    NC='\033[0m' # No Color

    echo -e "${BOLD}${CYAN}=================================${NC}"
    echo -e "${BOLD}${CYAN} 用法: ${NC}${LIGHT_GREEN}$0 [选项]${NC}"
    echo -e "${BOLD}${CYAN}=================================${NC}"
    echo
    echo -e "${BOLD}${CYAN}选项:${NC}"
    echo -e "${BOLD}${CYAN}---------------------------------${NC}"
    echo -e "${LIGHT_GREEN}  1   启用 BBR${NC}"
    echo
    echo -e "${LIGHT_GREEN}  2   以交换文件的方式创建交换空间${NC}"
    echo
    echo -e "${LIGHT_GREEN}  3   安装 Nezha${NC}"
    echo
    echo -e "${LIGHT_GREEN}  4   启用 Bash 自动补全${NC}"
    echo
    echo -e "${LIGHT_GREEN}  5   下载并安装 Docker Compose${NC}"
    echo
    echo -e "${LIGHT_GREEN}  6   安装和配置 Docker${NC}"
    echo
    echo -e "${LIGHT_GREEN}  7   安装 Nginx Proxy Manager${NC}"
    echo
    echo -e "${LIGHT_GREEN}  8   安装和配置 Lsky Pro${NC}"
    echo
    echo -e "${LIGHT_GREEN}  9   安装极光面板（Jiguang）${NC}"
    echo
    echo -e "${LIGHT_GREEN}  10  更新主机名${NC}"
    echo
    echo -e "${LIGHT_GREEN}  11  dd debian11${NC}"
    echo
    echo -e "${LIGHT_GREEN}  12  x-ui-非原版${NC}"
    echo
    echo -e "${LIGHT_GREEN}  13  更改ssh端口${NC}"
    echo
    echo -e "${LIGHT_GREEN}  14  更改ssh密码${NC}"
    echo
    echo -e "${LIGHT_GREEN}  15  安装 uptime_kuma${NC}"
    echo
    echo -e "${LIGHT_GREEN}  16  安装 flare${NC}"
    echo
    echo -e "${BOLD}${CYAN}---------------------------------${NC}"
    echo -e "${BOLD}${CYAN}  0   退出${NC}"
    echo -e "${BOLD}${CYAN}=================================${NC}"
}



# 执行选择的操作
function execute_option() {
    case $1 in
        1)
            echo "启用 BBR..."
            curl -fsSL https://raw.githubusercontent.com/zhyorhyz/script/main/enable_bbr.sh | sudo bash || { echo "启用 BBR 失败"; exit 1; }
            ;;
        2)
            echo "以交换文件的方式创建交换空间..."
            curl -fsSL https://raw.githubusercontent.com/zhyorhyz/script/main/creat_swap.sh -o creat_swap.sh && sudo chmod +x creat_swap.sh && sudo ./creat_swap.sh && sudo rm -rf creat_swap.sh || { echo "创建交换分区失败"; exit 1; }
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
            curl -fsSL https://raw.githubusercontent.com/zhyorhyz/script/main/install_nginx_proxy_manager.sh -o install_nginx_proxy_manager.sh && sudo chmod +x install_nginx_proxy_manager.sh && sudo ./install_nginx_proxy_manager.sh && sudo rm -rf install_nginx_proxy_manager.sh  || { echo "安装 Nginx Proxy Manager 失败"; exit 1; }
            ;;
        8)
            echo "安装和配置 Lsky Pro..."
            curl -fsSL https://raw.githubusercontent.com/zhyorhyz/script/main/install_and_configure_lsky_pro.sh -o install_and_configure_lsky_pro.sh && sudo chmod +x install_and_configure_lsky_pro.sh && sudo ./install_and_configure_lsky_pro.sh && sudo rm -rf install_and_configure_lsky_pro.sh  || { echo "安装和配置 Lsky Pro 失败"; exit 1; }
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
            curl -fsSL https://raw.githubusercontent.com/zhyorhyz/script/main/dd_debian11.sh -o dd_debian11.sh && chmod +x dd_debian11.sh && sudo ./dd_debian11.sh && sudo rm -f dd_debian11.sh
            ;;
        12)
            echo "安装 x-ui-非原版..."
            bash <(curl -Ls https://raw.githubusercontent.com/zhyorhyz/x-ui-non-original/main/install.sh)
            ;;      
        13)
            echo "更改 ssh 端口..."
            curl -fsSL https://raw.githubusercontent.com/zhyorhyz/script/main/change_ssh_port.sh -o 1.sh && chmod +x 1.sh && sudo ./1.sh && sudo rm -f 1.sh || { echo "更改ssh端口失败"; exit 1; }
            ;;
        14)
            echo "更改 SSH 密码..."
            curl -fsSL https://raw.githubusercontent.com/zhyorhyz/script/main/change_password.sh -o /tmp/change_password.sh &&
            chmod +x /tmp/change_password.sh &&
            sudo /tmp/change_password.sh &&
            sudo rm -f /tmp/change_password.sh ||
            { echo "更改 SSH 密码失败"; exit 1; }
            ;;
        15)
            echo "安装 uptime_kuma"
            curl -fsSL https://raw.githubusercontent.com/zhyorhyz/script/main/setup_uptime_kuma.sh -o 1.sh && chmod +x 1.sh && ./1.sh && rm -f 1.sh  || { echo "安装失败"; exit 1; }
            ;;
        16)
            echo "安装 flare"
            curl -fsSL https://raw.githubusercontent.com/zhyorhyz/script/main/setup_flare.sh -o 1.sh && chmod +x 1.sh && ./1.sh && rm -f 1.sh  || { echo "安装失败"; exit 1; }
            ;;  
        16)
            echo "安装 flare"
            curl -fsSL https://raw.githubusercontent.com/zhyorhyz/script/main/ssetup_cryptgeon.sh -o 1.sh && chmod +x 1.sh && ./1.sh && rm -f 1.sh  || { echo "安装失败"; exit 1; }
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
