#!/bin/bash

function update_and_install() {
    echo "请选择更新包列表的方法:"
    echo "1. 使用 apt update"
    echo "2. 使用 apt-get update --allow-releaseinfo-change"
    read -p "请输入选项 (1/2): " update_option

    case $update_option in
        1)
            echo "执行 apt update..."
            if ! sudo apt update; then
                echo "apt update 失败"
                exit 1
            fi
            ;;
        2)
            echo "执行 apt-get update --allow-releaseinfo-change..."
            if ! sudo apt-get update --allow-releaseinfo-change; then
                echo "apt-get update --allow-releaseinfo-change 失败"
                exit 1
            fi
            # 运行 apt-get update 再次确认
            echo "尝试运行 apt-get update"
            if ! sudo apt-get update; then
                echo "apt-get update 失败"
                exit 1
            fi
            ;;
        *)
            echo "无效选项"
            exit 1
            ;;
    esac

    # 询问是否安装软件包
    read -p "是否继续安装 sudo, wget, curl 和 parted? (y/n): " install_confirm
    if [ "$install_confirm" = "y" ]; then
        echo "安装 sudo, wget, curl 和 parted..."
        if ! sudo apt install sudo wget curl parted -y; then
            echo "安装失败"
            exit 1
        fi
    else
        echo "已取消安装"
        exit 0
    fi
}

update_and_install
