#!/bin/bash

# ================= 配置区 =================
SOURCE_DIRS=(
    "/vol1/1000/mje"
    "/vol1/1000/Photos"
    "/vol1/1002"
)
DEST_ROOT="alist-crypt:/"
LOG_FILE="/home/admin/rclone_daily.log"
LOCK_FILE="/tmp/rclone_autobackup.lock"
# =========================================

# --- 核心：防重叠逻辑 ---
# 打开锁文件，并将其绑定到文件描述符 200
exec 200>"$LOCK_FILE"

# 尝试获取非阻塞锁（-n），如果失败则说明另一个实例正在运行
if ! flock -n 200; then
    echo "$(date "+%Y-%m-%d %H:%M:%S") ⚠️ 警告: 检测到上一个备份进程尚未结束，本次任务跳过。" >> "$LOG_FILE"
    exit 1
fi
# -----------------------

echo "========================================" >> "$LOG_FILE"
echo "🚀 强制同步任务启动: $(date "+%Y-%m-%d %H:%M:%S")" >> "$LOG_FILE"

for SOURCE in "${SOURCE_DIRS[@]}"; do
    [ ! -d "$SOURCE" ] && echo "⚠️ 跳过: $SOURCE 不存在" >> "$LOG_FILE" && continue

    DIR_NAME=$(basename "$SOURCE")
    FULL_DEST="$DEST_ROOT$DIR_NAME"

    echo "----------------------------------------" >> "$LOG_FILE"
    echo "📂 正在处理目录: $SOURCE" >> "$LOG_FILE"

    # 1️⃣ 使用进程替换直接读取差异清单并执行删除
    echo "🔍 扫描并清理云端不一致的文件..." >> "$LOG_FILE"
    
    rclone check "$SOURCE" "$FULL_DEST" --size-only --one-way --differ - 2>/dev/null | while IFS= read -r FILE; do
        if [ -n "$FILE" ]; then
            echo "🗑️ 正在删除云端不一致文件: $FILE" >> "$LOG_FILE"
            rclone deletefile "$FULL_DEST/$FILE" >> "$LOG_FILE" 2>&1
        fi
    done

    # 2️⃣ 执行上传补传
    echo "⬆️ 开始上传补传..." >> "$LOG_FILE"
    rclone copy "$SOURCE" "$FULL_DEST" \
        --size-only \
        --transfers 2 \
        --checkers 4 \
        --buffer-size 32M \
        --timeout 10h \
        --contimeout 30s \
        --retries 3 \
        --low-level-retries 10 \
        --disable-http2 \
        --exclude "__MACOSX/**" \
        --exclude "._*" \
        --exclude "*.DS_Store" \
        --exclude "*.torrent" \
        --log-level INFO \
        --log-file "$LOG_FILE"

    [ $? -eq 0 ] && echo "✅ $DIR_NAME 处理完成" >> "$LOG_FILE" || echo "❌ $DIR_NAME 失败" >> "$LOG_FILE"
done

echo "🏁 所有任务结束: $(date "+%Y-%m-%d %H:%M:%S")" >> "$LOG_FILE"
echo "========================================" >> "$LOG_FILE"