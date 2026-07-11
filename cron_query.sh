#!/bin/bash

# Cron 任务查询脚本

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHARED_DIR="$SCRIPT_DIR/cron"
REGISTERED_FILE="$SHARED_DIR/registered.json"

output_json() {
    echo "$@"
}

get_all_registered() {
    if [ ! -f "$REGISTERED_FILE" ]; then
        output_json '{"jobs": [], "message": "暂无已注册的任务"}'
        return
    fi

    output_json "$(cat "$REGISTERED_FILE")"
}

get_job_info() {
    local job_name=$1

    if [ ! -f "$REGISTERED_FILE" ]; then
        output_json '{"error": "注册文件不存在"}'
        return 1
    fi

    local job_info=$(jq -r --arg name "$job_name" '.jobs[] | select(.name == $name)' "$REGISTERED_FILE" 2>/dev/null)

    if [ -z "$job_info" ]; then
        output_json "{\"error\": \"任务 '$job_name' 未找到\"}"
        return 1
    fi

    output_json "$job_info"
}

is_job_registered() {
    local job_name=$1

    if [ ! -f "$REGISTERED_FILE" ]; then
        echo "false"
        return
    fi

    local count=$(jq -r --arg name "$job_name" '[.jobs[] | select(.name == $name)] | length' "$REGISTERED_FILE" 2>/dev/null)
    if [ "$count" -gt 0 ]; then
        echo "true"
    else
        echo "false"
    fi
}

get_all_env_configs() {
    local result='{"main": [], "shared": []}'

    local config_file="$SCRIPT_DIR/config/cron/config.json"
    if [ -f "$config_file" ]; then
        local jobs=$(jq '.jobs' "$config_file" 2>/dev/null)
        result=$(jq --argjson jobs "$jobs" '.main = $jobs' <<< "$result")
    fi

    output_json "$result"
}

search_jobs() {
    local keyword=$1
    local result='{"main": [], "shared": []}'

    local config_file="$SCRIPT_DIR/config/cron/config.json"
    if [ -f "$config_file" ]; then
        local jobs=$(jq --arg kw "$keyword" '[.jobs[] | select(.name | ascii_downcase | contains($kw | ascii_downcase))]' "$config_file" 2>/dev/null)
        result=$(jq --argjson jobs "$jobs" '.main = $jobs' <<< "$result")
    fi

    output_json "$result"
}

show_help() {
    cat << 'EOF'
Cron 任务查询工具

用法: ./cron_query.sh [命令] [参数]

命令:
  all           获取所有已注册任务 (JSON)
  info <名称>   获取指定任务信息 (JSON)
  check <名称>  检查任务是否注册 (返回 true/false)
  envs          获取所有环境的任务配置 (JSON)
  search <关键词> 搜索任务 (JSON)
  help          显示帮助

示例:
  ./cron_query.sh all                    # 列出所有已注册任务
  ./cron_query.sh info daily_backup      # 查看任务详情
  ./cron_query.sh check daily_backup     # 检查是否已注册
  ./cron_query.sh search backup          # 搜索包含 backup 的任务
EOF
}

case "${1:-help}" in
    all)
        get_all_registered
        ;;
    info)
        if [ -z "$2" ]; then
            output_json '{"error": "请指定任务名称"}'
            exit 1
        fi
        get_job_info "$2"
        ;;
    check)
        if [ -z "$2" ]; then
            echo "false"
            exit 1
        fi
        is_job_registered "$2"
        ;;
    envs)
        get_all_env_configs
        ;;
    search)
        if [ -z "$2" ]; then
            output_json '{"error": "请指定搜索关键词"}'
            exit 1
        fi
        search_jobs "$2"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        output_json '{"error": "未知命令"}'
        show_help
        exit 1
        ;;
esac
