#!/usr/bin/env bash
# Claude Code Marketplace - Plugin 链接脚本
# 用于重新链接或修复 plugin 链接
# 用法: ./scripts/link-plugin.sh <plugin-id>

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
MARKETPLACE_CONFIG="$PROJECT_ROOT/marketplace.yaml"

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 获取 plugin 信息
get_plugin_info() {
    local plugin_id="$1"
    local field="$2"

    awk -v id="$plugin_id" -v field="$field" '
        BEGIN { in_plugin=0 }
        /^  - id:/ {
            in_plugin=0
            if ($3 == id) in_plugin=1
        }
        in_plugin && $0 ~ "^    " field ":" {
            sub(/^    '"$field"': /, "")
            gsub(/"/, "")
            print
            exit
        }
    ' "$MARKETPLACE_CONFIG"
}

# 链接 plugin
link_plugin() {
    local plugin_id="$1"
    local source=$(get_plugin_info "$plugin_id" "source")
    local install_path=$(get_plugin_info "$plugin_id" "install_path")

    if [ -z "$source" ] || [ -z "$install_path" ]; then
        log_error "无法获取 plugin '$plugin_id' 的配置信息"
        exit 1
    fi

    local source_path="$PROJECT_ROOT/$source"
    local target_path="$PROJECT_ROOT/$install_path"

    if [ ! -d "$source_path" ]; then
        log_error "源路径不存在: $source_path"
        log_info "请先运行: ./scripts/install-plugin.sh $plugin_id"
        exit 1
    fi

    log_info "链接 plugin: $plugin_id"
    log_info "  源: $source"
    log_info "  目标: $install_path"

    # 创建目标目录
    mkdir -p "$(dirname "$target_path")"

    # 删除已存在的链接或目录
    if [ -L "$target_path" ]; then
        log_info "删除已存在的符号链接"
        rm "$target_path"
    elif [ -d "$target_path" ]; then
        log_info "删除已存在的目录"
        rm -rf "$target_path"
    fi

    # 创建符号链接
    ln -s "$source_path" "$target_path"

    # 验证链接
    if [ -L "$target_path" ] && [ -e "$target_path" ]; then
        log_success "Plugin 链接成功: $install_path -> $source"
    else
        log_error "Plugin 链接失败"
        exit 1
    fi
}

# 主函数
main() {
    local plugin_id="$1"

    if [ -z "$plugin_id" ]; then
        log_error "请指定 plugin ID"
        echo "用法: $0 <plugin-id>"
        exit 1
    fi

    if ! grep -q "id: $plugin_id" "$MARKETPLACE_CONFIG"; then
        log_error "Plugin '$plugin_id' 不存在"
        exit 1
    fi

    link_plugin "$plugin_id"
}

main "$@"
