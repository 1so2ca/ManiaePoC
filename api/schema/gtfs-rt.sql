-- GTFS-RT リアルタイムデータのテーブル定義
-- Cloudflare D1 (SQLite) 用
-- API scheduled handlerによって分次で更新される

-- リアルタイムバス停通過情報（非正規化）
-- OpenAPIのStopTimeスキーマと完全に一致させ、JOIN不要で高速読み取り
CREATE TABLE realtime_stop_times (
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    -- 基本情報
    trip_id TEXT NOT NULL,
    dataset_id INTEGER NOT NULL,
    service_date TEXT NOT NULL, -- YYYY-MM-DD
    stop_id TEXT NOT NULL,
    stop_name TEXT NOT NULL,
    stop_sequence INTEGER NOT NULL,

    -- 予定時刻（GTFS-JPから取得、HH:MM:SS形式）
    scheduled_arrival TEXT NOT NULL,   -- HH:MM:SS
    scheduled_departure TEXT NOT NULL, -- HH:MM:SS

    -- 予測時刻（GTFS-RTから取得、HH:MM:SS形式）
    -- approaching状態の時のみ値が入る
    estimated_arrival TEXT,   -- HH:MM:SS
    estimated_departure TEXT, -- HH:MM:SS

    -- 実績時刻（GTFS-RTから取得、HH:MM:SS形式）
    -- arrived状態の時はarrivalのみ、departed状態の時は両方入る
    actual_arrival TEXT,   -- HH:MM:SS
    actual_departure TEXT, -- HH:MM:SS

    -- ステータス（OpenAPIと完全一致、事前計算して格納）
    status TEXT NOT NULL CHECK(status IN ('scheduled', 'approaching', 'arrived', 'departed')),

    -- メタデータ
    updated_at INTEGER NOT NULL, -- Unix timestamp（データ更新時刻）

    -- 外部キー（静的データと同期）
    FOREIGN KEY (dataset_id) REFERENCES gtfs_datasets(id) ON DELETE CASCADE,
    FOREIGN KEY (trip_id, dataset_id) REFERENCES trips(trip_id, dataset_id) ON DELETE CASCADE,

    -- 高速検索用の複合ユニーク制約
    UNIQUE (trip_id, dataset_id, service_date, stop_sequence)
);

-- 便レベルの情報（キャッシュ用）
-- route_nameやheadsignを毎回JOINしなくて済むように
CREATE TABLE realtime_trips (
    trip_id TEXT NOT NULL,
    dataset_id INTEGER NOT NULL,
    service_date TEXT NOT NULL, -- YYYY-MM-DD
    route_id TEXT NOT NULL,
    route_name TEXT NOT NULL,      -- キャッシュ（routesテーブルから）
    headsign TEXT NOT NULL,         -- キャッシュ（tripsテーブルから）
    last_updated INTEGER NOT NULL, -- Unix timestamp
    PRIMARY KEY (trip_id, service_date),
    FOREIGN KEY (dataset_id) REFERENCES gtfs_datasets(id) ON DELETE CASCADE,
    FOREIGN KEY (trip_id, dataset_id) REFERENCES trips(trip_id, dataset_id) ON DELETE CASCADE
);

-- インデックス（頻繁なクエリパターンに最適化）
CREATE INDEX idx_realtime_stop_times_trip_id ON realtime_stop_times(trip_id, dataset_id, service_date);
CREATE INDEX idx_realtime_stop_times_stop_id ON realtime_stop_times(stop_id, dataset_id, service_date);
CREATE INDEX idx_realtime_stop_times_status ON realtime_stop_times(status);
CREATE INDEX idx_realtime_stop_times_updated_at ON realtime_stop_times(updated_at);

-- 複合インデックス（バス停指定での便検索用）
CREATE INDEX idx_realtime_stop_times_stop_status ON realtime_stop_times(stop_id, status, service_date);

-- 古いデータ削除用のクエリ例（定期実行想定）
-- 1日以上前のデータは削除
-- DELETE FROM realtime_stop_times WHERE updated_at < unixepoch('now', '-1 day');
-- DELETE FROM realtime_trips WHERE last_updated < unixepoch('now', '-1 day');
