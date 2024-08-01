#!/bin/bash

# 更新系统并安装 Git
apt update && apt install git -y

# 克隆项目
git clone https://github.com/zhyorhyz/XrayR-release

# 进入项目目录
cd XrayR-release

# 检查 config 目录是否存在
if [ ! -d "config" ]; then
  echo "目录 config 不存在。退出脚本..."
  exit 1
fi

# 检查 config.yml 文件是否存在
config_file="config/config.yml"
if [ ! -f "$config_file" ]; then
  echo "配置文件 $config_file 不存在。退出脚本..."
  exit 1
fi

# 提取 ApiHost 的值
current_ApiHost=$(grep -A 3 'ApiConfig:' "$config_file" | grep 'ApiHost:' | awk -F': ' '{print $2}' | tr -d '"')

# 预期的 ApiHost 值
expected_ApiHost="http://127.0.0.1:667"

if [ "$current_ApiHost" != "$expected_ApiHost" ]; then
  echo "当前 ApiHost 的值是 $current_ApiHost，而不是预期的 $expected_ApiHost。"
  echo "是否更改 ApiHost、ApiKey 和 NodeID 的值？"
  read -r -p "确认更改 (y/n)? [默认: y]: " change_values
  change_values=${change_values:-y}

  if [[ "$change_values" != [yY] ]]; then
    echo "不更改配置。退出脚本..."
    exit 1
  fi
fi

# 获取用户输入
read -p "请输入 ApiHost（例如 http://127.0.0.1:667）: " ApiHost
read -p "请输入 ApiKey: " ApiKey
read -p "请输入 NodeID: " NodeID

# 更新配置文件中的 ApiHost, ApiKey 和 NodeID
echo "更新配置文件..."

# 使用 sed 更新 ApiHost
sed -i "/ApiConfig:/,/NodeID:/s|^\(\s*ApiHost:\s*\).*\$|\1\"$ApiHost\"|" "$config_file"

# 使用 sed 更新 ApiKey
sed -i "/ApiConfig:/,/NodeID:/s|^\(\s*ApiKey:\s*\).*\$|\1\"$ApiKey\"|" "$config_file"

# 使用 sed 更新 NodeID
sed -i "/ApiConfig:/,/NodeID:/s|^\(\s*NodeID:\s*\).*\$|\1$NodeID|" "$config_file"

# 启动 Docker
echo "启动 Docker 服务..."
docker-compose up -d

echo "操作完成。"
