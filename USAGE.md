# 使用指南

详细的 Claude Code Plugin Marketplace 使用说明。

## 目录

1. [快速开始](#快速开始)
2. [命令行使用](#命令行使用)
3. [Claude Code 集成](#claude-code-集成)
4. [高级用法](#高级用法)
5. [故障排除](#故障排除)

## 快速开始

### 方式一：一键安装

```bash
./scripts/quickstart.sh
```

这会自动：
- 初始化所有 git submodules
- 安装 rust-skills plugin
- 配置必要的权限

### 方式二：手动安装

```bash
# 1. 克隆仓库
git clone <your-repo-url>
cd rust-marketplace

# 2. 初始化 submodules
git submodule update --init --recursive

# 3. 查看可用 plugins
./scripts/list-plugins.sh

# 4. 安装想要的 plugin
./scripts/install-plugin.sh rust-skills

# 5. 重启 Claude Code
```

## 命令行使用

### 列出 Plugins

```bash
# 列出所有 plugins
./scripts/list-plugins.sh

# 只列出已安装的
./scripts/list-plugins.sh --installed

# 只列出可用但未安装的
./scripts/list-plugins.sh --available
```

输出示例：
```
========================================
  Claude Code Plugin Marketplace
========================================

[1] Rust Skills
    ID: rust-skills
    Version: main
    Author: ZhangHanDong
    Status: ✓ Installed
    Description: Rust 开发的三层认知框架...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Statistics:
  Total plugins: 1
  Installed: 1
  Available: 0
```

### 安装 Plugin

```bash
./scripts/install-plugin.sh <plugin-id>
```

示例：
```bash
./scripts/install-plugin.sh rust-skills
```

安装过程：
1. ✓ 检查 plugin 是否存在
2. ✓ 初始化 git submodule
3. ✓ 创建符号链接到 `.claude/skills/`
4. ✓ 更新权限配置
5. ✓ 标记为已启用

### 卸载 Plugin

```bash
./scripts/uninstall-plugin.sh <plugin-id>
```

示例：
```bash
./scripts/uninstall-plugin.sh rust-skills
```

注意：
- Plugin 源文件保留在 `plugins/` 目录
- 只移除 `.claude/skills/` 中的链接
- 权限配置保持不变（可手动调整）

### 重新链接 Plugin

如果链接损坏或需要修复：

```bash
./scripts/link-plugin.sh <plugin-id>
```

## Claude Code 集成

### 启用 /plugin 命令

1. **确保 marketplace skill 已加载**
   
   检查 `.claude/skills/marketplace/plugin.md` 文件存在。

2. **在 Claude Code 中使用**

   ```
   /plugin list
   /plugin install rust-skills
   /plugin info rust-skills
   /plugin uninstall rust-skills
   ```

### /plugin 命令详解

#### /plugin list

列出所有可用的 plugins，显示状态和基本信息。

```
用户: /plugin list
助手: [执行并显示 plugin 列表]
```

#### /plugin install <id>

安装指定的 plugin。

```
用户: /plugin install rust-skills
助手: 正在安装 plugin: rust-skills
      [显示安装进度]
      ✓ 安装成功！请重启 Claude Code。
```

#### /plugin info <id>

显示 plugin 的详细信息。

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

Requires Permissions:
- mcp__acp__Bash
- agent-browser

Status: ✓ 已安装
Install Path: .claude/skills/rust-skills
```

#### /plugin uninstall <id>

卸载已安装的 plugin。

```
用户: /plugin uninstall rust-skills
助手: 正在卸载 plugin: rust-skills
      ✓ 卸载完成！请重启 Claude Code。
```

## 高级用法

### 管理多个 Plugins

```bash
# 批量安装
for plugin in rust-skills python-skills; do
    ./scripts/install-plugin.sh $plugin
done

# 查看已安装的
./scripts/list-plugins.sh --installed
```

### 更新 Plugin

```bash
# 方式一：更新特定 plugin
cd plugins/rust-skills
git pull origin main
cd ../..

# 方式二：使用 git submodule 命令
git submodule update --remote plugins/rust-skills

# 方式三：更新所有 submodules
git submodule update --remote
```

### 固定 Plugin 版本

```bash
cd plugins/rust-skills
git checkout v1.0.0  # 切换到特定版本
cd ../..
git add plugins/rust-skills
git commit -m "Pin rust-skills to v1.0.0"
```

### 自定义安装位置

编辑 `marketplace.yaml`：

```yaml
plugins:
  - id: rust-skills
    install_path: .claude/skills/custom-location/rust-skills
```

### 使用复制而非符号链接

编辑 `marketplace.yaml`：

```yaml
settings:
  default_install_method: copy  # 改为 copy
```

然后修改 `scripts/install-plugin.sh` 中的链接逻辑：

```bash
# 替换符号链接为复制
cp -r "$source_path" "$target_path"
```

### 权限管理

查看当前权限：
```bash
cat .claude/settings.local.json
```

手动添加权限：
```json
{
  "permissions": {
    "allow": [
      "mcp__acp__Bash",
      "agent-browser",
      "mcp__acp__Read",
      "mcp__acp__Write"
    ]
  }
}
```

### 开发模式

在开发自己的 plugin 时：

```bash
# 1. 在 plugins/ 目录创建 plugin
mkdir -p plugins/my-plugin

# 2. 手动链接
ln -s $PWD/plugins/my-plugin .claude/skills/my-plugin

# 3. 编辑并测试
# 4. 满意后添加到 marketplace.yaml
```

## 故障排除

### Plugin 安装后不生效

**症状**: 安装 plugin 后，命令或 skills 不可用

**解决方案**:
1. 重启 Claude Code
2. 检查符号链接：`ls -la .claude/skills/`
3. 检查权限配置：`cat .claude/settings.local.json`

### 符号链接失效

**症状**: `ls -la .claude/skills/rust-skills` 显示断开的链接

**解决方案**:
```bash
# 重新创建链接
./scripts/link-plugin.sh rust-skills

# 或手动修复
rm .claude/skills/rust-skills
ln -s $PWD/plugins/rust-skills .claude/skills/rust-skills
```

### Submodule 初始化失败

**症状**: `git submodule update` 失败

**可能原因**:
- 网络问题
- 权限问题（SSH key）
- Submodule URL 错误

**解决方案**:
```bash
# 检查 submodule 配置
cat .gitmodules

# 手动克隆
git clone https://github.com/ZhangHanDong/rust-skills.git plugins/rust-skills

# 或使用 HTTPS 替换 SSH
git config --global url."https://github.com/".insteadOf git@github.com:
```

### 权限被拒绝

**症状**: 执行脚本时提示 `Permission denied`

**解决方案**:
```bash
# 添加执行权限
chmod +x scripts/*.sh

# 或使用 bash 执行
bash scripts/install-plugin.sh rust-skills
```

### Plugin 功能不完整

**症状**: Plugin 部分功能不工作

**检查清单**:
1. ✓ Submodule 完全初始化：`git submodule update --init --recursive`
2. ✓ 权限正确配置：检查 `.claude/settings.local.json`
3. ✓ Claude Code 已重启
4. ✓ Plugin 文件完整：`ls plugins/rust-skills/`

### 多个 Claude Code 项目共享 Plugins

**场景**: 想在多个项目中使用同一个 plugin

**方案一：全局安装**（不推荐，Claude Code 暂不支持）

**方案二：复制 marketplace 配置**
```bash
# 在新项目中
cp -r /path/to/rust-marketplace/.claude .
cp -r /path/to/rust-marketplace/plugins .
```

**方案三：使用独立的 plugin 仓库**
```bash
# 每个项目单独添加 submodule
git submodule add https://github.com/ZhangHanDong/rust-skills.git .claude/skills/rust-skills
```

## 性能优化

### 减少启动时间

1. **只安装需要的 plugins**
   ```bash
   ./scripts/uninstall-plugin.sh unused-plugin
   ```

2. **使用浅克隆**（减少下载大小）
   ```bash
   git submodule update --init --depth 1
   ```

### 节省磁盘空间

1. **使用符号链接而非复制**（默认行为）

2. **清理 git 历史**
   ```bash
   cd plugins/rust-skills
   git gc --aggressive --prune=all
   ```

## 最佳实践

1. **定期更新 Plugins**
   ```bash
   git submodule update --remote
   ```

2. **版本控制 marketplace 配置**
   提交 `marketplace.yaml` 和 `.gitmodules` 到版本控制。

3. **文档化自定义配置**
   如果修改了默认配置，记录在项目文档中。

4. **测试新 Plugin**
   在安装生产使用前，先在测试项目中验证。

5. **备份配置**
   ```bash
   cp .claude/settings.local.json .claude/settings.local.json.backup
   ```

## 下一步

- 阅读 [README.md](README.md) 了解项目概述
- 查看 [CONTRIBUTING.md](CONTRIBUTING.md) 学习如何贡献
- 访问 [rust-skills](https://github.com/ZhangHanDong/rust-skills) 了解具体功能

---

有问题？[提交 Issue](https://github.com/FineKe/rust-marketplace/issues) 或查看 [Discussions](https://github.com/FineKe/rust-marketplace/discussions)
