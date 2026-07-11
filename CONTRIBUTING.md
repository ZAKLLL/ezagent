# 贡献指南

感谢你对 EzAgent 感兴趣。这是一个个人数字分身模板，贡献时请先了解它的定位（见 [README.md](README.md#这本质是什么)）：这不是一个 Agent 程序，而是一份给 AI Agent 读取的结构化文档/配置库。

## 贡献前的几个原则

- **保持通用、简单**：这是模板，不是某个人的真实数字分身。新增内容（示例笔记、模板、Skill）要保持虚构/占位性质，不要引入真实姓名、公司、联系方式等个人信息
- **不引入编码/工程向内容**：定位是面向非技术个人用户，不要加代码统计、CI 集成之类的功能
- **不引入多环境/多场景概念**：`memory/`、`notes/`、`work/` 都是唯一真值，不要重新引入 company/home 之类的环境隔离
- **能力扩展优先走 Skills**：新的自动化能力优先做成 `.agents/skills/` 下的 Skill，而不是散落的脚本

## 提交规范

Commit message 用 `.gitmessage` 模板的格式：

```
类型: 简要描述（不超过 72 个字符）

详细描述（可选）
- 具体改动点 1
- 具体改动点 2
```

类型标识：`feat` | `fix` | `docs` | `refactor` | `chore`

示例：

```
feat: 新增会议纪要自动归类 skill

- 新增 .agents/skills/jvs-meeting-notes/SKILL.md
- 更新 CLAUDE.md 可用技能列表
```

## 提交 PR 前自检

- [ ] 没有引入真实个人信息（姓名、手机号、邮箱、公司、真实路径等）
- [ ] 没有提交真实的密钥/Token（真实 Provider 配置应遵循 `.gitignore` 规则，只提交 `*.example.json`）
- [ ] 涉及目录结构变化时，同步更新了 `README.md` / `CLAUDE.md` / `AGENTS.md`（可以直接让 Agent 调用 `jvs-update-doc` 技能检查）
- [ ] 运行过 `./agent_stats.sh`，确认脚本正常输出、没有报错
- [ ] 新增/修改的 Skill 遵循现有 `SKILL.md` 的 frontmatter 格式（`name` + `description`）

## 新增一个 Skill

推荐直接用仓库自带的 `skill-creator` 技能来创建和迭代，而不是手写。基本流程：

1. 明确这个 Skill 解决什么问题、什么时候应该被触发
2. 在 `.agents/skills/<skill-name>/SKILL.md` 写草稿（参考现有 Skill 的结构）
3. 如果需要在 Claude Code 里直接可用，确认 `agent_stats.sh` 的自动软链接机制会把它同步到 `~/.claude/skills/`
4. 用几个真实场景验证触发是否符合预期，再提交

## 报告问题

提 Issue 时尽量包含：用的是哪个 Agent 工具（Claude Code / Codex / opencode / 其他）、复现步骤、期望行为与实际行为的差异。

## 行为准则

保持友善和建设性的讨论氛围，不做人身攻击。没有更复杂的行为准则文档——这是一个小而简单的模板项目，希望贡献流程也一样简单。
