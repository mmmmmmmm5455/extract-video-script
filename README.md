# extract-video-script

本機 CLI 工具：搜尋 Bilibili/YouTube 教學影片 → 下載最低解析度 → 本機 Whisper 語音轉文字 → 輸出 Markdown 腳本。

## 一句話概述

輸入關鍵字，輸出 `.md` 腳本，中間不留任何影片/音軌檔案。所有語音轉文字在本機完成，無雲端依賴，無隱私風險。

## 安裝

### 1. 安裝依賴工具

```powershell
# 一次性安裝（PowerShell 管理員）
winget install Gyan.FFmpeg
winget install yt-dlp.yt-dlp
winget install jqlang.jq

# Whisper
pip install openai-whisper

# Node.js（page-agent 依賴）
winget install OpenJS.NodeJS.LTS

# BBDown（手動下載）
# 從 https://github.com/nilaoda/BBDown/releases 下載 win-x64.zip
# 解壓到 C:\Tools\BBDown\
```

### 2. 複製本專案

```bash
git clone git@github.com:mmmmmmmm5455/extract-video-script.git
```

### 3. 設定環境變數

```bash
# 編輯 .env.sh 中的路徑以符合你的環境
cp .env.sh.example .env.sh
# 將 .env.sh 放到 ~/.claude/video-scripts/.env.sh
```

## 使用方式

```bash
# 載入環境
source "$HOME/.claude/video-scripts/.env.sh"

# 搜尋並轉錄
./extract-video-script.sh "Docker 入門教學" --source bilibili --language zh

# YouTube 英文影片
./extract-video-script.sh "whisper speech to text" --source youtube

# 更多選項
./extract-video-script.sh "React Hooks" --source auto --max-results 3 --whisper-model small
```

### 完整參數

| 參數 | 必需 | 預設 | 說明 |
|------|------|------|------|
| `<關鍵字>` | 是 | - | 搜尋關鍵字，含空格需引號 |
| `--source` | 是 | - | `bilibili`、`youtube`、`auto` |
| `--max-results` | 否 | 5 | 搜尋結果數量上限 |
| `--language` | 否 | auto | 傳給 whisper 的語言提示（zh/en/auto） |
| `--whisper-model` | 否 | medium | 模型大小：tiny/base/small/medium/large |
| `--keep-cache` | 否 | false | 除錯用：保留暫存檔案 |
| `--dry-run` | 否 | false | 僅搜尋不下載 |

### 輸出範例

```markdown
---
title: "How to Install & Use Whisper AI Voice to Text"
source: "youtube"
url: "https://www.youtube.com/watch?v=ABFqbY_rmEk"
date: "2026-04-29"
duration: "764s"
language: "en"
model: "whisper-medium"
extracted_by: "extract-video-script v1.0.0"
---

# How to Install & Use Whisper AI Voice to Text

[00:00:00] Hi, everyone. Kevin here. Today, we're going to look at...

[00:00:07] With Whisper, you can transcribe speech to text...
```

## 架構

```
User: extract-video-script "關鍵字"
    │
    ▼
Agent 1: Search & Download (page-agent / BBDown / yt-dlp)
    │
    ▼
Agent 2: Extract & Transcribe (ffmpeg → whisper → markdown → delete)
    │
    ▼ (品質門檻未過時)
Agent 3: Quality & Self-Evolution (診斷 → 修復 → 記錄)
    │
    ▼
Output: ~/.claude/video-scripts/<title>.md
```

## 技術棧

| 工具 | 用途 | 版本 |
|------|------|------|
| BBDown | Bilibili 影片下載 | 1.6.3 |
| yt-dlp | YouTube 影片下載 | 2026.03.17 |
| openai-whisper | 本機語音轉文字 | 20250625 |
| FFmpeg | 音軌提取與轉碼 | 8.1 |
| page-agent | 瀏覽器搜尋 | 1.8.1 |
| markitdown | 文件轉 Markdown | 0.1.5 |
| prompt-optimizer | Prompt 優化 | 2.9.6 |
| Node.js | JS 執行環境 | v24.15.0 |
| Python | Agent 膠水層 | 3.14.4 |
| jq | JSON 處理 | 1.8.1 |
| Claude Code | Agent 執行環境 | - |

## 授權

本專案原創部分（Agent 設計、工作流編排、CLI 腳本、JSON Schema）以 MIT License 釋出。

依賴的第三方開源工具授權詳見 [ATTRIBUTIONS.md](ATTRIBUTIONS.md)。
