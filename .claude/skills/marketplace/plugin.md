---
version: 1.0.0
name: plugin
description: Claude Code Plugin Marketplace - 安装和管理 plugins
tags: [marketplace, plugin, install, management]
---

# Plugin Marketplace Skill

这个 skill 提供 Claude Code Plugin Marketplace 的管理功能，允许用户通过命令行安装、列出和管理 plugins。

## Usage

### 列出所有可用的 plugins
```
/plugin list
/plugin list --installed
/plugin list --available
```

### 安装 plugin
```
/plugin install <plugin-id>
```

### 显示 plugin 信息
```
/plugin info <plugin-id>
```

### 卸载 plugin
```
/plugin uninstall <plugin-id>
```

## 实现逻辑

当用户调用 `/plugin` 命令时，你应该：

1. **解析命令参数**
   - 识别子命令：list, install, info, uninstall
   - 提取 plugin-id 和其他参数

2. **执行相应的脚本**
   - `list`: 执行 `./scripts/list-plugins.sh`
   - `install <id>`: 执行 `./scripts/install-plugin.sh <id>`
   - `info <id>`: 从 marketplace.yaml 读取并显示详细信息
   - `uninstall <id>`: 移除链接并更新配置

3. **处理错误**
   - 检查脚本是否存在
   - 检查 plugin-id 是否有效
   - 显示友好的错误消息

4. **提供反馈**
   - 显示操作进度
   - 显示操作结果
   - 提供下一步建议

## 示例对话

### 列出 plugins
```
用户: /plugin list
助手: 正在获取可用的 plugins...
[执行 ./scripts/list-plugins.sh]
[显示输出]
```

### 安装 plugin
```
用户: /plugin install rust-skills
助手: 正在安装 plugin: rust-skills
[执行 ./scripts/install-plugin.sh rust-skills]
[显示安装进度和结果]
安装成功！请重启 Claude Code 以加载新的 skills。
```

### 显示 plugin 信息
```
用户: /plugin info rust-skills
助手: 
Plugin: Rust Skills
ID: rust-skills
Version: main
Author: ZhangHanDong
Repository: https://github.com/ZhangHanDong/rust-skills

Description:
Rust 开发的三层认知框架和技能集...

Features:
- Skills: ✓
- Agents: ✓
- Hooks: ✓
- Commands: ✓

Status: 已安装 ✓
```

## 技术细节

### 文件路径
- Marketplace 配置: `./marketplace.yaml`
- 安装脚本: `./scripts/install-plugin.sh`
- 列出脚本: `./scripts/list-plugins.sh`
- 链接脚本: `./scripts/link-plugin.sh`
- Plugin 存储: `./plugins/<plugin-id>/`
- 安装位置: `.claude/skills/<plugin-id>/`

### 权限要求
- 需要 Bash 执行权限
- 需要文件读写权限

### Git Submodule 操作
安装 plugin 时会自动：
1. 初始化 git submodule
2. 更新 submodule 内容
3. 创建符号链接到 .claude/skills/
4. 更新权限配置

## 注意事项

1. **重启要求**: 安装新 plugin 后需要重启 Claude Code 才能加载新的 skills
2. **权限配置**: 某些 plugins 需要额外的权限，会自动更新 `.claude/settings.local.json`
3. **Git 操作**: 使用 git submodule 管理 plugins，确保 git 已正确配置
4. **符号链接**: 默认使用符号链接而非复制，保持 plugin 内容同步

## 扩展性

这个 marketplace 架构支持：
- 添加更多 plugins（编辑 marketplace.yaml）
- 自定义安装方法（symlink 或 copy）
- 版本控制（通过 git submodule）
- 依赖管理（通过 YAML 配置）
- 权限管理（自动更新 settings）

## 相关文件

- `marketplace.yaml`: Plugin 配置清单
- `.claude-plugin/marketplace.json`: Marketplace 元数据
- `README.md`: 使用文档
