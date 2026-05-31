#!/bin/bash
# =============================================================
# sync-obsidian.sh — Obsidian Vault と claude-configuration を同期
#
# 使い方:
#   ./scripts/sync-obsidian.sh            # Vaultから取り込み (pull)
#   ./scripts/sync-obsidian.sh --push     # Vaultへ書き出し (push)
#   ./scripts/sync-obsidian.sh --status   # 差分確認
#
# 前提:
#   OBSIDIAN_VAULT 環境変数、または下記 VAULT_PATH を設定する
# =============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_ROOT="$(dirname "$SCRIPT_DIR")"

# ── Obsidian Vault パス設定 ────────────────────────────────────
# 優先順位: 環境変数 > iCloud > ローカル
if [ -n "${OBSIDIAN_VAULT:-}" ]; then
  VAULT_PATH="$OBSIDIAN_VAULT"
elif [ -d "${HOME}/Library/Mobile Documents/iCloud~md~obsidian/Documents/Main" ]; then
  VAULT_PATH="${HOME}/Library/Mobile Documents/iCloud~md~obsidian/Documents/Main"
elif [ -d "${HOME}/ObsidianVault" ]; then
  VAULT_PATH="${HOME}/ObsidianVault"
else
  echo "Obsidian Vault が見つかりません。"
  echo "OBSIDIAN_VAULT 環境変数を設定するか、~/ObsidianVault を作成してください。"
  exit 1
fi

VAULT_CLAUDE_DIR="${VAULT_PATH}/claude"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
ok()   { echo -e "${GREEN}✓${NC} $1"; }
info() { echo -e "${YELLOW}→${NC} $1"; }

# ── Vault → Config (pull): Obsidianで編集した内容を取り込む
pull_from_vault() {
  info "Vault → config-repo へ同期中..."
  if [ ! -d "$VAULT_CLAUDE_DIR" ]; then
    echo "Vault に claude/ ディレクトリがありません: ${VAULT_CLAUDE_DIR}"
    exit 1
  fi
  rsync -av --exclude=".obsidian" \
    "${VAULT_CLAUDE_DIR}/prompts/" "${CONFIG_ROOT}/prompts/"
  [ -f "${VAULT_CLAUDE_DIR}/CLAUDE.md" ] && \
    cp "${VAULT_CLAUDE_DIR}/CLAUDE.md" "${CONFIG_ROOT}/CLAUDE.md"
  ok "取り込み完了"
}

# ── Config → Vault (push): GitHubの最新をObsidianに書き出す
push_to_vault() {
  info "config-repo → Vault へ書き出し中..."
  mkdir -p "$VAULT_CLAUDE_DIR"
  rsync -av "${CONFIG_ROOT}/prompts/" "${VAULT_CLAUDE_DIR}/prompts/"
  cp "${CONFIG_ROOT}/CLAUDE.md" "${VAULT_CLAUDE_DIR}/CLAUDE.md"
  ok "書き出し完了 → ${VAULT_CLAUDE_DIR}"
}

# ── 差分確認
status() {
  if [ ! -d "$VAULT_CLAUDE_DIR" ]; then
    echo "Vault の claude/ ディレクトリが未作成です。"
    return
  fi
  echo "=== Vault ↔ config-repo の差分 ==="
  diff -rq --exclude=".obsidian" \
    "${VAULT_CLAUDE_DIR}/prompts" "${CONFIG_ROOT}/prompts" || true
  diff "${VAULT_CLAUDE_DIR}/CLAUDE.md" "${CONFIG_ROOT}/CLAUDE.md" || true
  echo "================================="
}

case "${1:-}" in
  --push)   push_to_vault ;;
  --status) status ;;
  *)        pull_from_vault ;;
esac
