#!/usr/bin/env bash
# Claude Code Marketplace - Plugin 卸载脚本
# 用法: ./scripts/uninstall-plugin.sh <plugin-id>

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

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
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

# 检查 plugin 是否已安装
check_installed() {
    local plugin_id="$1"
    local install_path=$(get_plugin_info "$plugin_id" "install_path")
    local target_path="$PROJECT_ROOT/$install_path"

    if [ ! -L "$target_path" ] && [ ! -d "$target_path" ]; then
        log_error "Plugin '$plugin_id' 未安装"
        exit 1
    fi
}

# 移除链接
remove_link() {
    local plugin_id="$1"
    local install_path=$(get_plugin_info "$plugin_id" "install_path")
    local target_path="$PROJECT_ROOT/$install_path"

    log_info "移除 plugin 链接: $install_path"

    if [ -L "$target_path" ]; then
        rm "$target_path"
        log_success "符号链接已移除"
    elif [ -d "$target_path" ]; then
        rm -rf "$target_path"
        log_success "目录已移除"
    fi
}

# 标记为未启用
mark_disabled() {
    local plugin_id="$1"

    log_info "标记 plugin 为未启用"

    local tmp=$(mktemp)
    awk -v id="$plugin_id" '
        /^  - id:/ {
            in_plugin=0
            if ($3 == id) in_plugin=1
        }
        in_plugin && /enabled:/ {
            print "    enabled: false"
            next
        }
        { print }
    ' "$MARKETPLACE_CONFIG" > "$tmp"
    mv "$tmp" "$MARKETPLACE_CONFIG"

    log_success "Plugin 已标记为未启用"
}

# 显示卸载后信息
show_post_uninstall_info() {
    local plugin_id="$1"
    local plugin_name=$(get_plugin_info "$plugin_id" "name")

    echo ""
    log_success "========================================="
    log_success "Plugin '$plugin_name' 已卸载"
    log_success "========================================="
    echo ""
    log_info "注意："
    echo "  - Plugin 文件仍保留在 plugins/$plugin_id/"
    echo "  - 如需完全删除，运行: git submodule deinit plugins/$plugin_id"
    echo "  - 权限配置保持不变，可在 .claude/settings.local.json 中手动调整"
    echo "  - 重启 Claude Code 以生效"
    echo ""
}

# 主函数
main() {
    local plugin_id="$1"

    if [ -z "$plugin_id" ]; then
        log_error "请指定要卸载的 plugin ID"
        echo "用法: $0 <plugin-id>"
        exit 1
    fi

    if ! grep -q "id: $plugin_id" "$MARKETPLACE_CONFIG"; then
        log_error "Plugin '$plugin_id' 不存在"
        exit 1
    fi

    log_info "开始卸载 plugin: $plugin_id"
    echo ""

    # 检查是否已安装
    check_installed "$plugin_id"

    # 执行卸载步骤
    remove_link "$plugin_id"
    mark_disabled "$plugin_id"

    # 显示卸载后信息
    show_post_uninstall_info "$plugin_id"
}

main "$@"
