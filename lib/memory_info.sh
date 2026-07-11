#!/bin/bash

# 记忆信息函数库

get_memory_stats() {
    local dir="memory"

    if [ ! -d "$dir" ]; then
        echo "  文件数：0"
        echo "  最新：N/A"
        return
    fi

    local count=$(find "$dir" -name "mem_*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    local latest=$(get_latest_file "$dir")

    echo "  文件数：$count"
    echo "  最新：${latest:-N/A}"
}

show_overview_preview() {
    local overview_file="memory/overview.md"

    echo -e "${BOLD}记忆概览:${NC}"
    local entries=""
    if [ -f "$overview_file" ]; then
        entries=$(grep '^- ' "$overview_file" 2>/dev/null | tail -3)
    else
        if [ -d "memory" ]; then
            entries=$(find "memory" -name 'mem_*.md' -type f | sort | tail -5 | while read -r mem_file; do
                local mem_date summary_line summary_type summary_title
                mem_date=$(basename "$mem_file" | sed 's/^mem_//;s/\.md$//;s/_/-/g')
                summary_line=$(grep -E '^\[[^]]+\][[:space:]]*[a-zA-Z0-9_-]+:' "$mem_file" 2>/dev/null | tail -1)
                [ -z "$summary_line" ] && continue
                summary_type=$(printf '%s\n' "$summary_line" | sed -En 's/^\[[^]]*\][[:space:]]*([a-zA-Z0-9_-]+):.*/\1/p')
                summary_title=$(printf '%s\n' "$summary_line" | sed -E 's/^\[[^]]*\][[:space:]]*[a-zA-Z0-9_-]+:[[:space:]]*//')
                echo "- $mem_date | [$summary_type] $summary_title | 主题: 其他 | 来源: legacy-memory | 详情: $(basename "$mem_file")"
            done | tail -3)
        fi
    fi

    if [ -z "$entries" ]; then
        echo -e "  ${YELLOW}暂无概览条目${NC}"
        echo ""
        return
    fi

    while IFS= read -r line; do
        [ -z "$line" ] && continue
        echo -e "  ${CYAN}$line${NC}"
    done << EOF
$entries
EOF
    echo ""
}

get_file_mtime() {
    local file="$1"
    local epoch=""
    epoch=$(stat -f %m "$file" 2>/dev/null || stat -c %Y "$file" 2>/dev/null || echo "")
    if [ -n "$epoch" ]; then
        date -r "$epoch" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date -d "@$epoch" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || echo "N/A"
    else
        echo "N/A"
    fi
}

get_file_epoch() {
    local file="$1"
    stat -c %Y "$file" 2>/dev/null || stat -f %m "$file" 2>/dev/null || echo "0"
}

show_memory_details() {
    echo -e "${BOLD}${BLUE}━━━━━━ 记忆详情 ━━━━━━${NC}"
    echo ""

    get_memory_stats
    echo ""

    echo -e "${BOLD}最近 7 天的记忆:${NC}"
    local recent_memories=$(find memory -name "mem_*.md" -type f -mtime -7 2>/dev/null | sort -r)

    if [ -n "$recent_memories" ]; then
        for memory in $recent_memories; do
            local filename=$(basename "$memory")
            local mod_date=$(get_file_mtime "$memory")
            echo -e "  ${CYAN}$filename${NC} ${YELLOW}($mod_date)${NC}"
        done
    else
        echo -e "  ${YELLOW}没有最近 7 天的记忆${NC}"
    fi
    echo ""

    show_overview_preview
}

show_memory_update_hint() {
    echo -e "${BOLD}${BLUE}━━━━━━ 记忆更新提示 ━━━━━━${NC}"
    echo ""

    local latest_memory=""
    local latest_timestamp=0
    if [ -d "memory" ]; then
        while IFS= read -r mem_file; do
            [ -z "$mem_file" ] && continue
            local mem_timestamp
            mem_timestamp=$(get_file_epoch "$mem_file")
            if [ "${mem_timestamp:-0}" -gt "$latest_timestamp" ]; then
                latest_timestamp="$mem_timestamp"
                latest_memory="$mem_file"
            fi
        done << EOF
$(find memory -name "mem_*.md" -type f 2>/dev/null)
EOF
    fi

    local current_timestamp=$(date +%s)
    local time_diff=$((current_timestamp - latest_timestamp))
    local hours_ago=$((time_diff / 3600))

    if [ -n "$latest_memory" ]; then
        local latest_date=$(get_file_mtime "$latest_memory")
        local latest_filename=$(basename "$latest_memory")

        echo -e "${BOLD}最新记忆:${NC}"
        echo -e "  文件：${CYAN}$latest_filename${NC}"
        echo -e "  时间：${YELLOW}$latest_date${NC}"
        echo -e "  距离现在：${YELLOW}${hours_ago} 小时前${NC}"
        echo ""

        if command -v git >/dev/null 2>&1 && git rev-parse --git-dir >/dev/null 2>&1; then
            local git_changes_since_last_memory=""
            git_changes_since_last_memory=$(git log --since="$latest_date" --oneline 2>/dev/null | wc -l | tr -d ' ')

            if [ "$git_changes_since_last_memory" -gt 0 ]; then
                echo -e "${BOLD}Git 变更（自最新记忆）:${NC}"
                echo -e "  ${YELLOW}发现 $git_changes_since_last_memory 个提交${NC}"
                echo ""
                echo -e "${YELLOW}💡 提示：有代码变更但未记录记忆，建议添加记忆！${NC}"
                echo -e "  使用 ${CYAN}./memory_add.sh${NC} 添加记忆"
            else
                echo -e "${GREEN}✓ Git 状态：无新变更${NC}"
            fi
        fi
    else
        echo -e "${YELLOW}⚠ 警告：未找到记忆文件${NC}"
        echo -e "  使用 ${CYAN}./memory_add.sh${NC} 创建第一个记忆"
    fi

    echo ""
}
