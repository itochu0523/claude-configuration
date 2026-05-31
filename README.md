# itochu0523-claude-configuration

Claude Code / claude.ai の設定ファイルを一元管理するリポジトリ。
**ここを更新するだけで、全作業リポジトリとObsidianに設定が伝播する。**

---

## ディレクトリ構成

```
claude-configuration/
├── CLAUDE.md                      # Claude Code 共通ベース設定（全リポジトリで使用）
├── mcp.json                       # MCP サーバー接続設定
├── Makefile                       # ショートカットコマンド集
├── .gitignore
│
├── prompts/
│   ├── roles/
│   │   ├── ml_engineer.md         # ML エンジニア ロール定義
│   │   └── enterprise_consultant.md  # クライアント向けコンサルロール
│   └── tasks/
│       ├── code_review.md         # コードレビュー テンプレート
│       ├── spec_writer.md         # 仕様書作成 テンプレート
│       └── bigquery_sql.md        # BigQuery SQL 作成テンプレート
│
└── scripts/
    ├── deploy.sh                  # 設定を各リポジトリへ配布
    └── sync-obsidian.sh           # Obsidian Vault との同期
```

---

## クイックスタート

### 1. クローン & セットアップ（初回のみ）

```bash
git clone https://github.com/itochu0523/itochu0523-claude-configuration.git
cd itochu0523-claude-configuration
make setup
```

`make setup` でやること:
- スクリプトに実行権限を付与
- `git post-commit hook` を登録（commit 後に自動デプロイ）

### 2. 設定を配布する

```bash
make deploy              # 全リポジトリへ配布
make deploy-asahi        # asahidrink_labelling のみ
make deploy-dashboard    # dmc-work-dashboard のみ
make deploy-mcp          # MCP設定のみ (~/.claude/mcp.json)
```

### 3. 新しいリポジトリに追加する

`scripts/deploy.sh` の `REPOS` に1行追記するだけ:

```bash
declare -A REPOS=(
  ["asahidrink_labelling"]="${HOME}/workspace/asahidrink_labelling"
  ["dmc-work-dashboard"]="${HOME}/workspace/dmc-work-dashboard"
  ["dmc-master-api"]="${HOME}/workspace/dmc-master-api"
  ["new-project"]="${HOME}/workspace/new-project"   # ← 追加
)
```

---

## Obsidian との連携

> Obsidian は **未インストールでも他の機能はすべて動く**。
> インストール後にいつでも連携できる。

### Obsidian インストール

[obsidian.md](https://obsidian.md) からダウンロードしてインストール。

### Vault の作成・設定

```bash
# Vault ディレクトリを作成
mkdir -p ~/ObsidianVault

# 環境変数を設定（~/.zshrc または ~/.bashrc に追記）
echo 'export OBSIDIAN_VAULT="${HOME}/ObsidianVault"' >> ~/.zshrc
source ~/.zshrc

# 設定ファイルを Vault へ初回書き出し
make obsidian-push
```

Obsidian を起動 → "Open folder as vault" → `~/ObsidianVault` を選択。

### Obsidian Git プラグインで自動同期

1. Obsidian → Settings → Community plugins → Browse
2. `Obsidian Git` を検索 → Install → Enable
3. Settings: **Auto pull interval: 10 分**, **Auto push after commit: ON**

これで GitHub ↔ Obsidian が自動同期される。

### 日常の同期コマンド

```bash
make obsidian-push    # GitHub の最新を Obsidian に書き出す
make obsidian-pull    # Obsidian で編集した内容を config-repo へ取り込む
make obsidian-status  # 差分確認
```

### Obsidian でのファイル配置

```
~/ObsidianVault/
└── claude/
    ├── CLAUDE.md
    └── prompts/
        ├── roles/
        └── tasks/
```

Obsidian でプロンプトを編集 → `make obsidian-pull` → `git commit & push` → 自動デプロイ、の流れ。

---

## Claude Code での使い方

### プロジェクト開始時

```bash
# 作業リポジトリへ移動
cd ~/workspace/asahidrink_labelling

# CLAUDE.md が配置されていれば Claude Code が自動で読み込む
claude
```

### ロールを切り替える

```bash
# ML エンジニアモードでセッション開始
cat ~/.claude-config/prompts/roles/ml_engineer.md | claude
```

### タスクテンプレートを使う

```bash
# コードレビュー用プロンプトを開く
cat .claude/prompts/tasks/code_review.md
# → 内容をコピーして Claude に貼り付け
```

---

## 自動化フロー

```
このリポジトリを git commit & push
         ↓
post-commit hook 発火
         ↓
make deploy 実行
         ↓
全作業リポジトリの CLAUDE.md が更新される
         ↓
次回 Claude Code 起動時に自動反映
```

手動でも `make deploy` 一発で即時反映できる。

---

## ファイル別役割まとめ

| ファイル | 役割 | 更新タイミング |
|---|---|---|
| `CLAUDE.md` | Claude Code が自動読み込む共通設定 | コーディングルール変更時 |
| `mcp.json` | MCP サーバー接続先 | 新しい MCP ツール追加時 |
| `prompts/roles/` | 作業種別ごとのロール定義 | 新しいクライアント・プロジェクト追加時 |
| `prompts/tasks/` | 繰り返しタスクのテンプレート | 新しいタスクパターン発見時 |
| `scripts/deploy.sh` | 各リポジトリへの配布 | 配布先リポジトリ追加時 |
| `scripts/sync-obsidian.sh` | Obsidian との双方向同期 | Vault パス変更時 |
| `Makefile` | 全コマンドのショートカット | めったに変えない |

---

## トラブルシューティング

**Q: `make deploy` でパーミッションエラーが出る**
```bash
chmod +x scripts/deploy.sh scripts/sync-obsidian.sh
```

**Q: Obsidian Vault が見つからないと言われる**
```bash
export OBSIDIAN_VAULT="/path/to/your/vault"
```

**Q: 特定のリポジトリだけ CLAUDE.md を変えたい**

そのリポジトリの `CLAUDE.md` を直接編集する。`deploy.sh` は上書きするので、
再デプロイ時に差分が消えることを念頭に置くこと。
プロジェクト固有の設定は `CLAUDE.md` の末尾に `## プロジェクト固有設定` セクションを追加して管理するのが推奨。

**Q: git commit 後に自動デプロイしたくない**
```bash
# post-commit hook を無効化
rm .git/hooks/post-commit
```

---

## 関連リポジトリ

| リポジトリ | 概要 |
|---|---|
| `asahidrink_labelling` | 飲料業界向け ML 分類（クライアント案件）|
| `dmc-work-dashboard` | BigQuery 業務分析ダッシュボード |
| `dmc-master-api` | Google Sheets → BigQuery sync |
