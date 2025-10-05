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

| ディレクトリ | 役割 | 主なポイント |
| --- | --- | --- |
| `web/` | フロントエンド（Elm + Cloudflare Pages） | `README.md`にUI/HTTP仕様を記載 |
| `api/` | Cloudflare Workers API | `openapi.yaml`と`schema/`配下のSQLでAPI/DBを管理 |
| `containers/` | 日次バッチ（Cloudflare Containers） | 静的GTFSの取得・D1更新フローを記載 |
| `docs/` | ドキュメント | `responce/`はレビュー履歴 |

### データベーススキーマ
- 静的: `api/schema/gtfs-jp.sql`（`gtfs_datasets`でlatest/current管理、停留所座標チェック付）
- リアルタイム: `api/schema/gtfs-rt.sql`（`service_date`＋`dataset_id`で便を一意化）
- 仕様メモ: `docs/responce/api-schema-review-20251005.md`

## コーディングルール

| 項目 | ルール |
| --- | --- |
| Commit | Conventional Commits、subjectは日本語（例: `feat: バス停検索APIを追加`） |
| Pull Request | タイトルも同形式。テンプレートに沿い `変更内容` / `動作確認` を記載 |
| Review | セルフレビューでOK。CI設定後はチェック必須、テストは正常系中心 |

## 開発タスク

開発は以下の順序で進めます。詳細タスクはGitHub Issueで管理します。

### 1. API設計
- [x] OpenAPI仕様の定義
  - [x] バス停検索API
  - [x] バス停情報取得API
  - [x] 到着情報取得API
  - [x] ODペア情報取得API

### 2. データベース設計
- [x] GTFS-JPテーブル定義
  - [x] gtfs_datasets（バージョン管理）
  - [x] stops（バス停）
  - [x] routes（路線）
  - [x] trips（便）
  - [x] stop_times（時刻表）
- [x] GTFS-RTテーブル定義
  - [x] realtime_trips（便メタデータキャッシュ）
  - [x] realtime_stop_times（リアルタイム到着情報）
  - [ ] 追加拡張（alerts / vehicleなど）

### 3. ディレクトリ構成
- [ ] 各リポジトリの詳細ディレクトリ構成決定
- [ ] Dockerfile作成
- [ ] 開発環境構築手順整備

### 4. 実装
- [ ] containers: GTFS-JPデータ取得・DB格納
- [ ] api: REST APIエンドポイント実装
- [ ] api: GTFS-RT定期取得（scheduled）
- [ ] web: フロントエンド実装
