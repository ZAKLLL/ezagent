#!/bin/bash
# SessionStart hook: 检查记忆新鲜度，提醒 Agent 关注是否有遗漏没记录的内容
# 依据: https://code.claude.com/docs/en/hooks.md — SessionStart 的 stdout（exit 0）会直接作为上下文注入

cd "${CLAUDE_PROJECT_DIR:-$(pwd)}" 2>/dev/null || exit 0

MEMORY_DIR="memory"
[ -d "$MEMORY_DIR" ] || exit 0

latest_file=$(ls -t "$MEMORY_DIR"/mem_*.md 2>/dev/null | head -1)

if [ -z "$latest_file" ]; then
    echo "提示：memory/ 下还没有任何记忆文件。完成有意义的工作后建议调用 ./memory_add.sh 记录。"
    exit 0
fi

latest_mtime=$(stat -f %m "$latest_file" 2>/dev/null || stat -c %Y "$latest_file" 2>/dev/null)
[ -n "$latest_mtime" ] || exit 0

now=$(date +%s)
days_ago=$(( (now - latest_mtime) / 86400 ))

if [ "$days_ago" -ge 3 ]; then
    echo "提示：最近一条记忆是 $days_ago 天前写的（$(basename "$latest_file")）。如果这期间有值得记住的进展，本次会话结束前考虑用 ./memory_add.sh 补一条。"
fi

exit 0
