# api/schema レビュー（2025-10-05）

## 概要
- `api/schema` 配下の SQL と README、関連 README、設計メモを突き合わせ、矛盾・パフォーマンス・拡張性・GTFS適合性の観点で確認。
- 主要な懸念は **リアルタイムテーブルが設計方針と矛盾している点**、**複合キー管理の欠落によるデータ不整合リスク**、**GTFS-JP/RT の要件を十分に満たせていない点**。

## 1. ドキュメントとの矛盾
- README では「GTFS-RT テーブルは OpenAPI の StopTime と完全一致し JOIN 不要」とあるが、`realtime_stop_times` に `stop_name` 列が存在せず、サンプル SQL も実際の列名（`stop_sequence`）と異なるためそのまま動作しない（`api/schema/README.md:18-83`, `api/schema/gtfs-rt.sql:7-37`）。
- OpenAPI では `Trip` オブジェクトに `stop_times` が含まれ、各要素に `stop_name` が必須だが、DB 側では取得するために `stops` との JOIN が必須になるため「JOIN 不要」の前提と矛盾（`api/openapi.yaml:210-372`, `api/schema/gtfs-rt.sql:7-37`）。
- `realtime_trips` の外部キーが `trips(trip_id)` を参照しているが、`trips` テーブルは `(trip_id, dataset_id)` の複合 PRIMARY KEY のため参照先が存在せず、外部キー制約が作成できない（`api/schema/gtfs-jp.sql:53-87`, `api/schema/gtfs-rt.sql:41-48`）。

## 2. パフォーマンス / 運用面の懸念
- JOIN を避ける設計意図に反して `stop_name` を取得するには結局 `stops` との JOIN が必要。Cloudflare D1 は JOIN に制限があるため、ピーク時レスポンスに影響する恐れ。
- `realtime_stop_times` のユニークキーが `(trip_id, stop_id, stop_sequence)` のみで、GTFS-RT の `TripDescriptor.start_date/start_time` を保持していない。日付を跨いで同じ `trip_id` が再利用されると前日のレコードと衝突し、書き換えや INSERT 失敗が発生する恐れ。
- `gtfs_datasets` に `is_active` の一意性制約がなく、`latest`/`current` ともに複数のアクティブエントリを持ててしまう。参照系クエリーが複数行を返し、API 側の前提が崩れるリスク。
- `realtime_trips` が `dataset_id` を保持していないため、静的データ更新直後にリアルタイムデータが古い `trip_id` を参照すると JOIN できず不整合になる。全テーブルから当日分を掃き出すバッチが失敗した場合に、事故復旧が難しくなる。

## 3. GTFS 仕様との整合性
- `stops` テーブルは `stop_lat/stop_lon` を NULL 許容にしているが、GTFS では停留所（location_type=0）では緯度経度が必須。NULL を許可するとフィードのバリデーションエラーを見逃す恐れがある。
- `stop_times` のコメントで `HH:MM:SS` フォーマットを強調しているが、GTFS では 24 時間を超える値（例: `25:10:00`）も許容される。アプリ側で 24 時間制に固定すると翌日便が誤表示になる。
- GTFS-RT では便の同定に `TripDescriptor.trip_id` に加えて `start_date` や `start_time` を利用することが推奨されている。スキーマに保持していない現状だと複数日の便を正しく区別できない。

## 4. 拡張性・将来拡張の懸念
- GTFS-JP 固有の拡張ファイル（例: `office_jp.txt`, `stop_times_jp.txt`, `calendar_dates.txt` など）への対応が未整備。将来の事業者追加や詳細情報表示に必要なカラムが不足している。
- `service_id` や `route_id` の参照元となる `calendar`, `calendar_dates`, `agency` テーブルが未定義。今後のダイヤ切り替えロジックや事業者横断の検索機能を実装しづらい。
- リアルタイム側で車両情報（vehicle_id、位置情報）や遅延秒数などを保持していないため、将来的に機能拡張（地図表示や遅延統計）が難しい。

## 推奨対応（優先度順）
1. `realtime_stop_times` に `stop_name`（または `stop_id` と結合済みの `dataset_id`）を追加し、README のクエリ例と実装意図を一致させる。併せて列名を `sequence` に揃えるか、クエリ側で `AS sequence` 指定を徹底。
2. リアルタイム系テーブルへ `dataset_id` と `service_date`（= TripDescriptor.start_date）を追加し、ユニークキー／外部キーを再設計。`realtime_trips` の外部キーは `(trip_id, dataset_id)` を参照するよう変更。
3. `gtfs_datasets` に部分一意制約（例: `UNIQUE(dataset_type, agency_name) WHERE is_active=1`）を追加し、常に 1 つのアクティブバージョンを保証。
4. `stops` の `stop_lat/stop_lon` を基本 NOT NULL にし、例外ケース（location_type≠0）だけを許容するバリデーションを実装。
5. GTFS-JP 拡張ファイルや `calendar` 系テーブルの取り込み方針を整理し、必要なテーブルを追加。将来の機能要件を想定して優先順位を決める。
6. リアルタイム機能拡張を見据え、`vehicle_id` や遅延秒数（delay）を保持するテーブル案を検討。

## 対応状況（2025-10-05）
- 対応済: 1〜4（`api/schema/gtfs-rt.sql`, `api/schema/gtfs-jp.sql`, `api/schema/README.md` を更新済み）
- 未着手: 5〜6（将来対応の検討事項として残置）
