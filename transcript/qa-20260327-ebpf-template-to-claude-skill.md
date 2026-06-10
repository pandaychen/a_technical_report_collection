# 问答：将 cursor-ebpf-project-analysis-prompt-template 转为 Claude Skill 并项目/全局生效

**日期**：2026-03-27

## 需求

把 `ebpf/cursor-ebpf-project-analysis-prompt-template.md` 转为 Claude 的 skills 文档，并在项目下或全局生效。

## 交付

1. **Claude Code Skill**（`.claude/skills/ebpf-project-analysis/`）
   - `SKILL.md`：YAML frontmatter + 角色、分阶段工作流、指向完整提示词。
   - `reference-phases.md`：由模板复制，供全局离线使用；模板头注明与 `ebpf/cursor-ebpf-project-analysis-prompt-template.md` 的关系。
   - `README.md`：安装到 `~/.claude/skills/` 与重启说明。

2. **Cursor Agent Skill**（`.cursor/skills/ebpf-project-analysis/`）：与上相同内容，全局路径为 `~/.cursor/skills/`。

3. **模板文件**末尾增加「Claude Code / Cursor Skill 集成」表格与指向 `README.md` 的说明。

## 生效方式摘要

- **项目内**：仓库根下已有 `.claude/skills/` / `.cursor/skills/`，由对应客户端加载（视版本支持情况）。
- **全局**：`cp -R` 到 `~/.claude/skills/ebpf-project-analysis` 或 `~/.cursor/skills/ebpf-project-analysis`，重启客户端。
