# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

EzAgent - 通用白领数字分身模板，一个面向非技术、泛白领知识工作者的个人数字助手，用于管理日常工作中的记忆、笔记、周报和常用信息。

**本质是一份结构化的个人知识库 / 上下文工程配置**（记忆约定、笔记分类、Agent Skills），不包含任何模型调用/推理编排代码，不是一个独立运行的 Agent 程序——需要交给 Claude Code 这类已具备推理能力的工具来读取和执行。

## 核心命令

### Agent 初始化
```bash
./agent_stats.sh           # 完整状态面板
./agent_stats.sh --json    # JSON 格式输出
```
进入此目录时首先执行，输出当前仓库信息供 Agent 解析。

> **自动维护**：每次执行 `agent_stats.sh` 时会自动将 `.agents/skills/` 下所有技能软链接到 `~/.claude/skills/`，无需手动操作。

### 记忆管理
```bash
./memory_add.sh                    # 添加记忆
./memory_search.sh 关键词           # 搜索记忆
./memory_search.sh -r 7            # 查看最近 7 天
./memory_search.sh -t "#标签"       # 按标签搜索
```

### 定时任务
```bash
./cron_manage.sh   # 管理定时任务
./cron_query.sh     # 查询定时任务状态
```

### Git 操作
```bash
git add .                # 添加所有更改
git commit               # 提交（会触发格式检查）
git push                 # 推送到远程（如已配置）
git pull                 # 拉取远程更新（如已配置）
```

## 架构结构

```
ezagent/
├── memory/            # 记忆文件（mem_YYYY_MM_DD.md），含示例条目
├── notes/             # 知识笔记，按主题分类，每类含示例笔记
├── work/
│   ├── bookmarks/      # 常用链接
│   ├── documents/      # 文档模板（会议纪要、简历模板等）
│   ├── interview/      # 求职记录模板
│   └── work_report/    # 周报/OKR/阶段复盘模板与示例
├── config/
│   ├── cron/           # 定时任务配置
│   └── llm_provider/   # AI 助手 Provider 配置示例
├── lib/                # Shell 函数库
├── .agents/skills/     # AI Agent 技能库
├── .claude/skills/     # 技能镜像（软链接自 .agents/skills/）
├── .githooks/          # Git hooks（提交前记忆检查等）
├── *.sh                # 核心脚本
└── CLAUDE.md           # 本文件
```

### 记忆系统
记忆文件按日期存储：`mem_YYYY_MM_DD.md`，统一存放在 `memory/`，不区分环境/场景。

### 函数库
`lib/` - 可复用的状态函数库，包含：
- 统计函数（`count_files`, `get_latest_file`）
- 显示函数（`show_content_stats`, `show_memory_details`, `show_system_info`）
- 输出函数（`output_agent_context`, `output_json`）

## 提交信息格式

使用 `.gitmessage` 模板，格式：`类型: 描述`

类型标识：`feat` | `fix` | `docs` | `refactor` | `chore`

示例：
```
feat: 新增本周周报

---
Context:
  Time: 2026-07-11 10:30:00
```

## 行为准则

### 脚本优先原则（强制执行）

执行数字分身相关操作时，必须遵循以下优先级：
1. 使用仓库提供的专用脚本
2. 使用仓库提供的共享脚本（`lib/`）
3. 使用 Bash 工具

必须优先使用仓库脚本的操作：
- 记忆管理 → `./memory_add.sh`, `./memory_search.sh`
- 状态查看 → `./agent_stats.sh`

直接使用 Git 命令的操作：
- Git 操作 → `git add`, `git commit`, `git push`, `git pull`

### 大变更后更新记忆（强制执行）

以下情况发生后，必须调用 `./memory_add.sh` 写入记忆：

- 新增或修改超过 5 个文件
- 涉及核心目录（`memory/`、`notes/`、`work/`）
- 周报、复盘、简历等重要内容的新增或更新
- 目录结构的调整

记忆内容要求：说明做了什么、为什么做、产出是什么，不写流水账。

## 可用技能

- `jvs` - 快速入口，进入仓库、加载记忆、准备接受任务
- `jvs-memory` - 记忆系统使用规范
- `jvs-notes` - 知识笔记管理
- `jvs-keep-clean` - 保持仓库结构清洁
- `jvs-update-doc` - 文档更新维护
- `jvs-weekly-report` - 周报生成
- `skill-creator` - 创建/优化 Agent 技能

## 依赖

- `bash` - 脚本运行环境
- `git` - 版本控制
