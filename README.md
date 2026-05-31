# itochu0523-claude-configuration

> Claude Code / claude.ai の設定を一元管理し、全プロジェクトへワンコマンドで配布するリポジトリ。

---

## 📊 構成フロー図・スライド資料（11枚）

全体構成・MCP サーバー・Obsidian 連携をビジュアルで解説。

**[▶ スライドを見る → itochu0523.github.io/docs/obsidian.html](https://itochu0523.github.io/docs/obsidian.html)**

> スライドファイルは `itochu0523.github.io` リポジトリの `docs/obsidian.html` で管理。

---

## 🗂️ ディレクトリ構成

```
claude-configuration/
├── CLAUDE.md                          # Claude Code が起動時に自動読み込みする共通設定
├── mcp.json                           # MCP サーバー接続設定（Slack / Drive / Gmail / Calendar）
├── Makefile                           # ショートカットコマンド集
├── .gitignore
│
├── prompts/
│   ├── roles/
│   │   ├── ml_engineer.md             # ML エンジニアロール定義
│   │   └── enterprise_consultant.md   # クライアント向けコンサルロール
│   └── tasks/
│       ├── code_review.md             # コードレビューテンプレート
│       ├── spec_writer.md             # 仕様書作成テンプレート
│       └── bigquery_sql.md            # BigQuery SQL 作成テンプレート
│
└── scripts/
    ├── deploy.sh                      # 設定を各リポジトリへ配布するスクリプト
    └── sync-obsidian.sh               # Obsidian Vault との双方向同期スクリプト
```

---

## ⚡ クイックスタート

### 初回セットアップ

```bash
git clone https://github.com/itochu0523/itochu0523-claude-configuration.git
cd itochu0523-claude-configuration
make setup
```

`make setup` でやること:
- スクリプトに実行権限を付与
- git post-commit hook を登録（commit 後に `make deploy` が自動実行）

### 設定を配布する

```bash
make deploy              # 全プロジェクトへ配布
make deploy-github-io    # itochu0523.github.io のみ
make deploy-dmc          # dmc-ops-workflow のみ
make deploy-mcp          # MCP設定のみ（~/.claude/mcp.json）
```

### 新しいリポジトリを追加する

`scripts/deploy.sh` の2箇所に1行追加するだけ:

```bash
REPO_NAMES=(
  "itochu0523.github.io"
  "dmc-ops-workflow"
  "new-project"                         # ← 追加
)
REPO_PATHS=(
  "${HOME}/workspace/itochu0523.github.io"
  "${HOME}/dev/dmc-ops-workflow"
  "${HOME}/workspace/new-project"       # ← 追加
)
```

---

## 🔌 MCP サーバー設定

`mcp.json` で接続先を一元管理。`make deploy-mcp` で `~/.claude/mcp.json` に自動配置される。

| サービス | 用途 | MCP URL |
|---|---|---|
| **Slack** | メッセージ送信・検索・チャンネル操作 | `https://mcp.slack.com/mcp` |
| **Google Drive** | ファイル読み書き・検索・共有 | `https://drivemcp.googleapis.com/mcp/v1` |
| **Gmail** | メール送受信・スレッド検索・ラベル管理 | `https://gmailmcp.googleapis.com/mcp/v1` |
| **Google Calendar** | 予定作成・空き時間確認・イベント更新 | `https://calendarmcp.googleapis.com/mcp/v1` |

### MCP の仕組み

```
Claude Code / claude.ai
        ↓  mcp.json を読み込む
  MCP Protocol (SSE/HTTP)
        ↓
  ┌──────┬──────┬──────┬──────────┐
 Slack  Drive  Gmail  Calendar
```

Claude が自然言語で指示するだけで、外部サービスを直接操作できる。

### MCP の更新手順

```bash
# 1. mcp.json を編集
vim mcp.json

# 2. 全環境へ配布
make deploy-mcp
```

---

## 📓 Obsidian 連携

> Obsidian は未インストールでも他の機能はすべて動く。インストール後にいつでも連携できる。

### Obsidian を使うメリット

| メリット | 内容 |
|---|---|
| **モバイル対応** | iPhone / iPad の Obsidian アプリでプロンプトを閲覧・編集 |
| **双方向同期** | Obsidian Git プラグインで GitHub と自動 push/pull |
| **ナレッジ化** | `[[リンク]]` でプロンプト同士を繋げてグラフ構造で管理 |
| **オフライン対応** | ローカルの Markdown ファイルなのでネット不要で閲覧可能 |

### セットアップ手順

```bash
# 1. Vault ディレクトリを作成
mkdir -p ~/ObsidianVault

# 2. 環境変数を設定（~/.zshrc に追記）
echo 'export OBSIDIAN_VAULT="${HOME}/ObsidianVault"' >> ~/.zshrc
source ~/.zshrc

# 3. 設定ファイルを Vault へ初回書き出し
make obsidian-push
```

[obsidian.md](https://obsidian.md) からインストール後、Obsidian を起動 → "Open folder as vault" → `~/ObsidianVault` を選択。

### Obsidian Git プラグインで自動同期

1. Settings → Community plugins → Browse → `Obsidian Git` をインストール・有効化
2. 設定: **Auto pull interval: 10分** / **Auto push after commit: ON**

### 同期コマンド

```bash
make obsidian-push    # config → Obsidian Vault へ書き出し
make obsidian-pull    # Obsidian Vault → config へ取り込み
make obsidian-status  # 差分確認
```

### Obsidian Vault 内のファイル配置

```
~/ObsidianVault/
└── claude/
    ├── CLAUDE.md
    └── prompts/
        ├── roles/
        │   ├── ml_engineer.md
        │   └── enterprise_consultant.md
        └── tasks/
            ├── code_review.md
            ├── spec_writer.md
            └── bigquery_sql.md
```

---

## 📁 管理プロジェクト一覧

| リポジトリ | オーナー | 概要 |
|---|---|---|
| [itochu0523.github.io](https://github.com/itochu0523/itochu0523.github.io) | itochu0523（個人） | 自作アプリ群のポータル・公開ページ |
| [dmc-ops-workflow](https://github.com/lazuli-inc/dmc-ops-workflow) | lazuli-inc（Org） | DMC 業務ワークフロー管理 |
| `gcp-product-master`（予定） | 未定 | GCP 上の商品マスターデータ基盤 |

### GitHub アカウント構成

```
同一 GitHub アカウントで 2 組織を管理
├── github.com/itochu0523/      ← 個人リポジトリ
└── github.com/lazuli-inc/      ← Organization リポジトリ
```

---

## 🤖 CLAUDE.md の内容

Claude Code が起動時に自動読み込みする共通設定ファイル。

| 項目 | 設定内容 |
|---|---|
| **ロール** | フルスタックエンジニア最高峰として動作 |
| **言語** | 日本語で簡潔に回答 |
| **コードコメント** | 日本語で記述 |
| **パフォーマンス** | 計算量・クエリ効率・レンダリング速度を常に意識 |
| **UI** | 美しく・ユーザーに優しい設計を徹底 |
| **テスト** | デプロイ前に自動テストを実行する構成にする |
| **透明性** | 何をするか・なぜするかを必ず事前に明示する |

---

## 🛠️ make コマンド一覧

```bash
make help                # コマンド一覧を表示

# ── デプロイ ──────────────────────────────
make deploy              # 全プロジェクトへ配布
make deploy-github-io    # itochu0523.github.io のみ
make deploy-dmc          # dmc-ops-workflow のみ
make deploy-mcp          # MCP設定のみ更新（~/.claude/mcp.json）
make list                # 登録済みリポジトリ一覧

# ── Obsidian 同期 ─────────────────────────
make obsidian-push       # config → Vault へ書き出し
make obsidian-pull       # Vault → config へ取り込み
make obsidian-status     # 差分確認

# ── セットアップ ──────────────────────────
make setup               # 初回セットアップ（権限付与 + git hook 登録）
```

---

## 🔄 自動デプロイ（git hook）

`make setup` 実行後は、**git commit するたびに自動で `make deploy` が走る**。

```
git commit  →  post-commit hook 発火  →  make deploy  →  全リポジトリへ自動配布
```

無効にしたい場合:

```bash
rm .git/hooks/post-commit
```

---

## ❓ トラブルシューティング

**Permission denied エラーが出る**
```bash
chmod +x scripts/deploy.sh scripts/sync-obsidian.sh
```

**Obsidian Vault が見つからないと言われる**
```bash
export OBSIDIAN_VAULT="/path/to/your/vault"
```

**特定のリポジトリだけ設定を変えたい**

そのリポジトリの `CLAUDE.md` を直接編集する。`make deploy` は上書きするため、プロジェクト固有の設定は `CLAUDE.md` 末尾の `## プロジェクト固有設定` セクションに追記して管理するのを推奨。
