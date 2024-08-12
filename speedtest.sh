#!/bin/bash

# 更新系统并安装speedtest-cli
sudo apt-get update
sudo apt-get install -y speedtest-cli

# 运行测速并输出结果
speedtest-cli
