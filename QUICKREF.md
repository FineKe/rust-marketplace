# 快速参考

## 一键开始

```bash
./scripts/quickstart.sh
```

## 常用命令

### 命令行

```bash
# 列出所有 plugins
./scripts/list-plugins.sh

# 安装 plugin
./scripts/install-plugin.sh rust-skills

# 卸载 plugin
./scripts/uninstall-plugin.sh rust-skills

# 重新链接
./scripts/link-plugin.sh rust-skills
```

### Claude Code 中

```
/plugin list
/plugin install rust-skills
/plugin info rust-skills
/plugin uninstall rust-skills
```

## 更新 Plugin

```bash
# 更新特定 plugin
git submodule update --remote plugins/rust-skills

# 更新所有 plugins
git submodule update --remote
```

## 文件位置

- **配置**: `marketplace.yaml`
- **Plugins**: `plugins/`
- **安装位置**: `.claude/skills/`
- **脚本**: `scripts/`
- **权限**: `.claude/settings.local.json`

## 故障排除

### Plugin 不生效？
```bash
# 1. 重启 Claude Code
# 2. 检查链接
ls -la .claude/skills/
# 3. 重新链接
./scripts/link-plugin.sh rust-skills
```

### Submodule 问题？
```bash
# 重新初始化
git submodule update --init --recursive
```

### 权限问题？
```bash
# 添加执行权限
chmod +x scripts/*.sh
```

## 项目结构

```
rust-marketplace/
├── marketplace.yaml          # Plugin 配置
├── plugins/                  # Submodules
│   └── rust-skills/
├── scripts/                  # 管理脚本
│   ├── install-plugin.sh
│   ├── uninstall-plugin.sh
│   ├── list-plugins.sh
│   └── link-plugin.sh
└── .claude/
    ├── skills/               # 安装的 plugins
    │   ├── marketplace/      # /plugin 命令
    │   └── rust-skills/      # 链接到 plugins/
    └── settings.local.json   # 权限配置
```

## 链接

- [完整文档](README.md)
- [使用指南](USAGE.md)
- [贡献指南](CONTRIBUTING.md)
- [Rust Skills](https://github.com/ZhangHanDong/rust-skills)
