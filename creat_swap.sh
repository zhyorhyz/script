#!/bin/bash

# 定义日志文件
LOG_FILE="/var/log/enable_swap.log"

# 输出信息到终端和日志文件的函数
log_message() {
    echo "$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | sudo tee -a "$LOG_FILE"
}

# 提示用户输入交换空间大小
read -p "请输入交换空间大小（如512M或2G）： " SWAP_SIZE

# 将交换空间大小转换为字节数
case "$SWAP_SIZE" in
    *M)
        SWAP_SIZE_BYTES=$(echo "${SWAP_SIZE%M} * 1024 * 1024" | bc)
        ;;
    *G)
        SWAP_SIZE_BYTES=$(echo "${SWAP_SIZE%G} * 1024 * 1024 * 1024" | bc)
        ;;
    *)
        log_message "不支持的交换空间单位。请使用M（兆字节）或G（吉字节）。"
        exit 1
        ;;
esac

# 确保提供的交换空间大小是有效的
if [ -z "$SWAP_SIZE_BYTES" ] || [ "$SWAP_SIZE_BYTES" -le 0 ]; then
    log_message "无效的交换空间大小。"
    exit 1
fi

# 提示用户输入swappiness值
read -p "请输入 swappiness 值（默认80），该值决定了系统使用交换空间的倾向：0 表示不使用交换，100 表示频繁使用交换空间。默认值为80： " SWAPPINESS

# 使用默认值如果用户没有输入
SWAPPINESS=${SWAPPINESS:-80}

# 验证 swappiness 是否是有效的整数
if ! [[ "$SWAPPINESS" =~ ^[0-9]+$ ]] || [ "$SWAPPINESS" -lt 0 ] || [ "$SWAPPINESS" -gt 100 ]; then
    log_message "无效的 swappiness 值。请输入0到100之间的整数。"
    exit 1
fi

# 检查现有的交换分区并删除
log_message "检查现有的交换分区..."
EXISTING_SWAP=$(sudo swapon --show=NAME | grep -w '/swapfile')
if [ -n "$EXISTING_SWAP" ]; then
    log_message "发现现有的交换分区，正在禁用和删除..."
    sudo swapoff /swapfile
    sudo rm /swapfile
else
    log_message "没有发现现有的交换分区。"
fi

# 创建交换文件
log_message "创建交换文件..."
sudo fallocate -l "$SWAP_SIZE" /swapfile

# 如果 fallocate 不可用，使用 dd 创建交换文件
if [ ! -f /swapfile ]; then
    log_message "fallocate 命令不可用，使用 dd 创建交换文件..."
    sudo dd if=/dev/zero of=/swapfile bs=1M count=$((SWAP_SIZE_BYTES / 1024 / 1024)) status=progress
fi

# 设置交换文件权限
log_message "设置交换文件权限..."
sudo chmod 600 /swapfile

# 确保权限设置成功
if [ "$(stat -c %a /swapfile)" -ne 600 ]; then
    log_message "权限设置失败，请检查 /swapfile 的权限。"
    exit 1
fi

# 设置交换空间
log_message "设置交换空间..."
sudo mkswap /swapfile

# 启用交换空间
log_message "启用交换空间..."
sudo swapon /swapfile

# 验证交换空间
log_message "验证交换空间..."
free -h

# 添加到 /etc/fstab 以便系统重启时自动启用
log_message "更新 /etc/fstab 文件..."
if ! grep -q '/swapfile' /etc/fstab; then
    echo "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab
else
    log_message "/swapfile 已经在 /etc/fstab 中"
fi

# 设置 swappiness 值
log_message "设置 swappiness 值为 ${SWAPPINESS}..."
sudo sysctl vm.swappiness=${SWAPPINESS}
echo "vm.swappiness=${SWAPPINESS}" | sudo tee -a /etc/sysctl.conf

log_message "交换空间配置完成。"
