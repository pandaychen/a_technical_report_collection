# 问答：基于 cursor-ebpf-project-analysis-prompt-template 生成 claude-code-internal 工具

**日期**：2026-03-27

## 需求

使用 `ebpf/cursor-ebpf-project-analysis-prompt-template.md`，生成可供 `claude-code-internal`（Claude Code）使用的工具。

## 交付物

1. **Claude Code 斜杠命令**（项目根目录 `.claude/commands/`）
   - `/ebpf-phase1-architecture` … `/ebpf-phase8-report`：对应模板阶段一至八。
   - `/ebpf-supplement-hids`、`sup-network`、`sup-fim`、`sup-rootkit`：对应模板中的补充提示词。
   - 用法：在 Claude Code 中输入斜杠命令后接参数，例如：  
     `/ebpf-phase1-architecture Tetragon https://github.com/cilium/tetragon`

2. **Shell 包装脚本**（`ebpf/scripts/claude-code-ebpf-analyze.sh`）
   - `list`：列出命令文件。
   - `print <阶段> <项目名> <仓库URL> [额外…]`：打印替换占位符后的完整提示词（可复制到交互会话）。
   - `run …`：在存在 `CLAUDE_CODE_BIN`（默认 `claude-code-internal`）时尝试非交互调用；否则回退为打印提示词。
   - 环境变量：`CLAUDE_CODE_BIN`、`EBPF_CLAUDE_COMMANDS_DIR`、`EBPF_ANALYZE_CWD`。

## 说明

- 分析目标代码时，应在**被分析仓库根目录**下启动 Claude Code，或将 `EBPF_ANALYZE_CWD` 指向该目录。
- 补充类斜杠命令仅需项目名时，仓库 URL 可传 `-` 占位。
