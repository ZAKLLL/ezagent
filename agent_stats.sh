#!/bin/bash

# 数字分身状态统计脚本 - 主入口
# 所有功能模块拆分到 lib/ 目录中
#
# 用法:
#   ./agent_stats.sh          - 显示完整状态面板
#   ./agent_stats.sh --json   - JSON 格式输出
#   ./agent_stats.sh --env    - 只显示环境信息
#   ./agent_stats.sh --memory - 只显示记忆信息
#   ./agent_stats.sh --platform - 只显示平台信息
#   ./agent_stats.sh --help   - 显示帮助

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 按依赖顺序加载所有模块
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/platform_info.sh"
source "$SCRIPT_DIR/lib/content_info.sh"
source "$SCRIPT_DIR/lib/memory_info.sh"
source "$SCRIPT_DIR/lib/output.sh"
source "$SCRIPT_DIR/lib/actions.sh"

main() {
    # 自动同步 skills 软链接
    sync_skills_symlinks

    case "${1:-}" in
        --json)
            output_json
            ;;
        --env)
            show_env_info
            show_content_stats
            ;;
        --memory)
            show_memory_details
            show_memory_update_hint
            ;;
        --platform)
            show_platform_info
            show_system_info
            ;;
        --help|-h)
            show_help
            ;;
        "")
            # 默认：显示完整状态面板
            clear 2>/dev/null || true
            echo ""
            echo -e "${BOLD}${CYAN}╔════════════════════════════════════════╗${NC}"
            echo -e "${BOLD}${CYAN}║      EzAgent - 数字分身状态面板         ║${NC}"
            echo -e "${BOLD}${CYAN}╚════════════════════════════════════════╝${NC}"
            echo ""

            show_env_info
            show_content_stats
            show_memory_details
            show_memory_update_hint
            show_system_info
            show_actions

            echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo ""
            ;;
        *)
            echo -e "${RED}未知选项：$1${NC}" >&2
            show_help
            exit 1
            ;;
    esac
}

main "$@"
