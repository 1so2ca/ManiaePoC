# API（バックエンド）

**バス運行情報を提供するREST API**

## 技術スタック
- Cloudflare Workers
- TypeScript
- REST API
- OpenAPI 3.0.3（仕様: `openapi.yaml`）

## データベース
- Cloudflare D1（SQLite）

## API仕様

### エンドポイント
- `GET /stops?query={name}` - バス停検索
- `GET /stops/{stop_id}` - バス停情報取得
- `GET /arrivals` - バス到着情報取得（バス停またはODペア指定）
- `GET /routes/od/{from_stop_id}/{to_stop_id}` - ODペア情報取得

### データ構造
- **便（Trip）中心**のレスポンス
- 各便は複数の**バス停通過情報（StopTime）**を持つ
- StopTimeは4種類の状態を持つ（scheduled/approaching/arrived/departed）
- フロントエンドでの加工を不要とするため、ユーザーが欲しい情報をそのまま返す

詳細は`openapi.yaml`を参照

## 構成

### `src/handlers/`
HTTP APIハンドラー

### `src/scheduled/`
定期実行ハンドラー（分次）
- GTFS-RTデータの定期取得（1分間隔）

## データフロー
1. GTFS-RTデータの定期取得（1分間隔）→DB格納
2. ユーザーリクエスト→便情報（予定・実績・予測）を返却

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
