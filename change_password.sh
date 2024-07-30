#!/bin/bash

# 定义日志文件
LOGFILE="/var/log/change_password.log"

# 记录日志函数
log_change() {
    echo "$(date) - $1" >> "$LOGFILE"
}

# 提示用户输入目标用户名
read -p "请输入要更改密码的用户名： " USERNAME

# 检查用户是否存在
if ! id "$USERNAME" &>/dev/null; then
    echo "错误: 用户 $USERNAME 不存在。"
    log_change "错误: 用户 $USERNAME 不存在。"
    exit 1
fi

# 询问用户是否要更改密码
read -p "是否要更改 $USERNAME 的密码？(yes/no)：" CONFIRM
if [[ "$CONFIRM" != "yes" && "$CONFIRM" != "no" ]]; then
    echo "错误: 请输入 'yes' 或 'no'。"
    exit 1
fi

if [ "$CONFIRM" == "no" ]; then
    echo "密码更改操作已取消。"
    exit 0
fi

# 提示用户输入新的密码
echo "请输入新的密码（8到64个字符，包括字母、数字和特殊字符）："
while true; do
    read -sp "新的密码： " NEW_PASSWORD
    echo
    read -sp "请再次输入新的密码以确认： " CONFIRM_PASSWORD
    echo

    # 验证两次密码是否一致
    if [ "$NEW_PASSWORD" != "$CONFIRM_PASSWORD" ]; then
        echo "错误: 两次输入的密码不一致。请重新输入。"
    elif [[ ${#NEW_PASSWORD} -lt 8 || ${#NEW_PASSWORD} -gt 64 ]]; then
        echo "错误: 密码长度应在 8 到 64 个字符之间。请重新输入。"
    elif ! [[ "$NEW_PASSWORD" =~ [a-z] ]] || ! [[ "$NEW_PASSWORD" =~ [A-Z] ]] || ! [[ "$NEW_PASSWORD" =~ [0-9] ]] || ! [[ "$NEW_PASSWORD" =~ [^a-zA-Z0-9] ]]; then
        echo "错误: 密码应包含字母、数字和特殊字符。请重新输入。"
    else
        break
    fi
done

# 更改用户的密码
echo "$USERNAME:$NEW_PASSWORD" | chpasswd
if [ $? -eq 0 ]; then
    echo "用户 $USERNAME 的密码已成功更改。"
    log_change "用户 $USERNAME 的密码已成功更改。"
else
    echo "错误: 无法更改用户 $USERNAME 的密码。"
    log_change "错误: 无法更改用户 $USERNAME 的密码。"
    exit 1
fi
