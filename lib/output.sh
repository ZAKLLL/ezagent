#!/bin/bash

# 输出格式化函数库

output_agent_context() {
    echo "EZAGENT_CONTEXT_START"
    echo "WORKING_DIR: $(pwd)"
    echo "TIMESTAMP: $(date -Iseconds)"
    echo "EZAGENT_CONTEXT_END"
}

output_json() {
    _count_memory_files() {
        if [ -d "memory" ]; then
            find memory -name "mem_*.md" -type f 2>/dev/null | wc -l | tr -d ' '
        else
            echo "0"
        fi
    }

    _json_escape() {
        printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
    }

    _overview_entries_json() {
        local overview_file="memory/overview.md"
        local lines=""

        if [ -f "$overview_file" ]; then
            lines=$(grep '^- ' "$overview_file" 2>/dev/null | tail -3)
        fi

        if [ -z "$lines" ]; then
            echo "[]"
            return
        fi

        local first=1
        printf '['
        while IFS= read -r line; do
            [ -z "$line" ] && continue

            local date_part env_part type_part title_part topic_part source_part detail_part
            date_part=$(printf '%s\n' "$line" | sed -E 's/^- ([0-9]{4}-[0-9]{2}-[0-9]{2}) \| .*/\1/')
            type_part=$(printf '%s\n' "$line" | sed -E 's/^- [0-9-]+ \| \[[^]]+\]\[([^]]+)\].*/\1/')
            title_part=$(printf '%s\n' "$line" | sed -E 's/^- [0-9-]+ \| \[[^]]+\]\[[^]]+\] (.*) \| 主题: .*/\1/')
            topic_part=$(printf '%s\n' "$line" | sed -E 's/^.* \| 主题: ([^|]+) \| 来源: .*/\1/' | sed 's/[[:space:]]*$//')
            source_part=$(printf '%s\n' "$line" | sed -E 's/^.* \| 来源: ([^|]+) \| 详情: .*/\1/' | sed 's/[[:space:]]*$//')
            detail_part=$(printf '%s\n' "$line" | sed -E 's/^.* \| 详情: ([^|]+)$/\1/' | sed 's/[[:space:]]*$//')

            [ $first -eq 0 ] && printf ','
            first=0
            printf '{"date":"%s","type":"%s","title":"%s","topic":"%s","source":"%s","detail":"%s","line":"%s"}' \
                "$(_json_escape "$date_part")" \
                "$(_json_escape "$type_part")" \
                "$(_json_escape "$title_part")" \
                "$(_json_escape "$topic_part")" \
                "$(_json_escape "$source_part")" \
                "$(_json_escape "$detail_part")" \
                "$(_json_escape "$line")"
        done << EOF
$lines
EOF
        printf ']'
    }

    _cpu_usage_json() {
        if [ "$(uname)" = "Darwin" ]; then
            local idle
            idle=$(top -l 1 -n 0 2>/dev/null | awk -F'[:,% ]+' '/CPU usage/{print $7; exit}')
            [ -n "$idle" ] && awk -v idle="$idle" 'BEGIN { printf "%.0f", 100 - idle }' && return 0
        else
            local used
            used=$(top -bn1 2>/dev/null | awk -F'[:, ]+' '/Cpu\(s\)/{print $2; exit}')
            [ -n "$used" ] && awk -v used="$used" 'BEGIN { printf "%.0f", used }' && return 0
        fi
        echo "0"
    }

    _memory_info_json() {
        if [ "$(uname)" = "Darwin" ]; then
            local total_bytes page_size pages_free pages_inactive pages_speculative
            total_bytes=$(sysctl -n hw.memsize 2>/dev/null)
            page_size=$(vm_stat 2>/dev/null | awk '/page size of/{gsub(/\./, "", $8); print $8; exit}')
            pages_free=$(vm_stat 2>/dev/null | awk '/Pages free/{gsub(/\./, "", $3); print $3; exit}')
            pages_inactive=$(vm_stat 2>/dev/null | awk '/Pages inactive/{gsub(/\./, "", $3); print $3; exit}')
            pages_speculative=$(vm_stat 2>/dev/null | awk '/Pages speculative/{gsub(/\./, "", $3); print $3; exit}')

            if [ -n "$total_bytes" ] && [ -n "$page_size" ] && [ -n "$pages_free" ] && [ -n "$pages_inactive" ] && [ -n "$pages_speculative" ]; then
                awk -v total="$total_bytes" -v size="$page_size" -v free="$pages_free" -v inactive="$pages_inactive" -v spec="$pages_speculative" '
                    BEGIN {
                        total_gib = total / 1024 / 1024 / 1024;
                        free_gib = (free + inactive + spec) * size / 1024 / 1024 / 1024;
                        used_gib = total_gib - free_gib;
                        if (used_gib < 0) used_gib = 0;
                        printf "%.0fGi/%.0fGi", used_gib, total_gib;
                    }'
                return 0
            fi
        else
            free -h 2>/dev/null | awk '/^Mem:/{print $3 "/" $2; exit}' && return 0
        fi
        echo "N/A"
    }

    _memory_pct_json() {
        if [ "$(uname)" = "Darwin" ]; then
            local total_bytes page_size pages_free pages_inactive pages_speculative
            total_bytes=$(sysctl -n hw.memsize 2>/dev/null)
            page_size=$(vm_stat 2>/dev/null | awk '/page size of/{gsub(/\./, "", $8); print $8; exit}')
            pages_free=$(vm_stat 2>/dev/null | awk '/Pages free/{gsub(/\./, "", $3); print $3; exit}')
            pages_inactive=$(vm_stat 2>/dev/null | awk '/Pages inactive/{gsub(/\./, "", $3); print $3; exit}')
            pages_speculative=$(vm_stat 2>/dev/null | awk '/Pages speculative/{gsub(/\./, "", $3); print $3; exit}')

            if [ -n "$total_bytes" ] && [ -n "$page_size" ] && [ -n "$pages_free" ] && [ -n "$pages_inactive" ] && [ -n "$pages_speculative" ]; then
                awk -v total="$total_bytes" -v size="$page_size" -v free="$pages_free" -v inactive="$pages_inactive" -v spec="$pages_speculative" '
                    BEGIN {
                        free_bytes = (free + inactive + spec) * size;
                        used_pct = ((total - free_bytes) / total) * 100;
                        if (used_pct < 0) used_pct = 0;
                        if (used_pct > 100) used_pct = 100;
                        printf "%.0f", used_pct;
                    }'
                return 0
            fi
        else
            free 2>/dev/null | awk '/^Mem:/{printf "%.0f", $3/$2*100; exit}' && return 0
        fi
        echo "0"
    }

    local scripts_count=$(count_files "scripts")
    local notes_count=$(count_files "notes")
    local bookmarks_count=$(count_files "work/bookmarks")
    local memory_count=$(_count_memory_files)

    local root_script_count=$(find . -maxdepth 1 -type f -name "*.sh" 2>/dev/null | wc -l | tr -d ' ')
    local docs_file_count=$(find docs -type f 2>/dev/null | wc -l | tr -d ' ')
    local readme_count=$(find . -type f \( -name "README.md" -o -name "AGENTS.md" \) -not -path "./.git/*" 2>/dev/null | wc -l | tr -d ' ')
    local skill_count=$(find .agents/skills -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
    local interview_count=$(find work/interview -mindepth 1 -maxdepth 1 -type d ! -name "_template" 2>/dev/null | wc -l | tr -d ' ')
    local document_count=$(find work/documents -type f 2>/dev/null | wc -l | tr -d ' ')

    local git_changes=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    local hooks_path=$(git config --get core.hooksPath 2>/dev/null)
    local hooks_ready="false"
    [ "$hooks_path" = ".githooks" ] && hooks_ready="true"

    local system_name="Linux"
    if [ "$(uname)" = "Darwin" ]; then
        system_name="macOS"
    elif [ -f /etc/os-release ]; then
        system_name=$(awk -F= '/^NAME=/{gsub(/"/, "", $2); print $2; exit}' /etc/os-release)
    fi

    local system_arch=$(detect_arch)
    local cpu_pct=$(_cpu_usage_json)
    local memory_info=$(_memory_info_json)
    local memory_pct=$(_memory_pct_json)
    local disk_info=$(df -h . 2>/dev/null | tail -1 | awk '{print $3 "/" $2}')
    local disk_pct=$(df . 2>/dev/null | tail -1 | awk '{gsub(/%/, "", $5); print $5}')
    local overview_json=$(_overview_entries_json)

    cat << EOF
{
  "environment": {
    "type": "unified"
  },
  "content": {
    "scripts": $scripts_count,
    "notes": $notes_count,
    "bookmarks": $bookmarks_count,
    "memory": $memory_count
  },
  "memory_totals": {
    "total": $memory_count
  },
  "memory_overview": $overview_json,
  "repo_assets": {
    "root_scripts": $root_script_count,
    "docs_files": $docs_file_count,
    "readmes": $readme_count,
    "skills": $skill_count,
    "documents": $document_count,
    "interviews": $interview_count
  },
  "repo_health": {
    "git_changes": $git_changes,
    "hooks_path": "$hooks_path",
    "hooks_ready": $hooks_ready
  },
  "capabilities": {
    "memory_system": true,
    "git_sync": true,
    "interview_workspace": true
  },
  "system_info": {
    "os": "$system_name",
    "arch": "$system_arch",
    "cpu_pct": $cpu_pct,
    "memory_info": "$memory_info",
    "memory_pct": $memory_pct,
    "disk_info": "$disk_info",
    "disk_pct": $disk_pct
  }
}
EOF
}
