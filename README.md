# itochu0523-claude-configuration

> Claude Code / claude.ai の設定を一元管理し、全プロジェクトへワンコマンドで配布するリポジトリ。

---

## この構成でできること

| やりたいこと | 方法 |
|---|---|
| 全プロジェクトの Claude 設定を統一したい | `CLAUDE.md` を1ファイル編集するだけ |
| 新しいリポジトリにすぐ設定を追加したい | `make deploy` を実行するだけ |
| スマホやサブ機でもプロンプトを参照したい | Obsidian でどこでも閲覧・編集 |
| チームに説明したい | このREADME + スライドで共有 |

---

## ディレクトリ構成

```
claude-configuration/
├── CLAUDE.md                          # Claude Code が自動で読み込む共通設定
├── mcp.json                           # MCP サーバー接続設定
├── Makefile                           # ショートカットコマンド集
├── .gitignore
│
├── prompts/
│   ├── roles/
│   │   ├── ml_engineer.md             # ML エンジニアロール
│   │   └── enterprise_consultant.md   # クライアント向けロール
│   └── tasks/
│       ├── code_review.md             # コードレビューテンプレート
│       ├── spec_writer.md             # 仕様書作成テンプレート
│       └── bigquery_sql.md            # BigQuery SQL テンプレート
│
└── scripts/
    ├── deploy.sh                      # 設定を各リポジトリへ配布
    └── sync-obsidian.sh               # Obsidian Vault との同期
```

---

## クイックスタート

### 初回セットアップ

```bash
git clone https://github.com/itochu0523/itochu0523-claude-configuration.git
cd itochu0523-claude-configuration
make setup
```

### 設定を配布する

```bash
make deploy              # 全プロジェクトへ配布
make deploy-github-io    # itochu0523.github.io のみ
make deploy-dmc          # dmc-ops-workflow のみ
make deploy-mcp          # MCP設定のみ (~/.claude/mcp.json)
```

### 新しいリポジトリを追加する

`scripts/deploy.sh` の2箇所に1行ずつ追加するだけ：

```bash
REPO_NAMES=(
  "itochu0523.github.io"
  "dmc-ops-workflow"
  "new-project"           # ← 追加
)
REPO_PATHS=(
  "${HOME}/workspace/itochu0523.github.io"
  "${HOME}/dev/dmc-ops-workflow"
  "${HOME}/workspace/new-project"   # ← 追加
)
```

---

## 管理しているプロジェクト

| リポジトリ | オーナー | 概要 |
|---|---|---|
| [itochu0523.github.io](https://github.com/itochu0523/itochu0523.github.io) | itochu0523（個人） | 自作アプリ群のポータル |
| [dmc-ops-workflow](https://github.com/lazuli-inc/dmc-ops-workflow) | lazuli-inc（Organization） | DMC業務ワークフロー管理 |
| gcp-product-master（予定） | 未定 | GCP上の商品マスターデータ基盤 |

### GitHub アカウント構成

```
同一アカウントで2つの組織を管理
├── github.com/itochu0523/     ← 個人リポジトリ
└── github.com/lazuli-inc/     ← Organization リポジトリ
```

---

## CLAUDE.md の内容

Claude Code が起動時に自動で読み込む設定ファイル。

- **ロール**: フルスタックエンジニア最高峰として動作
- **言語**: 日本語で簡潔に回答
- **コードルール**: コメント日本語・パフォーマンス最優先・UI は美しく
- **透明性**: 何をするか・なぜするかを必ず事前に説明

---

## Obsidian 連携（オプション）

> Obsidian は未インストールでも他の機能はすべて動く。インストール後にいつでも連携できる。

### インストール

[obsidian.md](https://obsidian.md) からダウンロード。

### 初期設定

```bash
# Vault ディレクトリを作成
mkdir -p ~/ObsidianVault

# 環境変数を設定（~/.zshrc に追記）
echo 'export OBSIDIAN_VAULT="${HOME}/ObsidianVault"' >> ~/.zshrc
source ~/.zshrc

# 設定ファイルを Vault へ初回書き出し
make obsidian-push
```

Obsidian を起動 → "Open folder as vault" → `~/ObsidianVault` を選択。

### Obsidian Git プラグインで自動同期

1. Settings → Community plugins → Browse → `Obsidian Git` をインストール
2. Auto pull interval: **10分**、Auto push after commit: **ON** に設定

### 同期コマンド

```bash
make obsidian-push    # config → Obsidian へ書き出し
make obsidian-pull    # Obsidian で編集した内容を config へ取り込み
make obsidian-status  # 差分確認
```

---

## make コマンド一覧

```bash
make help              # コマンド一覧を表示

# デプロイ
make deploy            # 全プロジェクトへ配布
make deploy-github-io  # itochu0523.github.io のみ
make deploy-dmc        # dmc-ops-workflow のみ
make deploy-mcp        # MCP設定のみ更新

# Obsidian 同期
make obsidian-push     # config → Vault
make obsidian-pull     # Vault → config
make obsidian-status   # 差分確認

# その他
make list              # 登録済みリポジトリ一覧
make setup             # 初回セットアップ
```

---

## 自動デプロイ（git hook）

`make setup` 実行後は、**git commit するたびに自動で `make deploy` が走る**。

```bash
git add .
git commit -m "feat: update CLAUDE.md"
# ↑ この瞬間に全プロジェクトへ自動配布される
git push
```

無効にしたい場合：

```bash
rm .git/hooks/post-commit
```

---

## トラブルシューティング

**スクリプトが Permission denied になる**
```bash
chmod +x scripts/deploy.sh scripts/sync-obsidian.sh
```

**Obsidian Vault が見つからないと言われる**
```bash
export OBSIDIAN_VAULT="/path/to/your/vault"
```

**特定のリポジトリだけ設定を変えたい**

そのリポジトリの `CLAUDE.md` を直接編集する。
`make deploy` は上書きするため、再デプロイ時に差分が消える点に注意。
プロジェクト固有の設定は `## プロジェクト固有設定` セクションを末尾に追加して管理するのを推奨。

---

## MCP サーバー設定

`mcp.json` で管理。`make deploy` または `make deploy-mcp` で `~/.claude/mcp.json` に配置される。

| サービス | URL |
|---|---|
| Slack | https://mcp.slack.com/mcp |
| Google Drive | https://drivemcp.googleapis.com/mcp/v1 |
| Gmail | https://gmailmcp.googleapis.com/mcp/v1 |
| Google Calendar | https://calendarmcp.googleapis.com/mcp/v1 |
