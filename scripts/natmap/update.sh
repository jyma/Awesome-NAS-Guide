#!/bin/sh

# =======================================================
# 1. 用户配置区域 (请根据实际情况修改)
# =======================================================

# qBittorrent 配置
QB_HOST="192.168.5.18"
QB_PORT="8085"
QB_USER="admin"
QB_PASS="admin"

# NATMap 参数配置，一般不需要改动
STUN_SERVER="stun.douyucdn.cn:18000"
HTTP_SERVER="baidu.com"
KEEP_ALIVE="10"  # 心跳间隔(秒)

# =======================================================
# 2. 逻辑处理区域 (自动探测 CPU + 模式判断)
# =======================================================

SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)
SCRIPT_PATH="$SCRIPT_DIR/$(basename "$0")"

# --- [模式一] 启动模式 (无参数时执行) ---
if [ -z "$1" ]; then
    echo ">>> 正在初始化 NATMap 启动器..."
    
    # 1. 自动探测 CPU 架构
    RAW_ARCH=$(uname -m)
    case "$RAW_ARCH" in
        x86_64)
            ARCH="x86_64"
            ;;
        aarch64|arm64)
            ARCH="aarch64"
            ;;
        *)
            echo "====================================================="
            echo "[错误] 不支持的 CPU 架构: $RAW_ARCH"
            echo "本脚本仅支持 'x86_64' 和 'aarch64'。"
            echo "请联系作者添加对应架构的二进制文件。"
            echo "====================================================="
            exit 1
            ;;
    esac

    BINARY_PATH="$SCRIPT_DIR/$ARCH/natmap"

    echo "    系统架构:  $RAW_ARCH"
    echo "    目标架构:  $ARCH"
    echo "    文件路径:  $BINARY_PATH"

    # 2. 检查二进制文件是否存在
    if [ ! -f "$BINARY_PATH" ]; then
        echo "====================================================="
        echo "[错误] 未找到二进制程序！"
        echo "预期位置: $BINARY_PATH"
        echo "请确保已将 natmap 程序放入对应的子文件夹中。"
        echo "====================================================="
        exit 1
    fi

    # 3. 自动赋予权限并启动
    chmod +x "$BINARY_PATH"
    
    echo ">>> 正在启动 NATMap 进程..."
    # 使用 exec 替换当前进程，并指定自己 (-e) 为回调脚本
    exec "$BINARY_PATH" -4 -u -k $KEEP_ALIVE -s $STUN_SERVER -h $HTTP_SERVER -t 127.0.0.1 -p 0 -e "$SCRIPT_PATH"

else
# --- [模式二] 回调模式 (有参数时执行 - 更新 qB) ---
    
    PUBLIC_PORT=$2
    PRIVATE_PORT=$4
    echo "=========================================="
    echo "NATMap 回调触发: 新公网端口 $PUBLIC_PORT"

    # 1. 登录 qB
    echo "1. 正在登录 qBittorrent..."
    QB_COOKIE=$(curl -s -i --header "Referer: http://$QB_HOST:$QB_PORT" --data "username=$QB_USER&password=$QB_PASS" "http://$QB_HOST:$QB_PORT/api/v2/auth/login" | grep -i set-cookie | cut -c13-48)

    if [ -z "$QB_COOKIE" ]; then
        echo "[错误] 登录失败。请检查脚本中的用户名/密码配置。"
        exit 1
    fi

    # 2. 修改端口
    echo "2. 正在修改监听端口..."
    curl -s -X POST -b "$QB_COOKIE" -d 'json={"listen_port":"'$PUBLIC_PORT'"}' "http://$QB_HOST:$QB_PORT/api/v2/app/setPreferences"

    # 3. 强制汇报 (增强提取逻辑)
    echo "3. 正在强制重新汇报 (Reannounce)..."
    RAW_DATA=$(curl -s -b "$QB_COOKIE" "http://$QB_HOST:$QB_PORT/api/v2/torrents/info?filter=all")
    TORRENTS=$(echo "$RAW_DATA" | grep -o '"hash":"[a-fA-F0-9]\{40\}"' | awk -F'"' '{print $4}' | tr '\n' '|')
    TORRENTS=${TORRENTS%|}

    if [ -n "$TORRENTS" ]; then
        curl -s -o /dev/null -X POST -b "$QB_COOKIE" -d "hashes=$TORRENTS" "http://$QB_HOST:$QB_PORT/api/v2/torrents/reannounce"
        echo "   -> 汇报请求已发送。"
    else
        echo "   -> 未找到运行中的种子。"
    fi

    # 4. 更新防火墙 (TCP+UDP)
    echo "4. 正在更新防火墙规则 (iptables)..."
    # 清理旧规则
    LINE_NUM=$(iptables -t nat -nvL --line-number | grep "$PRIVATE_PORT" | head -n 1 | awk '{print $1}')
    while [ -n "$LINE_NUM" ]; do
        iptables -t nat -D PREROUTING $LINE_NUM
        LINE_NUM=$(iptables -t nat -nvL --line-number | grep "$PRIVATE_PORT" | head -n 1 | awk '{print $1}')
    done
    # 添加新规则
    iptables -t nat -I PREROUTING -p tcp --dport "$PRIVATE_PORT" -j DNAT --to-destination "$QB_HOST:$PUBLIC_PORT"
    iptables -t nat -I PREROUTING -p udp --dport "$PRIVATE_PORT" -j DNAT --to-destination "$QB_HOST:$PUBLIC_PORT"

    echo "完成！所有设置已生效。"
    echo "=========================================="
fi