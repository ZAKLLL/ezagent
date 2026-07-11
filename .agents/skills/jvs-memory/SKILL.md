---
name: jvs-memory
description: 指导 AI Agent 使用 EzAgent 记忆系统。当 Agent 需要添加、搜索、读取、整理或维护记忆，检索长期上下文，理解 memory/ 目录结构，或处理 mem_YYYY_MM_DD.md、overview.md、记忆脚本相关任务时使用。记忆管理必须优先使用仓库脚本 memory_add.sh、memory_search.sh、agent_stats.sh；处理 EzAgent 记忆系统时即使用户没有明确提到”skill”也要使用此技能。
---

# JVS 记忆系统

此技能指导 Agent 使用 EzAgent 的长期记忆系统。仓库采用单一 `memory/` 目录作为记忆真值，不区分环境。

## 快速参考

### 记忆位置

```text
memory/                 # 记忆文件目录
memory/mem_YYYY_MM_DD.md # 每日记忆
memory/overview.md      # 最近事件概览
memory/overview_YYYY_MM.md # 月度概览
```

### 脚本优先

执行记忆相关操作时，优先级如下：

```text
优先级 1: 使用仓库专用脚本
优先级 2: 使用仓库共享脚本或库
优先级 3: 使用 Bash 临时命令
```

必须优先使用的脚本：

```bash
./memory_add.sh
./memory_search.sh
./agent_stats.sh
```

仅当脚本不支持目标操作时，才直接读取或编辑 `memory/` 文件。

## 常用操作

### 添加记忆

交互式添加：

```bash
./memory_add.sh
```

非交互式添加：

```bash
./memory_add.sh --non-interactive --content "记忆内容"
./memory_add.sh --non-interactive --title "标题" --content-file /path/to/file
```

需要把生成的记忆加入暂存区时：

```bash
./memory_add.sh --non-interactive --stage --content "记忆内容"
```

### 搜索记忆

```bash
./memory_search.sh "关键词"
./memory_search.sh -r 7
./memory_search.sh -d 2026_06_05
./memory_search.sh -t "#标签"
```

搜索时先用具体关键词或标签缩小范围，再按需读取匹配文件上下文。

### 查看状态

```bash
./agent_stats.sh
./agent_stats.sh --json
./agent_stats.sh --memory
```

用于快速确认记忆数量、最近活动和仓库状态。

## 记忆文件规范

每日记忆文件命名：

```text
mem_YYYY_MM_DD.md
```

推荐结构：

```markdown
# 记忆日期: YYYY-MM-DD

## 环境上下文
- 当前环境: main
- 主要任务: ...
- 相关项目: ...

## 关键事件
- 时间: HH:MM
- 描述: ...
- 行动项: ...

## 学习和洞察
- 领域: ...
- 内容: ...

## 重要信息
- [ ] 待办事项

## 标签
#标签1 #标签2

---
*创建时间: YYYY-MM-DD HH:MM:SS*
*环境: main*
*AI Agent: EzAgent*
```

## Agent 工作流程

### 检索上下文

1. 用 `./memory_search.sh` 搜索关键词、标签或最近记忆。
2. 只读取与当前任务相关的匹配文件片段。
3. 将记忆内容与当前用户请求整合，避免把无关历史带入答案。
4. 如果搜索结果不足，说明检索范围和限制。

### 添加记忆

1. 判断内容是否值得长期保存：偏好、决策、行动项、项目状态、学习洞察、重要事实。
2. 优先使用 `./memory_add.sh` 写入。
3. 内容要具体、可检索，包含必要上下文和标签。
4. 涉及敏感信息时提醒用户，并避免提交密钥、令牌、隐私数据。

### 维护记忆

1. 优先通过脚本查看状态和搜索重复内容。
2. 清理或整理前先确认影响范围。
3. 编辑历史记忆时保持原始时间、主题和上下文可追溯。
4. 维护完成后按任务需要提交 Git。

## 写作原则

- 具体：记录事实、决策依据、下一步，而不是笼统描述。
- 可检索：包含项目名、人物、日期、标签、关键技术词。
- 有边界：只保存对未来有价值的信息。
- 可追溯：重要决策要记录背景、选项、选择和影响。

## 安全

- 不把 API Key、密码、令牌、身份证件等敏感信息写入记忆。
- 需要保存敏感上下文时，使用脱敏摘要。
- 提交前检查 `git diff --cached`，避免误提交无关或敏感文件。
