# EzAgent - 通用白领数字分身

一个面向非技术、泛白领知识工作者的个人数字助手模板。本质上是一个文档库：用 Markdown 文件 + Shell 脚本 + AI Agent 技能定义，驱动 Claude Code（或其他支持 Agent Skills 的工具）帮你管理记忆、笔记、周报和常用信息。

不涉及编码/软件工程场景，开箱即用，也可以随时按自己的习惯调整。

## 核心特性

- **记忆系统**：按日期记录工作中的关键事件、决策、待办，跨会话保留上下文
- **知识笔记**：按主题分类沉淀行业认知、工作方法、职业发展记录
- **周报/OKR**：结合工作说明自动生成周报，配套 OKR 与阶段性复盘模板
- **常用文档模板**：会议纪要、简历、求职记录等
- **AI Agent 技能库**：预置一组 Claude Code Skills，覆盖记忆、笔记、周报、仓库维护等场景

## 快速开始

### 1. 查看当前状态
```bash
./agent_stats.sh
```
显示记忆/笔记/书签统计和 Git 状态，同时自动把 `.agents/skills/` 下的技能软链接到 `~/.claude/skills/`。

### 2. 记录一条记忆
```bash
./memory_add.sh
```

### 3. 搜索记忆
```bash
./memory_search.sh 关键词
./memory_search.sh -r 7   # 最近 7 天
```

### 4. 用 Claude Code 打开本仓库
在仓库根目录启动 Claude Code，它会自动读取 `CLAUDE.md` 了解行为准则，并可以调用 `.agents/skills/` 下的技能（如 `/jvs` 快速入口）。

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
