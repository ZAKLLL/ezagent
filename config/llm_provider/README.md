# LLM Provider 配置

存放不同 LLM 厂商的 Claude Code settings.json 配置模板。切换到对应 provider 时，复制模板、填入自己的 API Key，再拷贝到 `~/.claude/settings.json` 即可。

## 使用方式

```bash
# 以 DeepSeek 为例
cp config/llm_provider/deepseek_claude_settings.example.json config/llm_provider/deepseek_claude_settings.json
# 编辑 deepseek_claude_settings.json，填入你自己的 API Key
cp config/llm_provider/deepseek_claude_settings.json ~/.claude/settings.json
```

真实的 `*_claude_settings.json`（含真实 Key）已被 `.gitignore` 排除，不会被提交，只有 `*.example.json` 模板会入库。

## 配置文件列表

| 文件 | Provider | 基座 URL |
|------|----------|---------|
| `deepseek_claude_settings.example.json` | DeepSeek | api.deepseek.com/anthropic |

## 关键字段说明

- `ANTHROPIC_BASE_URL` — Anthropic API 兼容端点地址
- `ANTHROPIC_AUTH_TOKEN` — API Key（务必只填在本地文件里，不要提交到 git）
- `ANTHROPIC_MODEL` — 默认模型（主对话）
- `ANTHROPIC_DEFAULT_OPUS_MODEL` / `SONNET` / `HAIKU` — 各档位模型映射
- `CLAUDE_CODE_SUBAGENT_MODEL` — 子 Agent 使用的轻量模型
- `CLAUDE_CODE_EFFORT_LEVEL` — 推理力度（max/medium/low）
