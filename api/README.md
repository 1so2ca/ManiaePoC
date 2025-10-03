# API（バックエンド）

**バス運行情報を提供するREST API**

## 技術スタック
- Cloudflare Workers
- TypeScript
- REST API

## データベース
- Cloudflare D1（SQLite）

## 構成

### `src/handlers/`
HTTP APIハンドラー
- バス停情報の取得
- 運行情報の提供

### `src/scheduled/`
定期実行ハンドラー（分次）
- GTFS-RTデータの定期取得（1分間隔）
- リアルタイム運行情報の更新

## データフロー
1. GTFS-RTデータの定期取得（1分間隔）
2. ユーザーリクエストに応じたバス情報提供

## GTFS-RT URL

### 広島電鉄
- https://ajt-mobusta-gtfs.mcapps.jp/realtime/8/trip_updates.bin
- https://ajt-mobusta-gtfs.mcapps.jp/realtime/8/vehicle_position.bin
- https://ajt-mobusta-gtfs.mcapps.jp/realtime/8/alerts.bin

### 広島バス
- https://ajt-mobusta-gtfs.mcapps.jp/realtime/9/trip_updates.bin
- https://ajt-mobusta-gtfs.mcapps.jp/realtime/9/vehicle_position.bin
- https://ajt-mobusta-gtfs.mcapps.jp/realtime/9/alerts.bin

## 開発方針（PoC）
- **セキュリティ対策：最小限**
- **オブザーバビリティ：最小限**
- **テスト：正常系のみ**
- エラーハンドリング最小限
- ログ出力最小限
