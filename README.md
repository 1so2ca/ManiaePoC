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

## プロジェクト構成

```
/
├── web/              # フロントエンド（Elm + Cloudflare Pages）
├── api/              # バックエンド（Cloudflare Workers）
├── containers/       # 日次バッチ（Cloudflare Containers）
└── docs/             # ドキュメント
```

各ディレクトリの詳細は、それぞれのREADME.mdを参照してください。