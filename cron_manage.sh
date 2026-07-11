#!/bin/bash

# Cron 任务管理脚本

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/cron"
SHARED_DIR="$SCRIPT_DIR/cron"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

get_config_file() {
    echo "$CONFIG_DIR/config.json"
}

get_all_registered_jobs() {
    local config_file=$(get_config_file)
    local registered_file="$SHARED_DIR/registered.json"

    if [ ! -f "$registered_file" ]; then
        echo '{"jobs": []}' > "$registered_file"
    fi

    jq -s '.[0].jobs + (.[1].jobs // []) | unique_by(.name)' "$config_file" "$registered_file" 2>/dev/null || jq '.jobs' "$registered_file"
}

register_job() {
    local job_name=$1
    local config_file="$CONFIG_DIR/config.json"

    local job_info=$(jq -r --arg name "$job_name" '.jobs[] | select(.name == $name)' "$config_file" 2>/dev/null)
    if [ -z "$job_info" ]; then
        echo -e "${RED}错误: 任务 '$job_name' 不存在${NC}"
        return 1
    fi

    local cron_expr=$(echo "$job_info" | jq -r '.cron_expr')
    local script_name=$(echo "$job_info" | jq -r '.script')
    local description=$(echo "$job_info" | jq -r '.description')

    local script_path="$CONFIG_DIR/jobs/$script_name"

    if [ ! -f "$script_path" ]; then
        script_path="$SHARED_DIR/jobs/$script_name"
    fi

    if [ ! -f "$script_path" ]; then
        echo -e "${RED}错误: 脚本不存在: $script_path${NC}"
        return 1
    fi

    if crontab -l 2>/dev/null | grep -q "# ezagent: $job_name"; then
        echo -e "${YELLOW}任务 '$job_name' 已经注册${NC}"
        return 0
    fi

    local current_cron=$(crontab -l 2>/dev/null || echo "")
    local new_entry="$cron_expr $script_path # ezagent: $job_name"
    local new_cron="$current_cron
$new_entry"

    echo "$new_cron" | crontab -

    local registered_file="$SHARED_DIR/registered.json"
    local registered_job=$(cat << EOF
{
  "name": "$job_name",
  "script": "$script_name",
  "cron_expr": "$cron_expr",
  "description": "$description",
  "registered_at": "$(date +%Y-%m-%dT%H:%M:%S)",
  "registered_by": "main"
}
EOF
)

    jq --argjson job "$registered_job" '.jobs += [$job] | .jobs |= unique_by(.name)' "$registered_file" > "${registered_file}.tmp" && mv "${registered_file}.tmp" "$registered_file"

    echo -e "${GREEN}✓ 任务 '$job_name' 已注册到系统 cron${NC}"
    echo -e "${BLUE}  表达式: $cron_expr${NC}"
    echo -e "${BLUE}  脚本: $script_path${NC}"
}

unregister_job() {
    local job_name=$1

    if ! crontab -l 2>/dev/null | grep -q "# ezagent: $job_name"; then
        echo -e "${YELLOW}任务 '$job_name' 未注册${NC}"
        return 0
    fi

    crontab -l 2>/dev/null | grep -v "# ezagent: $job_name" | crontab -

    local registered_file="$SHARED_DIR/registered.json"
    jq --arg name "$job_name" '.jobs |= map(select(.name != $name))' "$registered_file" > "${registered_file}.tmp" && mv "${registered_file}.tmp" "$registered_file"

    echo -e "${GREEN}✓ 任务 '$job_name' 已从系统 cron 注销${NC}"
}

list_registered() {
    echo -e "${BLUE}系统已注册的 Cron 任务:${NC}"
    echo ""

    if ! crontab -l 2>/dev/null | grep -q "ezagent:"; then
        echo -e "${YELLOW}暂无已注册的任务${NC}"
        return
    fi

    crontab -l 2>/dev/null | grep "ezagent:" | while read -r line; do
        local job_name=$(echo "$line" | sed 's/.*# ezagent: //')
        local cron_expr=$(echo "$line" | awk '{print $1, $2, $3, $4, $5}')
        local script_path=$(echo "$line" | awk '{print substr($0, index($0, $6))}' | sed 's/ # ezagent:.*//')

        echo -e "${GREEN}📋 $job_name${NC}"
        echo -e "  表达式: $cron_expr"
        echo -e "  脚本: $script_path"
        echo ""
    done
}

list_available() {
    local config_file=$(get_config_file)

    echo -e "${BLUE}可用任务:${NC}"
    echo ""

    jq -r '.jobs[] | "\(.name)\t\(.script)\t\(.cron_expr)\t\(.enabled)\t\(.description)"' "$config_file" 2>/dev/null | while IFS=$'\t' read -r name script expr enabled desc; do
        local status=""
        if [ "$enabled" = "true" ]; then
            status="${GREEN}✓ 已启用${NC}"
        else
            status="${YELLOW}✗ 已禁用${NC}"
        fi

        local registered=""
        if crontab -l 2>/dev/null | grep -q "# ezagent: $name"; then
            registered=" ${BLUE}[已注册]${NC}"
        fi

        echo -e "${GREEN}📋 $name${NC}$registered"
        echo -e "  脚本: $script"
        echo -e "  表达式: $expr"
        echo -e "  说明: $desc"
        echo -e "  状态: $status"
        echo ""
    done
}

toggle_job() {
    local job_name=$1
    local config_file=$(get_config_file)

    if ! jq -e --arg name "$job_name" '.jobs[] | select(.name == $name)' "$config_file" >/dev/null 2>&1; then
        echo -e "${RED}错误: 任务 '$job_name' 不存在${NC}"
        return 1
    fi

    local current_enabled=$(jq -r --arg name "$job_name" '.jobs[] | select(.name == $name) | .enabled' "$config_file")
    local new_enabled="false"
    if [ "$current_enabled" = "false" ]; then
        new_enabled="true"
    fi

    jq --arg name "$job_name" --argjson enabled "$new_enabled" '(.jobs[] | select(.name == $name) | .enabled) = $enabled' "$config_file" > "${config_file}.tmp" && mv "${config_file}.tmp" "$config_file"

    if [ "$new_enabled" = "true" ]; then
        echo -e "${GREEN}✓ 任务 '$job_name' 已启用${NC}"
    else
        echo -e "${YELLOW}✗ 任务 '$job_name' 已禁用${NC}"
    fi

    if [ "$new_enabled" = "false" ] && crontab -l 2>/dev/null | grep -q "# ezagent: $job_name"; then
        echo ""
        echo -e "${YELLOW}任务已禁用但仍在系统 cron 中，是否注销? (y/n): ${NC}"
        read -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            unregister_job "$job_name"
        fi
    fi
}

sync_jobs() {
    local config_file=$(get_config_file)

    echo -e "${BLUE}同步启用任务到系统 cron...${NC}"
    echo ""

    jq -r '.jobs[] | select(.enabled == true) | .name' "$config_file" 2>/dev/null | while read -r job_name; do
        register_job "$job_name"
    done
}

show_help() {
    echo "Cron 任务管理工具"
    echo ""
    echo "用法: $0 [命令] [参数]"
    echo ""
    echo "命令:"
    echo "  list        列出所有可用任务"
    echo "  registered  列出系统已注册的任务"
    echo "  register <任务名>   注册任务到系统 cron"
    echo "  unregister <任务名> 从系统 cron 注销任务"
    echo "  toggle <任务名>     切换任务启用状态"
    echo "  sync        同步所有启用的任务到系统"
    echo "  help        显示帮助"
    echo ""
}

case "${1:-list}" in
    list)
        list_available
        ;;
    registered)
        list_registered
        ;;
    register)
        if [ -z "$2" ]; then
            echo -e "${RED}错误: 请指定任务名称${NC}"
            list_available
            exit 1
        fi
        register_job "$2"
        ;;
    unregister)
        if [ -z "$2" ]; then
            echo -e "${RED}错误: 请指定任务名称${NC}"
            exit 1
        fi
        unregister_job "$2"
        ;;
    toggle)
        if [ -z "$2" ]; then
            echo -e "${RED}错误: 请指定任务名称${NC}"
            exit 1
        fi
        toggle_job "$2"
        ;;
    sync)
        sync_jobs
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}未知命令: $1${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac
