# Containers（バッチ処理）

**GTFS-JPデータの定期取得とDB格納**

## 技術スタック
- Cloudflare Containers
- Python/TypeScript（予定）

## 処理内容
- GTFS-JPデータの定期取得・DB格納（日次）
- 静的なバス停・路線情報の更新

## GTFS-JP URL

### 広島電鉄
- https://ajt-mobusta-gtfs.mcapps.jp/static/8/latest.zip
- https://ajt-mobusta-gtfs.mcapps.jp/static/8/current_data.zip

### 広島バス
- https://ajt-mobusta-gtfs.mcapps.jp/static/9/latest.zip
- https://ajt-mobusta-gtfs.mcapps.jp/static/9/current_data.zip

## データフロー
1. GTFS-JPデータのダウンロード
2. ZIPファイルの展開
3. Cloudflare D1へのデータ格納

## 開発方針（PoC）
- **セキュリティ対策：最小限**
- **オブザーバビリティ：最小限**
- **テスト：正常系のみ**
- エラーハンドリング最小限
- ログ出力最小限
