#!/bin/bash

# 平台和系统信息函数库

# ==================== 平台检测函数 ====================

detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    elif [[ "$OSTYPE" == darwin* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == linux-gnu* ]]; then
        echo "linux"
    else
        echo "unknown"
    fi
}

detect_arch() {
    ARCH=$(uname -m)
    case $ARCH in
        x86_64) echo "x64" ;;
        i686|i386) echo "x86" ;;
        arm64|aarch64) echo "arm64" ;;
        *) echo "$ARCH" ;;
    esac
}

# ==================== 显示函数 ====================

show_platform_info() {
    echo ""
    echo -e "${BOLD}${BLUE}━━━━━━ 平台信息 ━━━━━━${NC}"
    echo ""

    local os_info=$(detect_os)
    local arch=$(detect_arch)

    echo -e "  操作系统：${CYAN}$os_info${NC}"
    echo -e "  架构：    ${CYAN}$arch${NC}"
    echo -e "  符号链接：${CYAN}支持${NC}"
    echo ""

    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo -e "  系统名称：${CYAN}$NAME${NC}"
        echo -e "  系统版本：${CYAN}$VERSION_ID${NC}"
        echo ""
    fi

    if [ "$os_info" = "macos" ]; then
        local mac_version=$(sw_vers -productVersion 2>/dev/null)
        echo -e "  macOS 版本：${CYAN}$mac_version${NC}"
        echo ""
    fi
}

show_system_info() {
    echo -e "${BOLD}${BLUE}━━━━━━ 系统信息 ━━━━━━${NC}"
    echo ""

    echo -e "${BOLD}运行环境:${NC}"

    local os_name="Unknown"
    local os_version="Unknown"
    local os_info=$(detect_os)

    if [ -f /etc/os-release ]; then
        source /etc/os-release
        os_name="$NAME"
        os_version="$VERSION_ID"
    elif [ "$os_info" = "macos" ]; then
        os_name="macOS"
        os_version=$(sw_vers -productVersion 2>/dev/null)
    elif [ "$os_info" = "linux" ]; then
        os_name="Linux"
        os_version=$(uname -r)
    else
        os_name="$os_info"
        os_version=$(uname -r)
    fi

    local arch=$(detect_arch)

    echo -e "  操作系统：${CYAN}$os_name${NC}"
    echo -e "  系统版本：${CYAN}$os_version${NC}"
    echo -e "  架构：${CYAN}$arch${NC}"
    echo -e "  符号链接：${CYAN}支持${NC}"

    echo ""
    echo -e "${BOLD}资源占用:${NC}"

    if [ "$(uname)" = "Darwin" ]; then
        local cpu_usage=$(top -l 1 -n 0 | grep "CPU usage" | awk '{print $3}' | cut -d'%' -f1)
        local mem_total=$(sysctl -n hw.memsize | awk '{printf "%.0f", $1/1024/1024/1024}')
        local mem_used=$(vm_stat | perl -ne '/page size of/ && do { $s=$2 } ; /Pages free/ && do { $f=$2 } ; /Pages active/ && do { $a=$2 } ; END { printf "%.0f", ($s*($a+$f)/1073741824) }')
        local disk_usage=$(df -h / | tail -1 | awk '{print $5}')
    else
        local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
        local mem_total=$(free -h | grep Mem | awk '{print $2}')
        local mem_used=$(free -h | grep Mem | awk '{print $3}')
        local disk_usage=$(df -h / | tail -1 | awk '{print $5}')
    fi

    echo -e "  CPU: ${YELLOW}~${cpu_usage}%${NC}"
    echo -e "  内存：${YELLOW}${mem_used}/${mem_total}${NC}"
    echo -e "  磁盘：${YELLOW}${disk_usage}${NC}"

    echo ""
    echo -e "${BOLD}脚本工具:${NC}"
    if command -v rg >/dev/null 2>&1; then
        echo -e "  ripgrep: ${GREEN}✓ 已安装${NC}"
    else
        echo -e "  ripgrep: ${RED}✗ 未安装${NC}"
    fi

    if command -v git >/dev/null 2>&1; then
        echo -e "  git: ${GREEN}✓ 已安装${NC}"
    else
        echo -e "  git: ${RED}✗ 未安装${NC}"
    fi

    if command -v git >/dev/null 2>&1; then
        local git_status=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
        if [ "$git_status" -eq 0 ]; then
            echo -e "  Git 状态：${GREEN}工作区干净${NC}"
        else
            echo -e "  Git 状态：${YELLOW}$git_status 个未提交文件${NC}"
        fi
    fi

    if [ -f ".git/config" ]; then
        local remote=$(git remote get-url origin 2>/dev/null)
        if [ -n "$remote" ]; then
            echo -e "  远程仓库：${CYAN}$remote${NC}"
        fi
    fi

    echo ""
}