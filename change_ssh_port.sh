#!/bin/bash

# 新的SSH端口号
NEW_PORT=2222  # 可以更改为你需要的端口号

# 备份当前的sshd_config文件
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# 修改sshd_config文件中的端口号
sed -i "s/^Port .*/Port $NEW_PORT/" /etc/ssh/sshd_config

# 重新加载SSH服务以应用更改
systemctl reload sshd

# 显示修改后的配置
echo "SSH端口已更改为 $NEW_PORT"
