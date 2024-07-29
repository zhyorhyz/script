#!/bin/bash

# 设定最低内核版本
REQUIRED_KERNEL_VERSION="4.9.0"

# 检查并安装必要工具
if ! command -v dpkg &> /dev/null; then
    echo "dpkg 工具未安装，正在安装..."
    sudo apt-get update
    sudo apt-get install -y dpkg
fi

if ! command -v grep &> /dev/null; then
    echo "grep 工具未安装，正在安装..."
    sudo apt-get update
    sudo apt-get install -y grep
fi

# 检查内核版本
current_kernel_version=$(uname -r | cut -d "-" -f 1)
if ! dpkg --compare-versions "$current_kernel_version" ge "$REQUIRED_KERNEL_VERSION"; then
    echo "当前内核版本 $current_kernel_version 不满足要求。请升级到至少 $REQUIRED_KERNEL_VERSION 版本。"
    exit 1
fi

# 检查是否已启用 BBR
bbr_enabled=$(sysctl net.ipv4.tcp_congestion_control | grep bbr)

if [[ -z "$bbr_enabled" ]]; then
    echo "BBR 模块未启用，正在启用..."
    
    # 加载 BBR 模块
    sudo modprobe tcp_bbr
    
    # 设置 BBR 为默认的拥塞控制算法
    echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p

    # 检查 BBR 是否已成功加载
    bbr_enabled=$(sysctl net.ipv4.tcp_congestion_control | grep bbr)
    if [[ -n "$bbr_enabled" ]]; then
        echo "BBR 模块成功启用。"
    else
        echo "BBR 模块启用失败。"
        exit 1
    fi
else
    echo "BBR 模块已启用。"
fi

# 验证 BBR 模块是否成功加载
if lsmod | grep -q tcp_bbr; then
    echo "BBR 模块已成功加载。"
else
    echo "BBR 模块未加载成功。"
    exit 1
fi
