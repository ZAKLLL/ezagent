#!/bin/bash

# 操作提示函数库

show_help() {
    echo "用法：agent_stats.sh [选项]"
    echo ""
    echo "选项:"
    echo "  (无参数)      - 显示完整状态面板"
    echo "  --json        - 输出 JSON 格式数据"
    echo "  --env         - 只显示环境信息"
    echo "  --memory      - 只显示记忆信息"
    echo "  --platform    - 只显示平台信息"
    echo "  --help        - 显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  ./agent_stats.sh              - 显示完整状态面板"
    echo "  ./agent_stats.sh --json       - 输出 JSON 格式"
    echo "  ./agent_stats.sh --env        - 只显示环境信息"
    echo ""
}

sync_skills_symlinks() {
    local skills_src="${SCRIPT_DIR}/.agents/skills"
    local skills_dst="${HOME}/.claude/skills"
    local added=()

    mkdir -p "$skills_dst"

    for skill_path in "$skills_src"/*/; do
        [[ -d "$skill_path" ]] || continue
        local skill_name
        skill_name=$(basename "$skill_path")
        local link="$skills_dst/$skill_name"
        if [[ ! -L "$link" ]] || [[ "$(readlink "$link")" != "$skill_path" ]]; then
            ln -sf "$skill_path" "$link"
            added+=("$skill_name")
        fi
    done

    if [[ ${#added[@]} -gt 0 ]]; then
        echo -e "${GREEN}✓${NC} Skills 软链接已更新: ${added[*]}"
    fi
}

show_actions() {
    echo ""
    echo -e "${BOLD}${BLUE}━━━━━━ 可用操作 ━━━━━━${NC}"
    echo ""
    echo -e "记忆管理:"
    echo -e "  ${CYAN}./memory_add.sh${NC}          - 添加记忆"
    echo -e "  ${CYAN}./memory_search.sh [关键词]${NC} - 搜索记忆"
    echo -e "  ${CYAN}./memory_search.sh -r 7${NC} - 查看最近 7 天"
    echo ""
    echo -e "Git 操作:"
    echo -e "  ${CYAN}git add .${NC}                 - 添加所有更改"
    echo -e "  ${CYAN}git commit${NC}                - 提交（格式：类型: 描述）"
    echo -e "  ${CYAN}git push${NC}                  - 推送到远程"
    echo -e "  ${CYAN}git pull${NC}                  - 拉取远程更新"
    echo ""
}
