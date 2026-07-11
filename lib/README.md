# 函数库目录

本目录包含 EzAgent 数字分身系统的可复用 Bash 函数库。

## 函数库列表

| 文件 | 说明 |
|------|------|
| [common.sh](common.sh) | 基础工具函数（颜色定义、文件统计等） |
| [platform_info.sh](platform_info.sh) | 平台/系统信息检测函数 |
| [content_info.sh](content_info.sh) | 内容统计函数（笔记/书签/记忆计数、远程 commit） |
| [memory_info.sh](memory_info.sh) | 记忆系统统计函数 |
| [output.sh](output.sh) | 输出格式化函数（含 JSON 输出） |
| [actions.sh](actions.sh) | 帮助文本与 skill 软链接同步 |

## 使用方式

这些函数库主要被 `agent_stats.sh` 加载使用：

```bash
source lib/common.sh
source lib/platform_info.sh
source lib/content_info.sh
source lib/memory_info.sh
source lib/output.sh
source lib/actions.sh
```

## 主要功能

### common.sh
- 颜色定义（RED, GREEN, YELLOW, BLUE, etc.）
- `count_files()` - 统计目录文件数
- `get_latest_file()` - 获取最新文件

### platform_info.sh
- 操作系统检测
- 架构检测
- 系统信息显示

### content_info.sh
- 远程仓库最新 commit 信息
- 笔记/书签/记忆的数量统计

### memory_info.sh
- 记忆文件统计
- 记忆详情显示
- 记忆更新提示

### output.sh
- JSON 格式输出（`--json`）
- 格式化显示

### actions.sh
- 帮助文本（`--help`）
- 自动同步 `.agents/skills/` 到 `.claude/skills/` 的软链接
