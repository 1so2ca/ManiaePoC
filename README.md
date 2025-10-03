# ManiaePoC

**広島県のバス運行情報を取得できるウェブアプリのProof of Concept**

## アプリ概要
- 指定したバス停の現在の運行情報を表示
- GTFS-JPとGTFS-RTを利用した情報取得
- 対応バス会社：広島電鉄、広島バス

## 開発方針（PoC）
- **モノレポ構成**（本番環境ではポリレポ予定）
- AI agent（ClaudeCode）を活用
- 動作確認を最優先とした実装
- **Docker**で環境構築（各リポジトリにDockerfile配置）
- **Feature Branch**方式でGit運用
- 秘密情報は`.env`で管理（`.env.example`を用意）

## プロジェクト構成

```
/
├── web/              # フロントエンド（Elm + Cloudflare Pages）
├── api/              # バックエンド（Cloudflare Workers）
├── containers/       # 日次バッチ（Cloudflare Containers）
└── docs/             # ドキュメント
```

各ディレクトリの詳細は、それぞれのREADME.mdを参照してください。

## Commit Message ルール

Conventional Commitsに従い、subjectは日本語で記述します。

```
<type>: <subject in Japanese>

<body>

<footer>
```

### Type
- `feat`: 新機能
- `fix`: バグ修正
- `docs`: ドキュメントのみの変更
- `style`: コードの意味に影響しない変更（フォーマット等）
- `refactor`: リファクタリング
- `test`: テスト追加・修正
- `chore`: ビルドプロセス・補助ツールの変更

### 例
```
feat: バス停検索APIを追加
fix: 到着時刻表示を修正
docs: GTFS-RT URLを追加
refactor: プロジェクトディレクトリ構成を変更
```

## Pull Request ルール

### タイトル
- Commit Messageと同じ形式：`<type>: <subject in Japanese>`

### 説明（最小限）
```
## 変更内容


## 動作確認
- [ ] 動作確認済み
```

### マージ条件（PoC）
- セルフレビューのみ
- CI/CDチェック（設定後）
- テストは正常系のみでOK

## 開発タスク

開発は以下の順序で進めます。詳細タスクはGitHub Issueで管理します。

### 1. API設計
- [ ] OpenAPI仕様の定義
  - バス停情報取得API
  - 運行情報取得API
  - バス停検索API

### 2. データベース設計
- [ ] GTFS-JPテーブル定義
  - stops（バス停）
  - routes（路線）
  - trips（便）
  - stop_times（時刻表）
- [ ] GTFS-RTテーブル定義
  - trip_updates（運行情報更新）
  - vehicle_positions（車両位置）
  - alerts（運行情報アラート）

### 3. ディレクトリ構成
- [ ] 各リポジトリの詳細ディレクトリ構成決定
- [ ] Dockerfile作成
- [ ] 開発環境構築手順整備

### 4. 実装
- [ ] containers: GTFS-JPデータ取得・DB格納
- [ ] api: REST APIエンドポイント実装
- [ ] api: GTFS-RT定期取得（scheduled）
- [ ] web: フロントエンド実装