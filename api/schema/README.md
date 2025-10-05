# Database Schema

Cloudflare D1 (SQLite互換) を使用したデータベース設計。

## ファイル構成

- `gtfs-jp.sql`: GTFS-JP（静的データ）のテーブル定義
- `gtfs-rt.sql`: GTFS-RT（リアルタイムデータ）のテーブル定義

## 設計方針

### 1. バージョン管理
- GTFS-JPデータは`latest`と`current`の2種類が存在
- `gtfs_datasets`テーブルでバージョンと有効期限を管理
- 各テーブルに`dataset_id`を持たせて明確に区別

### 2. 高速読み取り
- GTFS-RTテーブルは非正規化し、JOIN不要で読み取り可能
- OpenAPIレスポンスと同じデータ構造で格納
- 時刻フォーマットを統一（すべて`HH:MM:SS`形式）

### 3. 型変換の最小化
- OpenAPIで返す`status`を事前計算してDB格納
- 時刻は文字列（HH:MM:SS）で統一し、API応答時に変換不要

## GTFS-JP（静的データ）

日次でcontainersによって更新される静的な時刻表データ。

### 主要テーブル
- `gtfs_datasets`: データセットのバージョン・有効期限管理
- `stops`: バス停情報
- `routes`: 路線情報
- `trips`: 便情報
- `stop_times`: 時刻表（便ごとのバス停通過予定時刻）

停留所の予定時刻は GTFS-JP に合わせて `HH:MM:SS` 文字列を保持し、`25:10:00` のような24時超表記も受け入れる。

### データセット管理
```sql
-- 例: 広島電鉄のlatestデータを取得
SELECT * FROM gtfs_datasets
WHERE agency_name = '広島電鉄'
  AND dataset_type = 'latest'
  AND is_active = 1;
```

同一事業者・種別でアクティブ（`is_active = 1`）な行は常に1件になるよう、部分ユニークインデックスを付与。

## GTFS-RT（リアルタイムデータ）

apiのscheduled handlerによって分次で更新されるリアルタイム運行情報。

### 主要テーブル
- `realtime_stop_times`: バス停ごとの到着・出発予測時刻（非正規化、`dataset_id`・`service_date`付き）
- `realtime_trips`: 便情報のキャッシュ（`dataset_id`・`service_date`付き）

### 特徴
- OpenAPIの`StopTime`スキーマと整合する形で、`stop_name`などの表示用情報もキャッシュ
- `dataset_id`と`service_date`で静的データと同一便をトレースできる
- `status`フィールドを事前計算して格納（scheduled/approaching/arrived/departed）
- JOIN不要で高速読み取り

## OpenAPI仕様との対応

APIレスポンスは以下のクエリで生成可能（JOIN不要）:

```sql
-- GET /arrivals?stop_ids=34001
SELECT
    rt.trip_id,
    rt.route_name,
    rt.headsign,
    rts.dataset_id,
    rts.service_date,
    rts.stop_id,
    rts.stop_name,
    rts.stop_sequence AS sequence,
    rts.scheduled_arrival,
    rts.scheduled_departure,
    rts.estimated_arrival,
    rts.estimated_departure,
    rts.actual_arrival,
    rts.actual_departure,
    rts.status
FROM realtime_stop_times rts
JOIN realtime_trips rt
  ON rts.trip_id = rt.trip_id
 AND rts.dataset_id = rt.dataset_id
 AND rts.service_date = rt.service_date
WHERE rts.stop_id = '34001'
  AND rts.service_date = '2025-10-05'
ORDER BY rts.scheduled_arrival;
```

この設計により、API実装時の型変換やステータス計算が不要。
- 停留所（`location_type=0`）は緯度・経度を必須とするチェック制約で、GTFS-JP の要件違反を防止
