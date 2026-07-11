#!/bin/bash

# 环境信息函数库

get_last_remote_commit() {
    local branch
    local commit_msg

    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ -z "$branch" ] || [ "$branch" = "HEAD" ]; then
        echo "无法获取分支"
        return
    fi

    if git remote | grep -q "origin"; then
        git fetch --quiet origin 2>/dev/null || true
        commit_msg=$(git log origin/$branch -1 --format="%h %s" 2>/dev/null)
        if [ -n "$commit_msg" ]; then
            echo "$commit_msg"
        else
            echo "无法获取远程 commit"
        fi
    else
        echo "无远程仓库"
    fi
}

show_env_info() {
    local last_remote_commit=$(get_last_remote_commit)

    echo -e "${BOLD}${BLUE}━━━━━━ 环境信息 ━━━━━━${NC}"
    echo ""
    echo -e "远程 Commit: ${PURPLE}$last_remote_commit${NC}"
    echo ""
}

show_content_stats() {
    echo -e "${BOLD}${BLUE}━━━━━━ 内容统计 ━━━━━━${NC}"
    echo ""

    local notes_count=$(count_files "notes")
    local bookmarks_count=$(count_files "work/bookmarks")
    local memory_count=$(count_files "memory")
    local memory_latest=$(get_latest_file "memory")

    echo -e "  笔记：   ${CYAN}$notes_count${NC}"
    echo -e "  书签：   ${CYAN}$bookmarks_count${NC}"
    echo -e "  记忆：   ${CYAN}$memory_count${NC} ${GREEN}($memory_latest)${NC}"
    echo ""
}
