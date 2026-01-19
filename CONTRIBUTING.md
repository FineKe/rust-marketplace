# 贡献指南

感谢你对 Claude Code Plugin Marketplace 的贡献兴趣！

## 如何贡献

### 添加新的 Plugin

1. **Fork 此仓库**
   ```bash
   git clone https://github.com/FineKe/rust-marketplace.git
   cd rust-marketplace
   ```

2. **创建新分支**
   ```bash
   git checkout -b add-plugin-your-plugin-name
   ```

3. **添加 Plugin 作为 Submodule**
   ```bash
   git submodule add https://github.com/author/plugin-repo.git plugins/your-plugin-id
   ```

4. **更新 marketplace.yaml**
   
   在 `plugins` 列表中添加你的 plugin 配置：
   ```yaml
   - id: your-plugin-id
     name: "Your Plugin Name"
     version: "main"
     source: plugins/your-plugin-id
     type: submodule
     repository: https://github.com/author/plugin-repo
     description: |
       详细描述你的 plugin 功能
       支持多行描述
     author: Your Name
     homepage: https://your-plugin-homepage.com
     tags:
       - tag1
       - tag2
     requires_permissions:
       - mcp__acp__Bash
     features:
       - skills: true
       - agents: false
       - hooks: false
       - commands: true
     install_path: .claude/skills/your-plugin-id
     enabled: false
   ```

5. **测试安装**
   ```bash
   ./scripts/install-plugin.sh your-plugin-id
   ```

6. **更新文档**
   
   在 README.md 的 "可用的 Plugins" 部分添加你的 plugin 介绍。

7. **提交更改**
   ```bash
   git add .
   git commit -m "Add your-plugin-id to marketplace"
   git push origin add-plugin-your-plugin-name
   ```

8. **创建 Pull Request**
   
   在 GitHub 上创建 Pull Request，描述你添加的 plugin。

## Plugin 要求

要被收录到 marketplace，plugin 需要满足：

### 基本要求

- [ ] 有清晰的 README 文档
- [ ] 有明确的许可证
- [ ] 代码质量良好，无明显 bug
- [ ] 遵循 Claude Code Plugin 规范

### 目录结构

Plugin 应该包含：
```
your-plugin/
├── README.md          # 必需
├── LICENSE            # 必需
├── .claude-plugin/    # 推荐
│   └── plugin.json
└── skills/            # 至少包含一个
    └── skill.md
```

### 权限声明

在 marketplace.yaml 中明确声明需要的权限：
```yaml
requires_permissions:
  - mcp__acp__Bash      # 如果需要执行命令
  - mcp__acp__Read      # 如果需要读文件
  - mcp__acp__Write     # 如果需要写文件
  - agent-browser       # 如果需要网络访问
```

### 文档要求

Plugin 的 README.md 应该包含：

1. **简介**: Plugin 是什么，解决什么问题
2. **特性**: 主要功能列表
3. **安装**: 如何安装（可以引用 marketplace）
4. **使用方法**: 命令和示例
5. **配置**: 如果有配置选项
6. **许可证**: 许可证信息

## 改进 Marketplace 本身

### Bug 修复

1. 在 Issues 中报告 bug
2. Fork 并创建修复分支
3. 提交 Pull Request

### 功能增强

1. 在 Discussions 中讨论新功能
2. 获得社区反馈
3. 实现并提交 Pull Request

### 脚本改进

欢迎改进安装脚本：
- `scripts/install-plugin.sh`
- `scripts/list-plugins.sh`
- `scripts/link-plugin.sh`

改进方向：
- 更好的错误处理
- 更友好的用户界面
- 更多的配置选项
- 跨平台兼容性

## 代码风格

### Shell 脚本

- 使用 `#!/usr/bin/env bash`
- 使用 `set -e` 处理错误
- 添加清晰的注释
- 使用有意义的变量名
- 提供友好的输出信息

### YAML 配置

- 使用 2 空格缩进
- 保持一致的格式
- 添加必要的注释

### Markdown 文档

- 使用清晰的标题层级
- 提供代码示例
- 使用表格展示结构化信息
- 添加 emoji 提升可读性（适度）

## 测试

在提交 PR 前，请确保：

1. **安装测试**
   ```bash
   ./scripts/install-plugin.sh your-plugin-id
   ```

2. **列表测试**
   ```bash
   ./scripts/list-plugins.sh
   ./scripts/list-plugins.sh --installed
   ```

3. **链接测试**
   ```bash
   ./scripts/link-plugin.sh your-plugin-id
   ls -la .claude/skills/your-plugin-id
   ```

4. **清理测试**
   ```bash
   rm -rf .claude/skills/your-plugin-id
   ```

## Pull Request 流程

1. **清晰的标题**: 简要说明变更内容
2. **详细的描述**: 
   - 为什么需要这个变更
   - 做了哪些改动
   - 如何测试
3. **关联 Issue**: 如果相关，引用 Issue 编号
4. **测试证明**: 提供测试截图或输出

## 审查标准

PR 将根据以下标准审查：

- [ ] 代码质量和可读性
- [ ] 文档完整性
- [ ] 功能正确性
- [ ] 测试覆盖
- [ ] 向后兼容性
- [ ] 安全性考虑

## 许可证

贡献的代码将遵循项目的 MIT 许可证。

## 行为准则

- 尊重所有贡献者
- 建设性的反馈
- 包容和友善
- 专注于技术讨论

## 获取帮助

- **Issues**: 报告 bug 或请求功能
- **Discussions**: 一般性讨论和问题
- **Wiki**: 详细的指南和教程

## 致谢

所有贡献者都会在 CONTRIBUTORS.md 中列出。

---

再次感谢你的贡献！🎉
