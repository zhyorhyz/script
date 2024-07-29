#!/bin/bash

# 获取用户输入的交换文件大小
read -p "请输入交换文件的大小（例如 1G、512M）： " SWAPSIZE

# 提示用户关于 swappiness 值的意义
echo "swappiness 值决定了系统使用交换空间的积极程度。它的取值范围是 0 到 100："
echo " - 值较低（例如 10）：系统会尽量避免使用交换空间，更多地使用物理内存。适用于内存较大、需要较少交换的场景。"
echo " - 值较高（例如 60）：系统会较为积极地使用交换空间，适用于内存较小、需要更多交换的场景。"
echo "请输入 swappiness 值（例如 10、60），或直接按 Enter 以使用默认值 80： "
read SWAPPINESS

# 如果用户没有输入 swappiness 值，则使用默认值 80
if [ -z "$SWAPPINESS" ]; then
  SWAPPINESS=80
fi

# 定义交换文件的路径
SWAPFILE="/swapfile"

# 检查脚本是否以 root 用户运行
if [ "$(id -u)" -ne "0" ]; then
  echo "请以 root 用户运行此脚本。"
  exit 1
fi

# 计算块大小和块数
case $SWAPSIZE in
  *G)
    BLOCKSIZE=1M
    COUNT=$(echo ${SWAPSIZE%G} | awk '{print $1 * 1024}')
    ;;
  *M)
    BLOCKSIZE=1M
    COUNT=${SWAPSIZE%M}
    ;;
  *)
    echo "不支持的交换文件大小格式。请使用类似 1G 或 512M 的格式。"
    exit 1
    ;;
esac

# 删除旧的交换文件（如果存在）
if [ -f "$SWAPFILE" ]; then
  echo "删除旧的交换文件 $SWAPFILE..."
  rm -f $SWAPFILE
  if [ $? -ne 0 ]; then
    echo "删除交换文件失败。"
    exit 1
  fi
fi

# 创建新的交换文件
echo "创建交换文件..."
dd if=/dev/zero of=$SWAPFILE bs=$BLOCKSIZE count=$COUNT status=progress
if [ $? -ne 0 ]; then
  echo "创建交换文件失败。"
  exit 1
fi

# 设置交换文件权限
chmod 600 $SWAPFILE
if [ $? -ne 0 ]; then
  echo "设置交换文件权限失败。"
  exit 1
fi

# 将文件设置为交换区域
mkswap $SWAPFILE
if [ $? -ne 0 ]; then
  echo "设置交换区域失败。"
  exit 1
fi

# 启用交换文件
swapon $SWAPFILE
if [ $? -ne 0 ]; then
  echo "启用交换文件失败。"
  exit 1
fi

# 更新 /etc/fstab 文件
if ! grep -q "^$SWAPFILE " /etc/fstab; then
  echo "$SWAPFILE none swap sw 0 0" >> /etc/fstab
  if [ $? -ne 0 ]; then
    echo "更新 /etc/fstab 失败。"
    exit 1
  fi
fi

# 设置 swappiness 值
echo "设置 swappiness 值为 $SWAPPINESS..."
sysctl vm.swappiness=$SWAPPINESS
if [ $? -ne 0 ]; then
  echo "设置 swappiness 值失败。"
  exit 1
fi

# 永久设置 swappiness 值
if ! grep -q "^vm.swappiness=" /etc/sysctl.conf; then
  echo "vm.swappiness=$SWAPPINESS" >> /etc/sysctl.conf
  if [ $? -ne 0 ]; then
    echo "更新 /etc/sysctl.conf 失败。"
    exit 1
  fi
fi

# 显示当前交换空间和 swappiness 值
echo "交换文件创建并启用成功。当前交换空间："
swapon --show
echo "当前 swappiness 值："
sysctl vm.swappiness

exit 0
