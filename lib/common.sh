#!/bin/bash

# 通用函数库 - 颜色和基础工具

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ==================== 基础工具函数 ====================

count_files() {
    local dir=$1
    if [ -d "$dir" ]; then
        find "$dir" -type f 2>/dev/null | wc -l | tr -d ' '
    else
        echo "0"
    fi
}

get_latest_file() {
    local dir=$1
    if [ -d "$dir" ]; then
        local latest=$(find "$dir" -type f -name "mem_*.md" 2>/dev/null | sort -r | head -1)
        if [ -n "$latest" ]; then
            basename "$latest"
        fi
    fi
}

get_file_date() {
    local file=$1
    if [ -f "$file" ]; then
        stat -c %y "$file" 2>/dev/null | cut -d' ' -f1 | sed 's/-/ /g'
    fi
}