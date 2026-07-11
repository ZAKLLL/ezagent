#!/bin/bash
# PostToolUse hook (matcher: Edit|Write|NotebookEdit|Bash)
# 记录本次会话是否改动了 memory/notes/work 下的文件，以及是否调用过 ./memory_add.sh
# 依据: https://code.claude.com/docs/en/hooks.md — PostToolUse 的 stdin 含 tool_name / tool_input

command -v jq >/dev/null 2>&1 || exit 0

input="$(cat)"
session_id=$(echo "$input" | jq -r '.session_id // "unknown"')
tool_name=$(echo "$input" | jq -r '.tool_name // ""')

STATE_DIR="${TMPDIR:-/tmp}/ezagent-hooks"
mkdir -p "$STATE_DIR" 2>/dev/null || exit 0
STATE_FILE="$STATE_DIR/$session_id.state"

case "$tool_name" in
    Edit|Write|NotebookEdit)
        file_path=$(echo "$input" | jq -r '.tool_input.file_path // .tool_input.notebook_path // ""')
        case "$file_path" in
            */memory/mem_*.md) echo "memory_touched=1" >> "$STATE_FILE" ;;
            */notes/*|*/work/*) echo "core_touched=1" >> "$STATE_FILE" ;;
        esac
        ;;
    Bash)
        command_str=$(echo "$input" | jq -r '.tool_input.command // ""')
        case "$command_str" in
            *memory_add.sh*) echo "memory_touched=1" >> "$STATE_FILE" ;;
        esac
        ;;
esac

exit 0
