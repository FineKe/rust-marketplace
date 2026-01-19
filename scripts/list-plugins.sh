#!/usr/bin/env bash
# Claude Code Marketplace - 列出可用 Plugins
# 用法: ./scripts/list-plugins.sh [--installed|--available]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
MARKETPLACE_CONFIG="$PROJECT_ROOT/marketplace.yaml"

# 解析命令行参数
FILTER="all"
if [ "$1" = "--installed" ]; then
    FILTER="installed"
elif [ "$1" = "--available" ]; then
    FILTER="available"
fi

# 打印表头
print_header() {
    echo ""
    echo -e "${BOLD}${CYAN}========================================${NC}"
    echo -e "${BOLD}${CYAN}  Claude Code Plugin Marketplace${NC}"
    echo -e "${BOLD}${CYAN}========================================${NC}"
    echo ""
}

# 获取 marketplace 信息
get_marketplace_info() {
    local field="$1"
    grep "^  $field:" "$MARKETPLACE_CONFIG" | sed "s/^  $field: //" | sed 's/"//g'
}

# 列出所有 plugins
list_plugins() {
    local count=0
    local installed_count=0
    local available_count=0

    # 读取所有 plugin IDs
    local plugin_ids=$(grep "^  - id:" "$MARKETPLACE_CONFIG" | sed 's/^  - id: //')

    while IFS= read -r plugin_id; do
        if [ -z "$plugin_id" ]; then
            continue
        fi

        count=$((count + 1))

        # 提取 plugin 信息
        local plugin_info=$(awk -v id="$plugin_id" '
            BEGIN { in_plugin=0; name=""; desc=""; enabled=""; version=""; author="" }
            /^  - id:/ {
                if (in_plugin) {
                    print name "|" version "|" author "|" enabled "|" desc
                }
                in_plugin=0
                if ($3 == id) {
                    in_plugin=1
                    name=""; desc=""; enabled=""; version=""; author=""
                }
            }
            in_plugin && /^    name:/ {
                sub(/^    name: /, "")
                gsub(/"/, "")
                name=$0
            }
            in_plugin && /^    version:/ {
                sub(/^    version: /, "")
                gsub(/"/, "")
                version=$0
            }
            in_plugin && /^    author:/ {
                sub(/^    author: /, "")
                gsub(/"/, "")
                author=$0
            }
            in_plugin && /^    enabled:/ {
                sub(/^    enabled: /, "")
                enabled=$0
            }
            in_plugin && /^    description:/ {
                in_desc=1
                next
            }
            in_plugin && in_desc && /^      / {
                sub(/^      /, "")
                if (desc != "") desc = desc " "
                desc = desc $0
            }
            in_plugin && /^    [a-z]/ && !/^      / { in_desc=0 }
            END {
                if (in_plugin) {
                    print name "|" version "|" author "|" enabled "|" desc
                }
            }
        ' "$MARKETPLACE_CONFIG")

        IFS='|' read -r name version author enabled description <<< "$plugin_info"

        # 判断是否已安装
        local is_installed=false
        if [ "$enabled" = "true" ]; then
            is_installed=true
            installed_count=$((installed_count + 1))
        else
            available_count=$((available_count + 1))
        fi

        # 根据过滤条件决定是否显示
        if [ "$FILTER" = "installed" ] && [ "$is_installed" = false ]; then
            continue
        fi
        if [ "$FILTER" = "available" ] && [ "$is_installed" = true ]; then
            continue
        fi

        # 显示 plugin 信息
        echo -e "${BOLD}[$count] $name${NC}"
        echo -e "    ${BLUE}ID:${NC} $plugin_id"
        echo -e "    ${BLUE}Version:${NC} $version"
        echo -e "    ${BLUE}Author:${NC} $author"

        if [ "$is_installed" = true ]; then
            echo -e "    ${BLUE}Status:${NC} ${GREEN}✓ Installed${NC}"
        else
            echo -e "    ${BLUE}Status:${NC} ${YELLOW}○ Available${NC}"
        fi

        # 处理描述（截断过长的描述）
        if [ -n "$description" ]; then
            local short_desc=$(echo "$description" | head -c 100)
            if [ ${#description} -gt 100 ]; then
                short_desc="${short_desc}..."
            fi
            echo -e "    ${BLUE}Description:${NC} $short_desc"
        fi

        echo ""
    done <<< "$plugin_ids"

    # 显示统计信息
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}Statistics:${NC}"
    echo -e "  Total plugins: $count"
    echo -e "  ${GREEN}Installed: $installed_count${NC}"
    echo -e "  ${YELLOW}Available: $available_count${NC}"
    echo ""
}

# 显示使用提示
show_usage_hint() {
    echo -e "${BOLD}Usage:${NC}"
    echo "  Install a plugin:"
    echo "    ./scripts/install-plugin.sh <plugin-id>"
    echo ""
    echo "  List options:"
    echo "    ./scripts/list-plugins.sh              # 显示所有 plugins"
    echo "    ./scripts/list-plugins.sh --installed  # 只显示已安装"
    echo "    ./scripts/list-plugins.sh --available  # 只显示未安装"
    echo ""
}

# 主函数
main() {
    print_header

    # 显示 marketplace 信息
    local mp_name=$(get_marketplace_info "name")
    local mp_desc=$(get_marketplace_info "description")

    if [ -n "$mp_name" ]; then
        echo -e "${BOLD}Marketplace:${NC} $mp_name"
    fi
    if [ -n "$mp_desc" ]; then
        echo -e "${BOLD}Description:${NC} $mp_desc"
    fi
    echo ""

    # 列出 plugins
    list_plugins

    # 显示使用提示
    show_usage_hint
}

main "$@"
