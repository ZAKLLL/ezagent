---
name: jvs-keep-clean
description: 维护 EzAgent 数字空间的目录结构清洁。当 Agent 需要清理仓库结构、移除冗余文件、保持目录结构一致性、识别重复或孤立文件、检查命名规范违规、执行维护任务、或评估仓库整体健康状况时使用。此技能确保数字分身系统保持组织有序和可维护。每当用户提到清理、整理、维护仓库或询问目录结构健康状况时使用，即使用户没有明确要求"保持清洁"或类似关键词。
---

# JVS 保持清洁

此技能维护 EzAgent 数字空间的目录结构清洁。

## 原则

### 整洁的仓库
- **命名一致**：遵循既定规范
- **逻辑结构**：每个文件都有清晰、合理的位置
- **无重复文件**：没有冗余或重复的文件
- **无孤立文件**：所有文件都归属于某处并服务于目的
- **文档化**：所有重要组件都有文档

### 数字卫生
- 定期清理临时文件
- 归档旧记忆（>90 天）
- 清理过时的文档
- 删除未使用的脚本或工具
- 保持目录结构与设计一致

### 自动化
- 脚本处理常规维护
- 定期清理
- 尽可能自动化
- 关键操作人工确认

## 架构规则

### 目录结构

```
ezagent/
├── memory/               # 记忆文件（mem_YYYY_MM_DD.md）
├── notes/                # 知识笔记（按主题分类）
├── work/
│   ├── bookmarks/        # 常用链接
│   ├── documents/        # 文档模板
│   ├── interview/        # 求职记录（仅模板）
│   └── work_report/      # 周报/OKR/复盘
├── config/
│   ├── cron/             # 定时任务配置
│   └── llm_provider/     # AI 助手 Provider 配置
├── lib/                  # Shell 函数库
├── .agents/skills/       # AI Agent 技能定义
├── .claude/skills/       # 技能镜像（软链接自 .agents/skills/）
├── .githooks/            # Git hooks
├── *.sh                  # 核心脚本（根目录）
├── CLAUDE.md / AGENTS.md # 数字分身人格与行为定义
└── README.md
```

### 文件放置规则

**根目录：**
- `.gitignore` / `.gitmessage` - Git 相关配置
- `CLAUDE.md` / `AGENTS.md` - 人格与行为定义（核心，必需）
- `README.md` - 项目说明
- `agent_stats.sh`, `memory_add.sh`, `memory_search.sh`, `cron_manage.sh`, `cron_query.sh` - 常用入口脚本

**绝不要放在根目录：**
- 具体业务数据（放到 `memory/`、`notes/`、`work/` 对应子目录）
- 临时文件
- 真实密钥/配置（放到 `config/` 对应子目录，且遵循 `.gitignore` 规则）

## 命名规范

### 文件
```
- 脚本：snake_case.sh（如 agent_stats.sh、memory_add.sh）
- 文档：kebab-case 或全大写（如 README.md、CLAUDE.md）
- 记忆文件：mem_YYYY_MM_DD.md
```

### 目录
```
- 小写，优先使用 kebab-case
- 多个项目使用复数形式（如 notes/、skills/）
```

## 常见问题和解决方案

### 问题 1：文件位置错误

**问题：**
```
ezagent/
├── my-notes/       ❌ 应该放在 notes/
└── tmp/            ❌ 应该删除
```

**解决方案：**
```bash
mv my-notes/* notes/
rm -rf tmp/
```

### 问题 2：重复文件

**解决方案：**
```bash
# 比较文件
diff a.md b.md

# 如果相同，删除重复；如果不同，合并或重命名区分
```

### 问题 3：命名违规

**问题：**
- `MyNotes.md`（应该小写/kebab-case）
- `deployScript.sh`（应该是 snake_case）
- 记忆文件不遵循 `mem_YYYY_MM_DD.md` 格式

**解决方案：**
```bash
mv MyNotes.md my-notes.md
mv deployScript.sh deploy_script.sh
```

### 问题 4：记忆堆积

**问题：**
- `memory/` 下旧记忆文件太多，检索变慢

**解决方案：**
```bash
# 按年份归档 90 天前的记忆
mkdir -p memory/archive/2025
find memory/ -maxdepth 1 -name "mem_2025_*.md" -mtime +90 -exec mv {} memory/archive/2025/ \;
```

## 维护任务

### 每周
- [ ] 查看最近添加的记忆
- [ ] 检查重复文件
- [ ] 清理临时文件

### 每月
- [ ] 全面检查仓库结构
- [ ] 删除孤立文件
- [ ] 更新文档
- [ ] 检查命名规范
- [ ] 归档旧记忆（>90 天）

### 每季度
- [ ] 全面清理
- [ ] 如需要重组目录结构
- [ ] 更新 CLAUDE.md / AGENTS.md（如果行为准则有变化）
- [ ] 审查并更新所有文档

## 清理命令

### 快速清理
```bash
find . -name "*.tmp" -delete
find . -name "*.bak" -delete
find . -name "*~" -delete
```

### 结构检查
```bash
# 检查根目录中错误位置的文件
find . -maxdepth 1 -type f -name "*.md" ! -name "README.md" ! -name "CLAUDE.md" ! -name "AGENTS.md"

# 检查重复脚本
find . -name "*.sh" -not -path "./.git/*" | xargs -I{} basename {} | sort | uniq -d
```

### 归档旧记忆
```bash
find memory/ -maxdepth 1 -name "mem_*.md" -mtime +90 -exec mv {} memory/archive/ \;
```

### Git 卫生
```bash
git status
find . -size +1M -not -path "./.git/*" -ls
git ls-files --others --exclude-standard
```

## 评估检查清单

### 结构
- [ ] 根目录只包含系统级文件
- [ ] 没有错误位置的文件
- [ ] 没有孤立文件
- [ ] 目录结构与本技能描述一致

### 命名
- [ ] 脚本使用 snake_case
- [ ] 记忆文件遵循 `mem_YYYY_MM_DD.md` 格式
- [ ] 没有混合大小写的随意命名

### 文档
- [ ] README.md 反映当前状态
- [ ] CLAUDE.md / AGENTS.md 准确
- [ ] 所有脚本都有使用说明

### Git
- [ ] 没有未提交的敏感数据（密钥、真实姓名、隐私信息）
- [ ] 提交信息遵循 `.gitmessage` 模板格式（`类型: 描述`）
- [ ] `.gitignore` 覆盖真实密钥配置文件

## 何时使用此技能

- 用户要求"清理"或"整理"仓库
- 用户提到目录结构或仓库健康状况
- 你注意到文件位置不一致、命名混乱
- 用户想要"维护"或"审查"系统
- 仓库变得杂乱无章

## 应急清理

```bash
# 1. 查看当前状态
./agent_stats.sh

# 2. 手动将错位文件移动到正确位置

# 3. 仔细审查后删除重复文件

# 4. 归档旧记忆
find memory/ -maxdepth 1 -name "mem_*.md" -mtime +90 -exec mv {} memory/archive/ \;

# 5. 确认 README / CLAUDE.md / AGENTS.md 准确后提交
git add .
git commit -m "chore: 仓库清理"
```

## 最佳实践

### 要做的
- 随时清理，不留到"以后"
- 遵循命名规范
- 从一开始就把文件放在正确位置
- 重要更改时同步更新文档
- 定期归档旧记忆

### 不要做的
- 留下临时文件不管
- 在错误位置创建文件并打算"稍后移动"
- 复制文件而不整合
- 无视命名约定
- 让混乱积累

记住：**随时清理**优于**事后清理**。
