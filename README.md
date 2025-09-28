# ManiaePoC

**広島県のバス運行情報を取得できるウェブアプリのProof of Concept**

## アプリ概要
- 指定したバス停の現在の運行情報を表示
- GTFS-JPとGTFS-RTを利用した情報取得
- 対応バス会社：広島電鉄、広島バス

## 開発方針（PoC）
- **モノレポ構成**（本番環境ではポリレポ予定）
- **セキュリティ対策：最小限**
- **オブザーバビリティ：最小限**
- **テスト：正常系のみ**
- AI agent（ClaudeCode）を活用
- 動作確認を最優先とした実装

## 技術スタック

### フロントエンド
- **Elm** → JavaScript（Cloudflare Workers）
- **mdgriffith/elm-ui** - 型安全なUI構築

### バックエンド
- Cloudflare Workers
- TypeScript
- REST API

### データベース
- Cloudflare D1（SQLite）

### バッチ処理
- Cloudflare Workers（Cron Triggers）
- GTFS-RT取得・DB格納

## 機能

### メインページ
- バス停の現在の運行情報表示
- 到着予定時刻表示

### 検索ページ
- バス停検索
- お気に入り登録（localStorage）

## データフロー
1. GTFS-JPデータの定期取得・DB格納
2. GTFS-RTデータの定期取得（1分間隔）
3. ユーザーリクエストに応じたバス情報提供

## Elmライブラリ構成

### 必須ライブラリ
- **elm/browser** - ナビゲーション・URL管理
- **elm/http** - HTTPリクエスト
- **elm/json** - JSON エンコード・デコード
- **mdgriffith/elm-ui** - 型安全なUI構築

## 制約事項（PoC）
- エラーハンドリング最小限
- ログ出力最小限
- セキュリティ検証なし
- パフォーマンス最適化なし
- 正常系テストのみ

# GTFS関連URL
## GTFS-JP
### 広島電鉄
https://ajt-mobusta-gtfs.mcapps.jp/static/8/latest.zip
https://ajt-mobusta-gtfs.mcapps.jp/static/8/current_data.zip
### 広島バス
https://ajt-mobusta-gtfs.mcapps.jp/static/9/latest.zip
https://ajt-mobusta-gtfs.mcapps.jp/static/9/current_data.zip

## GTFS-RT
### 広島電鉄
https://ajt-mobusta-gtfs.mcapps.jp/realtime/8/trip_updates.bin
https://ajt-mobusta-gtfs.mcapps.jp/realtime/8/vehicle_position.bin
https://ajt-mobusta-gtfs.mcapps.jp/realtime/8/alerts.bin

### 広島バス
https://ajt-mobusta-gtfs.mcapps.jp/realtime/9/trip_updates.bin
https://ajt-mobusta-gtfs.mcapps.jp/realtime/9/vehicle_position.bin
https://ajt-mobusta-gtfs.mcapps.jp/realtime/9/alerts.bin