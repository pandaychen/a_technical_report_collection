#!/usr/bin/env bash
# claude-code-ebpf-analyze.sh
# 基于 ebpf/cursor-ebpf-project-analysis-prompt-template.md 生成的 Claude Code 辅助脚本。
# 用法：在「被分析的目标项目」目录下执行，或设置 EBPF_ANALYZE_CWD 指向该目录。
#
# 环境变量：
#   CLAUDE_CODE_BIN   默认可执行名 claude-code-internal（可写绝对路径）
#   EBPF_CLAUDE_COMMANDS_DIR  斜杠命令目录，默认为本仓库 .claude/commands
#   EBPF_ANALYZE_CWD    作为工作目录传给 claude（默认当前目录）

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
COMMANDS_DIR="${EBPF_CLAUDE_COMMANDS_DIR:-$REPO_ROOT/.claude/commands}"
CLAUDE_BIN="${CLAUDE_CODE_BIN:-claude-code-internal}"
WORKDIR="${EBPF_ANALYZE_CWD:-$PWD}"

usage() {
  cat <<'EOF'
用法:
  claude-code-ebpf-analyze.sh list
  claude-code-ebpf-analyze.sh print <阶段> <项目名> <仓库URL> [额外参数...]
  claude-code-ebpf-analyze.sh run   <阶段> <项目名> <仓库URL> [额外参数...]

阶段 (phase):
  1 architecture | 2 hooks | 3 maps | 4 userspace | 5 features
  6 security     | 7 quality | 8 report
  sup-hids | sup-network | sup-fim | sup-rootkit

print: 将替换占位符后的提示词打印到 stdout（便于复制进 Claude Code）。
run:   将提示词通过管道交给 CLAUDE_CODE_BIN；若二进制支持常见非交互参数会尝试附加。

示例:
  cd /path/to/tetragon
  EBPF_ANALYZE_CWD="$PWD" /path/to/claude-code-ebpf-analyze.sh print 1 Tetragon https://github.com/cilium/tetragon
  EBPF_ANALYZE_CWD="$PWD" /path/to/claude-code-ebpf-analyze.sh run 2 Tetragon https://github.com/cilium/tetragon

说明:
  - 请先在被分析仓库根目录 clone 完整代码后再运行 run/print。
  - 阶段 5 的「额外参数」会填入提示词中的 $3；阶段 8 第三个参数可作为输出目录提示。
EOF
}

resolve_file() {
  local p="$1"
  case "$p" in
    1|architecture|phase1) echo "ebpf-phase1-architecture.md" ;;
    2|hooks|phase2) echo "ebpf-phase2-hooks.md" ;;
    3|maps|phase3) echo "ebpf-phase3-maps.md" ;;
    4|userspace|phase4) echo "ebpf-phase4-userspace.md" ;;
    5|features|phase5) echo "ebpf-phase5-features.md" ;;
    6|security|phase6) echo "ebpf-phase6-security.md" ;;
    7|quality|phase7) echo "ebpf-phase7-quality.md" ;;
    8|report|phase8) echo "ebpf-phase8-report.md" ;;
    sup-hids|hids) echo "ebpf-supplement-hids.md" ;;
    sup-network|network) echo "ebpf-supplement-network.md" ;;
    sup-fim|fim) echo "ebpf-supplement-fim.md" ;;
    sup-rootkit|rootkit) echo "ebpf-supplement-rootkit.md" ;;
    *) echo ""; return 1 ;;
  esac
}

build_prompt() {
  local file="$1" name="$2" repo="$3" extra="${4-}"
  local path="$COMMANDS_DIR/$file"
  if [[ ! -f "$path" ]]; then
    echo "错误: 找不到命令文件: $path" >&2
    exit 1
  fi
  if command -v python3 >/dev/null 2>&1; then
    python3 - "$path" "$name" "$repo" "$extra" <<'PY'
import re
import sys
from pathlib import Path

path, name, repo, extra = sys.argv[1:5]
text = Path(path).read_text(encoding="utf-8")
if text.lstrip().startswith("---"):
    text = re.sub(r"^---\n.*?\n---\n", "", text, count=1, flags=re.DOTALL)
text = text.replace("$1", name).replace("$2", repo).replace("$3", extra)
sys.stdout.write(text)
PY
  else
    # 无 python3 时的退化：仅做简单替换（避免在值中出现 & 等字符）
    local body
    body="$(awk '
      /^---$/ { if (fm==0) { fm=1; skip=1; next } if (fm==1) { skip=0; next } }
      skip==0 { print }
    ' "$path")"
    body="${body//\$1/$name}"
    body="${body//\$2/$repo}"
    body="${body//\$3/$extra}"
    printf '%s' "$body"
  fi
}

cmd_list() {
  echo "命令目录: $COMMANDS_DIR"
  echo ""
  ls -1 "$COMMANDS_DIR"/*.md 2>/dev/null | while read -r f; do
    basename "$f"
  done
}

main() {
  local sub="${1:-}"
  [[ -n "$sub" ]] || { usage; exit 1; }
  case "$sub" in
    -h|--help|help) usage; exit 0 ;;
    list) cmd_list; exit 0 ;;
    print|run) ;;
    *) usage; exit 1 ;;
  esac

  local phase="${2:-}"
  local name="${3:-}"
  local repo="${4:-}"
  if [[ -z "$phase" || -z "$name" ]]; then
    echo "错误: 缺少参数。需要: $sub <阶段> <项目名> <仓库URL> [额外...]" >&2
    exit 1
  fi
  # 补充类命令仅需项目名，仓库 URL 可传占位符「-」
  if [[ -z "$repo" ]]; then
    case "$phase" in
      sup-hids|hids|sup-network|network|sup-fim|fim|sup-rootkit|rootkit) repo="-" ;;
      *)
        echo "错误: 缺少仓库 URL。补充类阶段可传「-」占位。" >&2
        exit 1
        ;;
    esac
  fi
  shift 4
  local extra="$*"

  local fname
  fname="$(resolve_file "$phase")" || { echo "错误: 未知阶段: $phase" >&2; exit 1; }

  local prompt
  prompt="$(build_prompt "$fname" "$name" "$repo" "$extra")"

  if [[ "$sub" == "print" ]]; then
    printf '%s\n' "$prompt"
    exit 0
  fi

  # run
  if ! command -v "$CLAUDE_BIN" >/dev/null 2>&1; then
    echo "警告: 未在 PATH 中找到 \"$CLAUDE_BIN\"，仅打印提示词。可通过 CLAUDE_CODE_BIN 指定路径。" >&2
    printf '%s\n' "$prompt"
    exit 0
  fi

  cd "$WORKDIR"
  # 尝试常见非交互入口：优先 --print，其次 -p
  if "$CLAUDE_BIN" --help 2>&1 | grep -q -- '--print'; then
    printf '%s\n' "$prompt" | "$CLAUDE_BIN" --print
  elif "$CLAUDE_BIN" --help 2>&1 | grep -qE '^[[:space:]]*-p'; then
    printf '%s\n' "$prompt" | "$CLAUDE_BIN" -p "$(printf '%s\n' "$prompt")"
  else
    echo "请将下列提示词粘贴到 $CLAUDE_BIN 交互会话中（工作目录: $WORKDIR）：" >&2
    echo "---" >&2
    printf '%s\n' "$prompt"
  fi
}

main "$@"
