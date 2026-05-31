# =============================================================
# Makefile — claude-configuration ショートカット
# 使い方: make <target>
# =============================================================

.PHONY: help deploy deploy-mcp obsidian-push obsidian-pull obsidian-status \
        list setup fmt

# デフォルト: ヘルプ表示
help:
	@echo ""
	@echo "  Claude Configuration — コマンド一覧"
	@echo "  ──────────────────────────────────────"
	@echo "  make deploy              全リポジトリへ CLAUDE.md + prompts を配布"
	@echo "  make deploy-mcp          MCP設定のみ更新 (~/.claude/mcp.json)"
	@echo "  make deploy-<name>       特定リポジトリへのみ配布 (例: make deploy-asahi)"
	@echo "  make list                登録済みリポジトリ一覧"
	@echo ""
	@echo "  make obsidian-push       config → Obsidian Vault へ書き出し"
	@echo "  make obsidian-pull       Obsidian Vault → config へ取り込み"
	@echo "  make obsidian-status     Vault との差分確認"
	@echo ""
	@echo "  make setup               初回セットアップ (chmod + git hooks)"
	@echo "  make fmt                 Markdown lint (markdownlint)"
	@echo ""

# ── デプロイ ──────────────────────────────────────────────────
deploy:
	@bash scripts/deploy.sh

deploy-mcp:
	@bash scripts/deploy.sh --mcp-only

deploy-asahi:
	@bash scripts/deploy.sh asahidrink

deploy-dashboard:
	@bash scripts/deploy.sh dmc-work-dashboard

deploy-master-api:
	@bash scripts/deploy.sh dmc-master-api

list:
	@bash scripts/deploy.sh --list

# ── Obsidian 同期 ─────────────────────────────────────────────
obsidian-push:
	@bash scripts/sync-obsidian.sh --push

obsidian-pull:
	@bash scripts/sync-obsidian.sh

obsidian-status:
	@bash scripts/sync-obsidian.sh --status

# ── セットアップ ──────────────────────────────────────────────
setup:
	@chmod +x scripts/deploy.sh scripts/sync-obsidian.sh
	@mkdir -p .git/hooks
	@echo '#!/bin/bash\nmake deploy' > .git/hooks/post-commit
	@chmod +x .git/hooks/post-commit
	@echo "✓ セットアップ完了 (git post-commit hook 登録済み)"
	@echo "  git commit 後に自動で make deploy が走ります"

fmt:
	@which markdownlint > /dev/null 2>&1 && markdownlint '**/*.md' || \
		echo "markdownlint 未インストール: npm install -g markdownlint-cli"
