#!/usr/bin/env bash
# Claude Code Marketplace - Plugin 安装脚本
# 用法: ./scripts/install-plugin.sh <plugin-id>

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
MARKETPLACE_CONFIG="$PROJECT_ROOT/marketplace.yaml"
CLAUDE_DIR="$PROJECT_ROOT/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"
SETTINGS_FILE="$CLAUDE_DIR/settings.local.json"

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

# 检查依赖
check_dependencies() {
    if ! command -v yq &> /dev/null; then
        log_warning "yq 未安装，将使用 grep/sed 解析 YAML（功能有限）"
        USE_YQ=false
    else
        USE_YQ=true
    fi

    if ! command -v jq &> /dev/null; then
        log_error "jq 未安装，请先安装: brew install jq"
        exit 1
    fi
}

# 简单的 YAML 解析（不使用 yq）
get_plugin_info() {
    local plugin_id="$1"
    local field="$2"

    # 使用 awk 提取 plugin 信息
    awk -v id="$plugin_id" -v field="$field" '
        BEGIN { in_plugin=0; found=0 }
        /^  - id:/ {
            in_plugin=0
            if ($3 == id) { in_plugin=1; found=1 }
        }
        in_plugin && $0 ~ "^    " field ":" {
            sub(/^    '"$field"': /, "")
            gsub(/"/, "")
            print
            exit
        }
    ' "$MARKETPLACE_CONFIG"
}

# 检查 plugin 是否存在
check_plugin_exists() {
    local plugin_id="$1"

    if ! grep -q "id: $plugin_id" "$MARKETPLACE_CONFIG"; then
        log_error "Plugin '$plugin_id' 不存在于 marketplace"
        log_info "运行 './scripts/list-plugins.sh' 查看可用 plugins"
        exit 1
    fi
}

# 初始化 git submodule
init_submodule() {
    local plugin_id="$1"
    local source=$(get_plugin_info "$plugin_id" "source")

    log_info "初始化 git submodule: $source"

    cd "$PROJECT_ROOT"

    if [ ! -d "$source/.git" ]; then
        git submodule update --init --recursive "$source"
        log_success "Submodule 初始化完成"
    else
        log_info "Submodule 已存在，更新中..."
        git submodule update --remote "$source"
        log_success "Submodule 更新完成"
    fi
}

# 链接或复制 plugin 文件
link_plugin() {
    local plugin_id="$1"
    local source=$(get_plugin_info "$plugin_id" "source")
    local install_path=$(get_plugin_info "$plugin_id" "install_path")

    local source_path="$PROJECT_ROOT/$source"
    local target_path="$PROJECT_ROOT/$install_path"

    log_info "链接 plugin 文件到 Claude 配置目录"

    # 创建目标目录
    mkdir -p "$(dirname "$target_path")"

    # 检查是否已存在
    if [ -L "$target_path" ] || [ -d "$target_path" ]; then
        log_warning "目标路径已存在，将被覆盖"
        rm -rf "$target_path"
    fi

    # 创建符号链接
    ln -s "$source_path" "$target_path"
    log_success "Plugin 文件已链接到: $install_path"
}

# 更新权限配置
update_permissions() {
    local plugin_id="$1"

    log_info "更新权限配置"

    # 创建 settings.local.json 如果不存在
    if [ ! -f "$SETTINGS_FILE" ]; then
        mkdir -p "$CLAUDE_DIR"
        echo '{"permissions":{"allow":[]}}' > "$SETTINGS_FILE"
    fi

    # 读取需要的权限
    local permissions=$(awk -v id="$plugin_id" '
        BEGIN { in_plugin=0; in_perms=0 }
        /^  - id:/ {
            in_plugin=0; in_perms=0
            if ($3 == id) in_plugin=1
        }
        in_plugin && /requires_permissions:/ { in_perms=1; next }
        in_plugin && in_perms && /^      - / {
            sub(/^      - /, "")
            print
        }
        in_plugin && in_perms && /^    [a-z]/ { in_perms=0 }
    ' "$MARKETPLACE_CONFIG")

    if [ -z "$permissions" ]; then
        log_info "无需额外权限"
        return
    fi

    # 添加权限到 settings.local.json
    while IFS= read -r perm; do
        if [ -n "$perm" ]; then
            log_info "添加权限: $perm"
            # 使用 jq 添加权限（避免重复）
            tmp=$(mktemp)
            jq --arg perm "$perm" '
                .permissions.allow |= (. + [$perm] | unique)
            ' "$SETTINGS_FILE" > "$tmp"
            mv "$tmp" "$SETTINGS_FILE"
        fi
    done <<< "$permissions"

    log_success "权限配置已更新"
}

# 标记 plugin 为已启用
mark_enabled() {
    local plugin_id="$1"

    log_info "标记 plugin 为已启用"

    # 使用 sed 更新 marketplace.yaml 中的 enabled 状态
    # 注意：这是一个简单实现，可能需要改进
    local tmp=$(mktemp)
    awk -v id="$plugin_id" '
        /^  - id:/ {
            in_plugin=0
            if ($3 == id) in_plugin=1
        }
        in_plugin && /enabled:/ {
            print "    enabled: true"
            next
        }
        { print }
    ' "$MARKETPLACE_CONFIG" > "$tmp"
    mv "$tmp" "$MARKETPLACE_CONFIG"

    log_success "Plugin 已标记为启用"
}

# 显示安装后信息
show_post_install_info() {
    local plugin_id="$1"
    local plugin_name=$(get_plugin_info "$plugin_id" "name")

    echo ""
    log_success "========================================="
    log_success "Plugin '$plugin_name' 安装成功！"
    log_success "========================================="
    echo ""
    log_info "下一步："
    echo "  1. 重启 Claude Code 以加载新的 skills"
    echo "  2. 查看 plugin 文档: plugins/$plugin_id/README.md"
    echo "  3. 开始使用 plugin 提供的功能"
    echo ""

    # 显示特定 plugin 的使用提示
    if [ "$plugin_id" = "rust-skills" ]; then
        log_info "Rust Skills 使用提示："
        echo "  - 使用 /sync-crate-skills 同步 Cargo.toml 依赖"
        echo "  - 400+ 关键词会自动触发认知路由"
        echo "  - 查看文档了解三层认知框架"
    fi
    echo ""
}

# 主函数
main() {
    local plugin_id="$1"

    if [ -z "$plugin_id" ]; then
        log_error "请指定要安装的 plugin ID"
        echo "用法: $0 <plugin-id>"
        echo ""
        log_info "可用 plugins:"
        "$SCRIPT_DIR/list-plugins.sh"
        exit 1
    fi

    log_info "开始安装 plugin: $plugin_id"
    echo ""

    # 检查依赖
    check_dependencies

    # 检查 plugin 是否存在
    check_plugin_exists "$plugin_id"

    # 执行安装步骤
    init_submodule "$plugin_id"
    link_plugin "$plugin_id"
    update_permissions "$plugin_id"
    mark_enabled "$plugin_id"

    # 显示安装后信息
    show_post_install_info "$plugin_id"
}

# 运行主函数
main "$@"
