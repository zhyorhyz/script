#!/bin/bash

# 设置颜色和样式
BOLD='\033[1m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 打印帮助信息
function show_help() {
    echo -e "${BOLD}${RED}警告: 你即将运行 dd debian11，这个操作可能会造成系统问题或数据丢失。${NC}"
    echo -e "注意: 以下是选项的含义:"
    echo -e "  ${BOLD}yes${NC} - 确认继续执行 dd debian11 操作。"
    echo -e "  ${BOLD}no${NC} - 取消操作，脚本将退出。"
    echo -e "  ${BOLD}re${NC} - 重新输入参数（端口号和密码）。"
}

# 获取用户输入
function get_user_input() {
    while true; do
        read -p "请输入端口号 (默认: 22): " PORT
        PORT=${PORT:-22}

        # 验证端口号有效性
        if [[ ! "$PORT" =~ ^[0-9]+$ ]] || [ "$PORT" -lt 1 ] || [ "$PORT" -gt 65535 ]; then
            echo "无效的端口号，请输入一个介于 1 和 65535 之间的数字。"
            continue
        fi

        read -p "请输入密码 (默认: 12345zxc): " PASSWORD
        PASSWORD=${PASSWORD:-12345zxc}

        echo -e "\n端口: $PORT"
        echo -e "密码: $PASSWORD"

        show_help

        read -p "你确定要继续执行 dd debian11 吗？ (yes/no/re): " final_confirm
        
        case $final_confirm in
            yes)
                echo "执行 dd debian11..."
                bash <(wget --no-check-certificate -qO- 'https://raw.githubusercontent.com/zhyorhyz/dd/master/InstallNET.sh') -d 11 -v 64 -p "$PASSWORD" -port "$PORT" || { echo "dd失败"; exit 1; }
                exit 0
                ;;
            no)
                echo "操作已取消"
                exit 0
                ;;
            re)
                echo "重新输入参数..."
                break
                ;;
            *)
                echo "无效输入，请输入 'yes'、'no' 或 're'."
                ;;
        esac
    done
}

# 主程序
while true; do
    echo -e "\n${BOLD}${RED}警告: 你即将运行 dd debian11，这个操作可能会造成系统问题或数据丢失。${NC}"
    
    read -p "你确定要继续执行 dd debian11 吗？ (yes/no): " confirm
    
    case $confirm in
        yes)
            get_user_input
            ;;
        no)
            echo "操作已取消"
            exit 0
            ;;
        *)
            echo "无效输入，请输入 'yes' 或 'no'."
            ;;
    esac
done
