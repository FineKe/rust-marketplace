#!/usr/bin/env bash
# 快速开始脚本 - 一键安装 rust-skills

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Claude Code Marketplace 快速开始${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

echo -e "${GREEN}步骤 1/3:${NC} 初始化 git submodules..."
git submodule update --init --recursive

echo ""
echo -e "${GREEN}步骤 2/3:${NC} 安装 rust-skills plugin..."
./scripts/install-plugin.sh rust-skills

echo ""
echo -e "${GREEN}步骤 3/3:${NC} 设置完成！"
echo ""
echo -e "${YELLOW}下一步:${NC}"
echo "  1. 重启 Claude Code"
echo "  2. 在 Rust 项目中使用 /sync-crate-skills"
echo "  3. 开始享受 Rust Skills 的强大功能！"
echo ""
echo -e "${BLUE}查看更多信息: cat README.md${NC}"
echo ""
