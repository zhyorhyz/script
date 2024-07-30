#!/bin/bash

# 提示用户输入新的SSH端口号
read -p "请输入新的SSH端口号（1-65535）： " NEW_PORT

# 验证端口号是否在合法范围内
if [[ ! "$NEW_PORT" =~ ^[0-9]+$ ]] || [ "$NEW_PORT" -lt 1 ] || [ "$NEW_PORT" -gt 65535 ]; then
    echo "错误: 端口号 $NEW_PORT 无效。端口号应在 1 到 65535 之间。"
    exit 1
fi

# 检查是否安装了必要的工具
if ! command -v sed &> /dev/null || ! command -v systemctl &> /dev/null; then
    echo "错误: 必要的工具 `sed` 或 `systemctl` 未安装。"
    exit 1
fi

# 备份当前的sshd_config文件
if ! cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak; then
    echo "错误: 无法备份 sshd_config 文件。"
    exit 1
fi

# 修改sshd_config文件中的端口号
if ! sed -i "s/^Port .*/Port $NEW_PORT/" /etc/ssh/sshd_config; then
    echo "错误: 无法修改 sshd_config 文件。"
    exit 1
fi

# 检查sshd服务是否在运行
if ! systemctl is-active --quiet sshd; then
    echo "错误: sshd 服务未运行。"
    exit 1
fi

# 重新加载SSH服务以应用更改
if ! systemctl reload sshd; then
    echo "错误: 无法重新加载 sshd 服务。"
    exit 1
fi

# 显示修改后的配置
echo "SSH端口已更改为 $NEW_PORT"
