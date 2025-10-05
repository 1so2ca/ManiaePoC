-- GTFS-JP 静的データのテーブル定義
-- Cloudflare D1 (SQLite) 用

-- データセットのバージョン管理
-- latest.zipとcurrent_data.zipを区別するために必要
CREATE TABLE gtfs_datasets (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    dataset_type TEXT NOT NULL CHECK(dataset_type IN ('latest', 'current')),
    agency_name TEXT NOT NULL, -- '広島電鉄' or '広島バス'
    valid_from TEXT NOT NULL,   -- YYYY-MM-DD（有効期限開始）
    valid_until TEXT NOT NULL,  -- YYYY-MM-DD（有効期限終了）
    imported_at INTEGER NOT NULL, -- Unix timestamp（データ取り込み日時）
    is_active INTEGER DEFAULT 1 CHECK(is_active IN (0, 1)), -- 現在有効か
    UNIQUE (dataset_type, agency_name, valid_from)
);

-- バス停情報
CREATE TABLE stops (
    stop_id TEXT NOT NULL,
    dataset_id INTEGER NOT NULL,
    stop_name TEXT NOT NULL,
    stop_desc TEXT,
    stop_lat REAL,
    stop_lon REAL,
    zone_id TEXT,
    stop_url TEXT,
    location_type INTEGER DEFAULT 0,
    parent_station TEXT,
    stop_timezone TEXT,
    wheelchair_boarding INTEGER,
    PRIMARY KEY (stop_id, dataset_id),
    FOREIGN KEY (dataset_id) REFERENCES gtfs_datasets(id) ON DELETE CASCADE,
    CHECK (
        (COALESCE(location_type, 0) = 0 AND stop_lat IS NOT NULL AND stop_lon IS NOT NULL)
        OR (COALESCE(location_type, 0) <> 0)
    )
);

-- 路線情報
CREATE TABLE routes (
    route_id TEXT NOT NULL,
    dataset_id INTEGER NOT NULL,
    agency_id TEXT,
    route_short_name TEXT,
    route_long_name TEXT,
    route_desc TEXT,
    route_type INTEGER NOT NULL,
    route_url TEXT,
    route_color TEXT,
    route_text_color TEXT,
    route_sort_order INTEGER,
    PRIMARY KEY (route_id, dataset_id),
    FOREIGN KEY (dataset_id) REFERENCES gtfs_datasets(id) ON DELETE CASCADE
);

-- 便情報
CREATE TABLE trips (
    trip_id TEXT NOT NULL,
    dataset_id INTEGER NOT NULL,
    route_id TEXT NOT NULL,
    service_id TEXT NOT NULL,
    trip_headsign TEXT,
    trip_short_name TEXT,
    direction_id INTEGER,
    block_id TEXT,
    shape_id TEXT,
    wheelchair_accessible INTEGER,
    bikes_allowed INTEGER,
    PRIMARY KEY (trip_id, dataset_id),
    FOREIGN KEY (route_id, dataset_id) REFERENCES routes(route_id, dataset_id) ON DELETE CASCADE,
    FOREIGN KEY (dataset_id) REFERENCES gtfs_datasets(id) ON DELETE CASCADE
);

-- 時刻表（便ごとのバス停通過予定時刻）
-- 時刻は文字列（HH:MM:SS）で格納してOpenAPIとフォーマットを統一（25:00:00のような24時超表記も許容）
CREATE TABLE stop_times (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    trip_id TEXT NOT NULL,
    dataset_id INTEGER NOT NULL,
    arrival_time TEXT, -- HH:MM:SS形式
    departure_time TEXT, -- HH:MM:SS形式
    stop_id TEXT NOT NULL,
    stop_sequence INTEGER NOT NULL,
    stop_headsign TEXT,
    pickup_type INTEGER DEFAULT 0,
    drop_off_type INTEGER DEFAULT 0,
    shape_dist_traveled REAL,
    timepoint INTEGER DEFAULT 1,
    FOREIGN KEY (trip_id, dataset_id) REFERENCES trips(trip_id, dataset_id) ON DELETE CASCADE,
    FOREIGN KEY (stop_id, dataset_id) REFERENCES stops(stop_id, dataset_id) ON DELETE CASCADE,
    UNIQUE (trip_id, stop_sequence, dataset_id)
);

-- インデックス
CREATE INDEX idx_gtfs_datasets_active ON gtfs_datasets(is_active, dataset_type, agency_name);
CREATE UNIQUE INDEX idx_gtfs_datasets_active_unique
    ON gtfs_datasets(dataset_type, agency_name)
    WHERE is_active = 1;
CREATE INDEX idx_stop_times_trip_id ON stop_times(trip_id, dataset_id);
CREATE INDEX idx_stop_times_stop_id ON stop_times(stop_id, dataset_id);
CREATE INDEX idx_trips_route_id ON trips(route_id, dataset_id);
CREATE INDEX idx_stops_name ON stops(stop_name, dataset_id);
