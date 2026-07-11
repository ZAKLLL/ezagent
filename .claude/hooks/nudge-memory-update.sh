#!/bin/bash
# Stop hook: 会话结束时检查——改了 notes/work 但没跑 memory_add.sh 就提醒用户（不打扰 Agent，不阻断继续）
# 依据: https://code.claude.com/docs/en/hooks.md — Stop 的 systemMessage 只展示给用户，不进入模型上下文、不强制继续对话

command -v jq >/dev/null 2>&1 || exit 0

input="$(cat)"
session_id=$(echo "$input" | jq -r '.session_id // "unknown"')

STATE_DIR="${TMPDIR:-/tmp}/ezagent-hooks"
STATE_FILE="$STATE_DIR/$session_id.state"

[ -f "$STATE_FILE" ] || exit 0

core_touched=$(grep -c "^core_touched=1" "$STATE_FILE" 2>/dev/null)
memory_touched=$(grep -c "^memory_touched=1" "$STATE_FILE" 2>/dev/null)
core_touched=${core_touched:-0}
memory_touched=${memory_touched:-0}

if [ "$core_touched" -gt 0 ] && [ "$memory_touched" -eq 0 ]; then
    jq -n '{systemMessage: "⚠️ 本次会话修改了 notes/ 或 work/ 下的文件，但没检测到 ./memory_add.sh 的调用。如果这些改动值得记住，建议手动补一条记忆。"}'
fi

# 每次 Stop 后清空状态，避免同一会话反复提示
rm -f "$STATE_FILE"

exit 0
