#!/bin/bash
# =============================================================
# deploy.sh — Claude 設定を各作業リポジトリへ配布する
#
# 使い方:
#   ./scripts/deploy.sh                    # 全リポジトリへ配布
#   ./scripts/deploy.sh asahidrink         # 名前でフィルタ
#   ./scripts/deploy.sh --path /path/repo  # パス直接指定
#   ./scripts/deploy.sh --mcp-only         # MCP設定のみ更新
#   ./scripts/deploy.sh --list             # 登録済みリポジトリ一覧
# =============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_ROOT="$(dirname "$SCRIPT_DIR")"
CLAUDE_HOME="${HOME}/.claude"

# ── 配布先リポジトリ（名前:パス の形式で列挙）────────────────
# 追加する場合はここに1行足すだけ
REPO_NAMES=(
  "itochu0523.github.io"
  "dmc-ops-workflow"
)
REPO_PATHS=(
  # "${HOME}/workspace/itochu0523.github.io"
  # "${HOME}/workspace/dmc-ops-workflow"
  "/Users/ito_1/Desktop/itochu0523-documents/Itochu0523/workspace/itochu0523.github.io/"
  "/Users/ito_1/dev/dmc-ops-workflow"
)

# ── カラー出力 ────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
ok()   { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC}  $1"; }

# ── MCP 設定をホームに配置 ────────────────────────────────────
deploy_mcp() {
  mkdir -p "$CLAUDE_HOME"
  cp "${CONFIG_ROOT}/mcp.json" "${CLAUDE_HOME}/mcp.json"
  ok "mcp.json → ${CLAUDE_HOME}/mcp.json"
}

# ── CLAUDE.md + prompts を指定リポジトリへコピー ─────────────
deploy_to() {
  local name="$1"
  local target="$2"

  if [ ! -d "$target" ]; then
    warn "スキップ: ${name} (${target} が存在しません)"
    return
  fi

  cp "${CONFIG_ROOT}/CLAUDE.md" "${target}/CLAUDE.md"
  ok "CLAUDE.md → ${target}/"

  if [ -d "${CONFIG_ROOT}/prompts" ]; then
    mkdir -p "${target}/.claude/prompts"
    rsync -a --delete "${CONFIG_ROOT}/prompts/" "${target}/.claude/prompts/"
    ok "prompts/  → ${target}/.claude/prompts/"
  fi
}

# ── 一覧表示 ─────────────────────────────────────────────────
list_repos() {
  echo "登録済みリポジトリ:"
  for i in "${!REPO_NAMES[@]}"; do
    name="${REPO_NAMES[$i]}"
    path="${REPO_PATHS[$i]}"
    if [ -d "$path" ]; then
      echo "  ✓ ${name}: ${path}"
    else
      echo "  - ${name}: ${path} (ディレクトリ未存在)"
    fi
  done
}

# ── メイン処理 ────────────────────────────────────────────────
main() {
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo " Claude 設定 deploy — $(date '+%Y-%m-%d %H:%M:%S')"
  echo " config root: ${CONFIG_ROOT}"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  case "${1:-}" in
    --list)
      list_repos
      exit 0
      ;;
    --mcp-only)
      deploy_mcp
      exit 0
      ;;
    --path)
      deploy_mcp
      deploy_to "$(basename "$2")" "$2"
      exit 0
      ;;
    "")
      deploy_mcp
      for i in "${!REPO_NAMES[@]}"; do
        deploy_to "${REPO_NAMES[$i]}" "${REPO_PATHS[$i]}"
      done
      ;;
    *)
      deploy_mcp
      for i in "${!REPO_NAMES[@]}"; do
        if [[ "${REPO_NAMES[$i]}" == *"$1"* ]]; then
          deploy_to "${REPO_NAMES[$i]}" "${REPO_PATHS[$i]}"
        fi
      done
      ;;
  esac

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo " 完了"
}

main "$@"
