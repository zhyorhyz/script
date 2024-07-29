#!/bin/bash

set -e  # 确保脚本在遇到错误时停止执行

# 显示帮助信息
show_help() {
    echo "用法: $0 [选项]"
    echo
    echo "选项:"
    echo "  -h, --help         显示此帮助信息"
    echo "  -q, --quiet        静默模式，不显示详细输出"
    echo
    echo "示例:"
    echo "  $0"
    echo "  $0 -q"
}

# 打印消息的函数（根据 QUIET_MODE 决定是否输出）
print_msg() {
    if [ "$QUIET_MODE" = false ]; then
        echo "$1"
    fi
}

# 确保以 root 用户或具有 sudo 权限的用户运行此脚本
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "错误: 请以 root 用户或具有 sudo 权限的用户运行此脚本。"
        exit 1
    fi
}

# 检查并安装 bash-completion 包
install_bash_completion() {
    print_msg "检查并安装 bash-completion 包..."
    if dpkg -l | grep -qw bash-completion; then
        print_msg "bash-completion 包已经安装。"
    else
        print_msg "安装 bash-completion 包..."
        sudo apt-get update -qq
        sudo apt-get install -y bash-completion
    fi
}

# 确保 bash-completion 配置文件存在
check_bash_completion_file() {
    if [ ! -f /etc/bash_completion ]; then
        echo "错误: /etc/bash_completion 文件不存在，请确保 bash-completion 包正确安装。"
        exit 1
    fi
}

# 配置 ~/.bashrc 以启用 bash-completion
configure_bashrc() {
    print_msg "配置 ~/.bashrc 以启用 bash-completion..."
    local BASHRC_FILE="$HOME/.bashrc"
    
    if ! grep -q 'bash_completion' "$BASHRC_FILE"; then
        print_msg "将 bash-completion 配置添加到 ~/.bashrc..."
        cat << EOF >> "$BASHRC_FILE"

# 启用 bash-completion
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi
EOF
    else
        print_msg "bash-completion 配置已经存在于 ~/.bashrc 中。"
    fi
}

# 处理命令行选项
parse_options() {
    QUIET_MODE=false
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            -h|--help) show_help; exit 0 ;;
            -q|--quiet) QUIET_MODE=true ;;
            *) echo "未知选项: $1"; show_help; exit 1 ;;
        esac
        shift
    done
}

# 主函数
main() {
    parse_options "$@"
    check_root
    install_bash_completion
    check_bash_completion_file
    configure_bashrc
    print_msg "请重新登录或运行 'source ~/.bashrc' 以使更改生效。"
    print_msg "自动补全配置完成。"
}

# 执行主函数
main "$@"

