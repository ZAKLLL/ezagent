#!/bin/bash

# 记忆搜索脚本

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

MEMORY_DIR="memory"

# 检查搜索工具
if command -v rg >/dev/null 2>&1; then
    SEARCH_CMD="rg"
    SEARCH_OPTS="-i"
elif command -v grep >/dev/null 2>&1; then
    SEARCH_CMD="grep"
    SEARCH_OPTS="-ri --include=mem_*.md"
else
    echo -e "${RED}错误: 未找到搜索工具 (rg 或 grep)${NC}"
    exit 1
fi

# 显示帮助
show_help() {
    echo "记忆搜索工具"
    echo ""
    echo "用法: $0 [选项] [关键词]"
    echo ""
    echo "选项:"
    echo "  -d, --date DATE    搜索特定日期 (格式: YYYY_MM_DD)"
    echo "  -t, --tag TAG      搜索特定标签"
    echo "  -r, --recent N     搜索最近 N 天的记忆"
    echo "  -h, --help         显示帮助"
    echo ""
    echo "示例:"
    echo "  $0 项目决策"
    echo "  $0 -d 2026_03_06"
    echo "  $0 -t #project"
    echo "  $0 -r 7"
}

# 搜索记忆
search_memory() {
    local keyword=$1
    local date=$2
    local tag=$3

    echo -e "${BLUE}━━━━━━ 搜索记忆 ━━━━━━${NC}"
    echo ""
    echo "关键词: $keyword"
    echo "搜索范围: $MEMORY_DIR"
    echo ""

    local found=false
    local results

    if [ -n "$keyword" ]; then
        results=$($SEARCH_CMD $SEARCH_OPTS "$keyword" "$MEMORY_DIR" 2>/dev/null | head -10)
    elif [ -n "$tag" ]; then
        results=$($SEARCH_CMD $SEARCH_OPTS "$tag" "$MEMORY_DIR" 2>/dev/null | head -10)
    elif [ -n "$date" ]; then
        results=$(cat "$MEMORY_DIR/mem_$date.md" 2>/dev/null | head -10)
    fi

    if [ -n "$results" ]; then
        echo -e "${GREEN}在 $MEMORY_DIR 中找到:${NC}"
        echo "$results"
        echo ""
        found=true
    fi

    if [ "$found" = "false" ]; then
        echo -e "${YELLOW}未找到匹配的记忆${NC}"
    else
        echo -e "${GREEN}✓ 搜索完成${NC}"
    fi
}

# 显示最近的记忆
show_recent() {
    local days=${1:-7}

    echo -e "${BLUE}━━━━━━ 最近 $days 天的记忆 ━━━━━━${NC}"
    echo ""

    local found=false
    local recent_files
    recent_files=$(find "$MEMORY_DIR" -maxdepth 1 -name "mem_*.md" -type f -mtime -$days 2>/dev/null | sort -r)

    if [ -n "$recent_files" ]; then
        found=true
        for file in $recent_files; do
            local filename=$(basename "$file")

            echo -e "${GREEN}$filename${NC}"
            echo ""

            # 显示前20行
            head -n 20 "$file"
            echo ""
            echo "---"
            echo ""
        done
    fi

    if [ "$found" = "false" ]; then
        echo -e "${YELLOW}没有找到最近 $days 天的记忆${NC}"
    fi
}

# 解析参数
KEYWORD=""
DATE=""
TAG=""
RECENT=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--date)
            DATE="$2"
            shift 2
            ;;
        -t|--tag)
            TAG="$2"
            shift 2
            ;;
        -r|--recent)
            RECENT="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            KEYWORD="$1"
            shift
            ;;
    esac
done

# 处理命令
if [ -n "$RECENT" ]; then
    show_recent "$RECENT"
elif [ -n "$KEYWORD" ] || [ -n "$DATE" ] || [ -n "$TAG" ]; then
    search_memory "$KEYWORD" "$DATE" "$TAG"
else
    # 默认显示最近的记忆
    show_recent 7
fi
