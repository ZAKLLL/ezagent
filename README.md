# EzAgent - AI 时代，你的数字分身

一个面向非技术个人用户的数字分身模板：用 Markdown 文件 + Shell 脚本 + AI Agent 技能定义（Skills），驱动 Claude Code（或其他支持 Agent Skills 的工具）帮你管理记忆、笔记、周报和常用信息。

不涉及编码/软件工程场景，开箱即用，也可以随时按自己的习惯调整。

## 这本质是什么

**这不是一个 Agent 程序**——仓库里没有任何调用大模型、做推理/编排的代码。

它本质上是一份**结构化的个人知识库 / 上下文工程（Context Engineering）配置**：约定好记忆怎么存、笔记怎么分类、周报怎么写、常见任务该怎么做（Skills），然后交给 Claude Code 这类已经具备推理能力的 Agent 工具去读取和执行。

打个比方：Claude Code 是"大脑和双手"，这个仓库是喂给它的"记忆和SOP手册"。换成任何其他支持读取 `CLAUDE.md` / Agent Skills 的工具，同样能用这套约定跑起来。

## 核心特性

- **记忆系统**：按日期记录工作中的关键事件、决策、待办，跨会话保留上下文
- **知识笔记**：按主题分类沉淀行业认知、工作方法、职业发展记录
- **周报/OKR**：结合工作说明自动生成周报，配套 OKR 与阶段性复盘模板
- **常用文档模板**：会议纪要、简历、求职记录等
- **AI Agent 技能库**：预置一组 Claude Code Skills，覆盖记忆、笔记、周报、仓库维护等场景
- **Agent Hooks 自检**：`.claude/hooks/` 里的 Claude Code hooks 会自动检测"改了笔记/文档但忘了更新记忆"的情况并提醒，见 [CLAUDE.md](CLAUDE.md#自进化机制agent-hooks)

## 安装指南

这个仓库同时准备了两份指令文件：`CLAUDE.md`（Claude Code 专用）和 `AGENTS.md`（通用约定，Codex CLI、opencode 等主流 Agent 工具都会自动读取同名文件）。理论上任何支持"项目级指令文件"的 Agent 工具，把它指向这个仓库根目录就能直接工作。

### 1. 拿到这份仓库

```bash
git clone git@github.com:ZAKLLL/ezagent.git my-digital-twin
cd my-digital-twin
```

如果想要一份不带原仓库 Git 历史的干净副本（比如你要重新 init 成自己的仓库）：

```bash
npx degit ZAKLLL/ezagent my-digital-twin
cd my-digital-twin && git init
```

### 2. 选一个 Agent 工具打开它

#### Claude Code
```bash
npm install -g @anthropic-ai/claude-code
cd my-digital-twin
claude
```
自动读取根目录 `CLAUDE.md`；`.agents/skills/` 下的技能会在执行 `./agent_stats.sh` 时自动软链接到 `~/.claude/skills/`，无需手动配置。

#### Codex CLI（OpenAI）
```bash
npm install -g @openai/codex
# 或：curl -fsSL https://chatgpt.com/codex/install.sh | sh
cd my-digital-twin
codex
```
Codex 会自动读取根目录 `AGENTS.md` 作为项目指令。

#### opencode
```bash
curl -fsSL https://opencode.ai/install | bash
# 或：npm i -g opencode-ai@latest
cd my-digital-twin
opencode
```
opencode 同样读取 `AGENTS.md`。

#### 其他 Agent Harness（通用方式）
只要你的工具支持读取 `AGENTS.md`（目前事实上的通用约定），把它指向本仓库根目录即可。如果你的工具用的是别的文件名（如某些工具的 `.rules`/自定义配置），把 `AGENTS.md` 的内容复制过去即可，内容本身与工具无关。

### 3. 确认环境正常

```bash
./agent_stats.sh
```
显示记忆/笔记/书签统计和 Git 状态。

## 首次使用

### 记录一条记忆
```bash
./memory_add.sh
```

### 搜索记忆
```bash
./memory_search.sh 关键词
./memory_search.sh -r 7   # 最近 7 天
```

## 目录结构

```
ezagent/
├── memory/            # 记忆文件，含示例条目，参考格式后替换为自己的内容
├── notes/             # 知识笔记，7 个通用分类，每类含 1 篇示例
├── work/
│   ├── bookmarks/      # 常用链接
│   ├── documents/      # 会议纪要模板、简历模板
│   ├── interview/      # 求职记录模板
│   └── work_report/    # 周报索引 + 示例周报 + OKR/复盘模板
├── config/
│   ├── cron/           # 定时任务配置（如周报提醒）
│   └── llm_provider/   # Claude Code Provider 配置示例
├── lib/                # agent_stats.sh 依赖的 Shell 函数库
├── .agents/skills/     # AI Agent 技能定义（SKILL.md）
├── .claude/skills/     # 技能镜像，软链接自 .agents/skills/
├── .claude/hooks/      # Agent Hooks 脚本（记忆自检）
├── .claude/settings.json  # Hooks 注册配置
├── .githooks/          # 提交前记忆检查等 Git hooks
└── *.sh                # 核心脚本
```

## 核心概念

- **记忆（memory/）**：某个时间点的工作上下文和待办，按日期存档，用完即可搜索找回
- **笔记（notes/）**：长期有效的知识和方法论，按主题分类，持续积累
- **示例内容**：仓库里带"示例"字样的文件仅用于展示格式，替换成你自己的真实内容即可

## 使用建议

1. 先看一遍 `CLAUDE.md` 和 `AGENTS.md`，了解 Agent 的行为准则
2. 用几天 `memory_add.sh` / `memory_search.sh`，培养随手记录的习惯
3. 把 `notes/` 下的示例笔记换成自己的分类和内容
4. 需要写周报时，复制 `work/work_report/weekly/` 下的示例改名使用，或直接让 Agent 调用 `jvs-weekly-report` 技能生成

## 文档

- [CLAUDE.md](CLAUDE.md) - Claude Code 行为准则与项目说明
- [AGENTS.md](AGENTS.md) - 数字分身人格定义
- [.agents/skills/](.agents/skills/) - 各技能的详细说明

## License

按你自己的需要设置，本模板不预设 License。
