#!/bin/bash

# 记忆添加脚本

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

NON_INTERACTIVE=0
AUTO_STAGE=0
CONTENT_ARG=""
CONTENT_FILE=""
ENTRY_TITLE=""
ENTRY_MARKER=""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

while [ $# -gt 0 ]; do
    case "$1" in
        --non-interactive)
            NON_INTERACTIVE=1
            ;;
        --stage)
            AUTO_STAGE=1
            ;;
        --content)
            shift
            CONTENT_ARG="${1:-}"
            ;;
        --content-file)
            shift
            CONTENT_FILE="${1:-}"
            ;;
        --title)
            shift
            ENTRY_TITLE="${1:-}"
            ;;
        --marker)
            shift
            ENTRY_MARKER="${1:-}"
            ;;
        *)
            echo -e "${RED}错误: 未知参数 $1${NC}"
            exit 1
            ;;
    esac
    shift
done

resolve_current_env() {
    echo "main"
}

trim_text() {
    echo "$1" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

extract_commit_type() {
    local text="$1"
    local type
    type=$(printf '%s\n' "$text" | sed -En 's/^\[[^]]*\][[:space:]]*([a-zA-Z0-9_-]+):.*/\1/p' | head -1)
    if [ -n "$type" ]; then
        echo "$type"
    else
        echo "note"
    fi
}

extract_summary_title() {
    local text="$1"
    local first_line summary
    first_line=$(printf '%s\n' "$text" | sed '/^[[:space:]]*$/d' | head -1)
    summary=$(printf '%s\n' "$first_line" | sed -E 's/^\[[^]]*\][[:space:]]*[a-zA-Z0-9_-]+:[[:space:]]*//')
    summary=$(trim_text "$summary")
    if [ -z "$summary" ]; then
        summary=$(trim_text "$ENTRY_TITLE")
    fi
    if [ -z "$summary" ]; then
        summary="记忆更新"
    fi
    echo "$summary"
}

extract_topic() {
    local haystack
    haystack=$(printf '%s %s\n' "$ENTRY_TITLE" "$CONTENT" | tr '[:upper:]' '[:lower:]')
    case "$haystack" in
        *面试*|*应聘*|*jd*|*resume*|*简历*) echo "面试";;
        *stats*|*状态面板*) echo "状态";;
        *memory*|*记忆*|*overview*|*概览*) echo "记忆系统";;
        *provider*|*llm*|*模型*|*openai*|*anthropic*|*deepseek*) echo "LLM";;
        *readme*|*docs*|*文档*|*claude.md*|*agents.md*) echo "文档";;
        *周报*|*weekly*|*okr*) echo "周报/OKR";;
        *git*|*hook*|*commit*) echo "Git";;
        *project*|*项目*) echo "项目";;
        *) echo "其他";;
    esac
}

extract_source() {
    if [ -n "$ENTRY_MARKER" ]; then
        echo "commit-msg"
    elif [ "$NON_INTERACTIVE" -eq 1 ]; then
        echo "hook-summary"
    else
        echo "manual-memory"
    fi
}

append_overview_entry() {
    local overview_file="$1"
    local monthly_file="$2"
    local detail_file="$3"
    local summary_title="$4"
    local summary_type="$5"
    local summary_topic="$6"
    local summary_source="$7"
    local summary_marker="$8"
    local entry_line="- $DATE_FORMATTED | [$summary_type] $summary_title | 主题: $summary_topic | 来源: $summary_source | 详情: $(basename "$detail_file")"

    if [ -n "$summary_marker" ]; then
        if [ -f "$overview_file" ] && grep -Fq "$summary_marker" "$overview_file"; then
            return 0
        fi
        if [ -f "$monthly_file" ] && grep -Fq "$summary_marker" "$monthly_file"; then
            return 0
        fi
    fi

    if [ ! -f "$overview_file" ]; then
        cat > "$overview_file" << EOF
# 记忆概览

## 最近事件

EOF
    fi

    {
        echo "$entry_line"
        if [ -n "$summary_marker" ]; then
            echo "$summary_marker"
        fi
    } >> "$overview_file"

    local tmp_overview
    tmp_overview=$(mktemp)
    awk '
        /^# 记忆概览/ { print; next }
        /^## 最近事件/ { print; next }
        /^- / || /^<!-- commit-msg:/ { recent[++n]=$0; next }
        { rest[++m]=$0 }
        END {
            start = n - 99
            if (start < 1) start = 1
            for (i=start; i<=n; i++) print recent[i]
            for (i=1; i<=m; i++) print rest[i]
        }
    ' "$overview_file" > "$tmp_overview"
    mv "$tmp_overview" "$overview_file"

    if [ ! -f "$monthly_file" ]; then
        cat > "$monthly_file" << EOF
# ${DATE_FORMATTED%-%d} 记忆概览

## $DATE_FORMATTED

EOF
    elif ! grep -Fq "## $DATE_FORMATTED" "$monthly_file"; then
        printf "\n## %s\n\n" "$DATE_FORMATTED" >> "$monthly_file"
    fi

    {
        echo "$entry_line"
        if [ -n "$summary_marker" ]; then
            echo "$summary_marker"
        fi
    } >> "$monthly_file"
}

CURRENT_ENV="$(resolve_current_env)"

# 获取今天的日期
TODAY=$(date +%Y_%m_%d)
DATE_FORMATTED=$(date +%Y-%m-%d)
MONTH_FORMATTED=$(date +%Y_%m)
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# 确定记忆目录
MEMORY_DIR="memory"

# 检查目录是否存在
if [ ! -d "$MEMORY_DIR" ]; then
    mkdir -p "$MEMORY_DIR"
fi

# 记忆文件
MEMORY_FILE="$MEMORY_DIR/mem_$TODAY.md"
OVERVIEW_FILE="$MEMORY_DIR/overview.md"
MONTHLY_OVERVIEW_FILE="$MEMORY_DIR/overview_$MONTH_FORMATTED.md"

# 显示信息
echo -e "${BLUE}━━━━━━ 添加记忆 ━━━━━━${NC}"
echo ""
echo "环境: $CURRENT_ENV"
echo "日期: $DATE_FORMATTED"
echo "文件: $MEMORY_FILE"
echo ""

# 检查文件是否存在
if [ -f "$MEMORY_FILE" ]; then
    echo -e "${YELLOW}今天的记忆文件已存在${NC}"
    echo ""
    if [ "$NON_INTERACTIVE" -eq 1 ]; then
        echo -e "${GREEN}非交互模式: 追加到现有记忆文件${NC}"
    else
        read -p "是追加到现有记忆还是新建？(a/new): " choice
        echo ""

        if [ "$choice" = "new" ]; then
            TODAY_NEW=$(date +%Y_%m_%d_%H_%M_%S)
            MEMORY_FILE="$MEMORY_DIR/mem_$TODAY_NEW.md"
            echo -e "${GREEN}创建新记忆文件: $MEMORY_FILE${NC}"
        else
            echo -e "${GREEN}追加到现有记忆文件${NC}"
        fi
    fi
else
    echo -e "${GREEN}创建新记忆文件${NC}"
fi

CONTENT=""
if [ -n "$CONTENT_FILE" ]; then
    if [ ! -f "$CONTENT_FILE" ]; then
        echo -e "${RED}错误: 内容文件不存在: $CONTENT_FILE${NC}"
        exit 1
    fi
    CONTENT="$(cat "$CONTENT_FILE")"
elif [ -n "$CONTENT_ARG" ]; then
    CONTENT="$CONTENT_ARG"
else
    echo ""
    echo "输入记忆内容（按 Ctrl+D 结束输入）："
    echo ""

    while IFS= read -r line; do
        CONTENT+="$line"$'\n'
    done
fi

if [ -z "$CONTENT" ]; then
    echo -e "${RED}错误: 记忆内容不能为空${NC}"
    exit 1
fi

SUMMARY_TYPE=$(extract_commit_type "$CONTENT")
SUMMARY_TITLE=$(extract_summary_title "$CONTENT")
SUMMARY_TOPIC=$(extract_topic)
SUMMARY_SOURCE=$(extract_source)

if [ -n "$ENTRY_MARKER" ] && [ -f "$MEMORY_FILE" ] && grep -Fq "$ENTRY_MARKER" "$MEMORY_FILE"; then
    echo -e "${YELLOW}提示: 相同标记的记忆已存在，跳过写入${NC}"
    exit 0
fi

# 写入文件
if [ ! -f "$MEMORY_FILE" ]; then
    cat > "$MEMORY_FILE" << EOF
# 记忆日期: $DATE_FORMATTED

## 环境上下文
- 当前环境: $CURRENT_ENV
- 主要任务: 待定
- 相关项目: 待定

## 记忆内容

$CONTENT

${ENTRY_MARKER}

---
*Created at: $TIMESTAMP*
*Environment: $CURRENT_ENV*
*AI Agent: EzAgent*
EOF
else
    echo "" >> "$MEMORY_FILE"
    if [ -n "$ENTRY_TITLE" ]; then
        echo "## $ENTRY_TITLE" >> "$MEMORY_FILE"
    else
        echo "## 记忆内容 ($TIMESTAMP)" >> "$MEMORY_FILE"
    fi
    echo "" >> "$MEMORY_FILE"
    echo "$CONTENT" >> "$MEMORY_FILE"
    if [ -n "$ENTRY_MARKER" ]; then
        echo "" >> "$MEMORY_FILE"
        echo "$ENTRY_MARKER" >> "$MEMORY_FILE"
    fi
fi

echo ""
echo -e "${GREEN}✓ 记忆已保存到: $MEMORY_FILE${NC}"
echo ""

append_overview_entry \
    "$OVERVIEW_FILE" \
    "$MONTHLY_OVERVIEW_FILE" \
    "$MEMORY_FILE" \
    "$SUMMARY_TITLE" \
    "$SUMMARY_TYPE" \
    "$SUMMARY_TOPIC" \
    "$SUMMARY_SOURCE" \
    "$ENTRY_MARKER"

echo -e "${GREEN}✓ 记忆概览已更新: $OVERVIEW_FILE${NC}"
echo -e "${GREEN}✓ 月度概览已更新: $MONTHLY_OVERVIEW_FILE${NC}"
echo ""

if [ "$AUTO_STAGE" -eq 1 ]; then
    cd "$SCRIPT_DIR"
    git add -f "$MEMORY_FILE"
    git add -f "$OVERVIEW_FILE" "$MONTHLY_OVERVIEW_FILE"
    echo -e "${GREEN}✓ 已加入暂存区: $MEMORY_FILE${NC}"
    echo -e "${GREEN}✓ 已加入暂存区: $OVERVIEW_FILE, $MONTHLY_OVERVIEW_FILE${NC}"
fi

if [ "$NON_INTERACTIVE" -eq 0 ]; then
    read -p "是否提交到 Git？(y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cd "$SCRIPT_DIR"
        git add "$MEMORY_FILE" "$OVERVIEW_FILE" "$MONTHLY_OVERVIEW_FILE"
        git commit -m "feat: 添加记忆 ($DATE_FORMATTED)"
        echo -e "${GREEN}✓ 已提交到 Git${NC}"
    fi
fi
