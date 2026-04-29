# extract-video-script — 專案日誌 (Project Journal)

> **日誌深度：A（詳細記錄）**
> 記錄所有 Agent 操作、工具調用、檔案變更，確保完整可追溯。

---

## 1. 專案概述

| 項目 | 內容 |
|------|------|
| **工具名稱** | `extract-video-script` |
| **一句話目的** | 輸入關鍵字，自動搜尋 Bilibili/YouTube 教學影片 → 下載 → 本機 Whisper 語音轉文字 → 輸出 Markdown 腳本，不留任何影片/音軌殘留 |
| **建立日期** | 2026-04-29 |
| **PRD 路徑** | `C:\Users\qwqwh\.claude\projects\video-script-extractor\PRD.md` |
| **GitHub Repo** | https://github.com/mmmmmmmm5455/extract-video-script |
| **工具目錄** | `C:\Users\qwqwh\.claude\video-scripts\` |
| **源碼目錄** | `C:\Users\qwqwh\.claude\projects\video-script-extractor\` |

---

## 2. 預期目標

- **節省時間：** 自動化「搜影片 → 下載 → 聽寫 → 整理腳本」這個手動流程，從 30-60 分鐘降到 5-10 分鐘
- **自我進化：** 每次失敗自動診斷、搜尋修復方案、更新配置，越用越穩定
- **知識提取：** 將教學影片轉為可搜尋、可摘要、可翻譯的文字腳本，後續可餵給 Claude 做二次處理
- **離線可用：** 所有語音轉文字在本機完成，無雲端依賴，無隱私風險

---

## 3. 技術棧完整清單

| 工具 | 用途 | 安裝狀態 | 安裝日期 | 版本 |
|------|------|----------|----------|------|
| `BBDown` | Bilibili 影片下載（強制首選） | ✅ 已安裝 | 2026-04-29 | 1.6.3 |
| `yt-dlp` | YouTube 影片下載 | ✅ 已安裝 | 2026-04-29 | 2026.03.17 |
| `ffmpeg` | 音軌提取 / 格式轉換 / 編碼降級 | ✅ 已安裝 | 2026-04-29 | 8.1 (winget) |
| `whisper` (openai-whisper) | 本機語音轉文字 | ✅ 已安裝 | 2026-04-29 | 20250625 |
| `faster-whisper` | 備選語音轉文字引擎（CTranslate2） | ❌ 未安裝（備選） | — | — |
| `dotnet` (.NET Runtime) | BBDown 執行依賴 | ✅ 已安裝 | 既有 | 8.0.409 |
| `node` + `npx` | page-agent 執行依賴 | ✅ 已安裝 | 2026-04-29 | v24.15.0 (可攜版) |
| `python3` | Agent 膠水層 / JSON / 腳本處理 | ✅ 已安裝 | 既有 | 3.14.4 |
| `jq` | JSON 解析（bash 腳本中） | ✅ 已安裝 | 2026-04-29 | 1.8.1 |
| `page-agent` | 瀏覽器搜尋（B站/YT 結果頁爬取） | ✅ 已安裝 | 2026-04-29 | 1.8.1（alibaba/page-agent，含 MCP server） |
| `markitdown` | 多格式文件轉 Markdown（微軟） | ✅ 已安裝 | 2026-04-29 | 0.1.5（pip install markitdown） |
| `prompt-optimizer` | Prompt 優化引擎（MCP server） | ✅ 已安裝 | 2026-04-29 | 2.9.6（linshenkx，core + mcp-server 建置成功，UI 跳過） |

---

## 4. 技能使用記錄

| 技能 | 使用位置 | 選擇理由 | 實際效果 |
|------|----------|----------|----------|
| `sci-openai-whisper` | Agent 2 | 本機 Whisper CLI，符合「嚴禁雲端」規則 | 待記錄 |
| `sci-openai-whisper-api` | — | **已禁用**（雲端 API，違反禁止規則） | — |
| `os-ffmpeg-encoder-check` | Agent 2 | 檢測編碼器可用性，避免 lib 錯誤 | 待記錄 |
| `os-ffmpeg-graceful-degradation` | Agent 2 | 編碼失敗時系統性降級 | 待記錄 |
| `sci-video-frames` | Agent 2（輔助） | 場景檢測，輔助腳本分段 | 待記錄 |
| `os-audio-track-production` | Agent 2（借用模式） | 僅借用 ffmpeg 音軌提取模式，不執行音樂流程 | 待記錄 |
| `os-audio-track-production-enhanced` | Agent 2（借用模式） | 增量驗證哲學：提取 → 驗證 → 下一步 | 待記錄 |
| `caveman` | 所有 Agent | 精簡編碼風格，減少 token 消耗 | 待記錄 |
| `skill-discovery` | Agent 3 | 自我進化時搜尋新技能/替代方案 | 待記錄 |
| `page-agent` | Agent 1, Agent 3 | 瀏覽器搜尋與爬取 | 待記錄 |
| `compress` | 全專案 | 壓縮日誌與配置檔案 | 待記錄 |

---

## 5. 關鍵決策記錄

| 日期 | 決策 | 理由 |
|------|------|------|
| 2026-04-29 | 禁用 `sci-openai-whisper-api` | SKILL.md 明確指向 OpenAI 雲端 API，違反「嚴禁雲端語音轉文字 API」規則。僅使用本機 `whisper` CLI |
| 2026-04-29 | Bilibili 下載首選 BBDown | 用戶強制要求（C# 命令列工具，GitHub Stars 中），yt-dlp 僅用於 YouTube |
| 2026-04-29 | Agent 數量定為 2+1 | Agent 1（搜尋下載）+ Agent 2（提取轉文字）為必要；Agent 3（品質進化）僅異常觸發 |
| 2026-04-29 | 影片最低解析度策略 | 使用 BBDown quality=16 (360P) 和 yt-dlp `worst[ext=mp4]` — 腳本品質不依賴畫質，節省頻寬和時間 |
| 2026-04-29 | whisper 預設模型選擇 medium | 平衡速度與精度。若 GPU OOM → 自動降級 small → base |
| 2026-04-29 | 強制清理策略 | Agent 2 完成後立即 rm 影片和暫存音軌，不做快取。`--keep-cache` flag 僅供除錯 |
| 2026-04-29 | 日誌深度選 A（詳細記錄） | 用戶指定。記錄所有 Agent 操作、工具調用、檔案變更，確保完整可追溯 |
| 2026-04-29 | Agent 間通訊使用 JSON 檔案 | 不用網路/IPC。每個 Agent 讀取上游 JSON → 執行 → 寫入下游 JSON，簡單可靠 |

---

## 6. 環境診斷（2026-04-29）

### 已安裝

| 工具 | 版本 | 路徑 |
|------|------|------|
| dotnet | 8.0.409 | `C:\Program Files\dotnet\` |
| python3 | 3.14.4 | Windows Python |

### 環境診斷（2026-04-29）— Phase 0 已完成 ✅

> **所有 7 項工具已於 2026-04-29 安裝完成。** 以下為安裝記錄。

| 工具 | 安裝方式 | 結果 |
|------|----------|------|
| ffmpeg | `winget install Gyan.FFmpeg` | ✅ v8.1 |
| yt-dlp | `winget install yt-dlp.yt-dlp` | ✅ v2026.03.17（附帶 Deno + yt-dlp.FFmpeg） |
| BBDown | GitHub Releases → `C:\Tools\BBDown\` | ✅ v1.6.3（檔名 `BBDown_1.6.3_20240814_win-x64.zip`） |
| Node.js + npx | 可攜版 → `C:\Tools\nodejs\` | ✅ v24.15.0（MSI 需管理員被拒，改用 zip） |
| openai-whisper | `pip install openai-whisper` | ✅ v20250625（需 `PYTHONIOENCODING=utf-8`） |
| jq | `winget install jqlang.jq` | ✅ v1.8.1（先前已安裝） |

**已知問題：**
- whisper cp950 終端亂碼 → `PYTHONIOENCODING=utf-8` 解決
- winget 工具需從 `WinGet/Packages/` 目錄直接調用
- 環境配置：`C:\Users\qwqwh\.claude\video-scripts\.env.sh`

### 已安裝

---

## 7. 失敗與修正

### yt-dlp JS Runtime 警告（2026-04-29）
- **問題：** `WARNING: [youtube] No supported JavaScript runtime could be found`
- **根因：** yt-dlp 需要 JS runtime 進行 YouTube 提取，deno 已預設啟用但不可用於此版本
- **嘗試 1：** Git Bash 路徑格式 `/c/Tools/nodejs/...` → 失敗（yt-dlp 為 Windows exe，不識別 Unix 路徑）
- **嘗試 2：** Windows 路徑格式 `C:\Tools\nodejs\...` → 成功
- **修復：** `~/.config/yt-dlp/config` 中設定 `--js-runtimes "node:C:\\Tools\\nodejs\\node-v24.15.0-win-x64\\node.exe"`
- **驗證：** `JS runtimes: node-24.15.0` — 警告已消除

---

## 8. 成果評估

### Phase 2 測試 #1 — Agent 1 YouTube 搜尋與下載（2026-04-29）

**搜尋關鍵字：** "whisper speech to text tutorial"
**來源：** youtube
**最大結果數：** 1

**結果：成功 ✅**

| 項目 | 值 |
|------|------|
| 影片標題 | How to Install & Use Whisper AI Voice to Text |
| 影片 ID | ABFqbY_rmEk |
| 上傳者 | Kevin Stratvert |
| 時長 | 764s (12m44s) |
| 觀看數 | 764,829 |
| 下載格式 | 18 (360p mp4) |
| 檔案大小 | 16,474,971 bytes (15.7 MB) |
| 下載速度 | 8.15 MiB/s |
| 搜尋耗時 | ~3s |
| 下載耗時 | ~1s |
| 總耗時 | ~4s |

**品質門檻檢查：**
- ✅ 時長 < 7200s
- ✅ 檔案存在且 > 0 bytes
- ✅ 語言已推斷為 en（英文標題）
- ✅ 格式為 mp4（含音軌 — format 18 為標準 mp4+acc）

**yt-dlp JS Runtime 修復（2026-04-29）：**
- **問題：** yt-dlp 警告 "No supported JavaScript runtime could be found"
- **根因：** 需要設定 `--js-runtimes` 指向 node.exe；Git Bash 路徑格式（`/c/Tools/...`）不被 yt-dlp（Windows exe）識別
- **修復：** 在 `~/.config/yt-dlp/config` 中以 Windows 格式設定 `--js-runtimes "node:C:\\Tools\\nodejs\\node-v24.15.0-win-x64\\node.exe"`
- **驗證：** `JS runtimes: node-24.15.0` — 警告已消除

**觀察：**
- yt-dlp 警告缺少 JS runtime（deno 已啟用但不夠），但未影響下載
- 建議之後安裝 node 作為 JS runtime：`--js-runtimes node` 或設定於 yt-dlp config
- format 18 為標準 360p，符合最低解析度策略

### Phase 2 測試 #2 — Agent 2 語音提取與轉錄（2026-04-29）

**來源影片：** "How to Install & Use Whisper AI Voice to Text" (ABFqbY_rmEk, 764s)
**模型：** whisper medium (CPU FP32)

**結果：成功 ✅**

| 步驟 | 狀態 | 耗時 | 詳情 |
|------|------|------|------|
| ffmpeg 音軌提取 | ✅ | ~1s | WAV 16kHz mono, 23.3 MB |
| Whisper 模型下載 | ✅ | ~14s | medium model 1.42 GB 下載到 ~/.cache/whisper/ |
| Whisper 轉錄 | ✅ | ~46min | CPU FP32, 109 段落, 2,447 詞 |
| Markdown 寫入 | ✅ | <1s | YAML front matter + 時間戳段落 |
| 影片刪除 | ✅ | <1s | ABFqbY_rmEk.mp4 已刪除 |
| WAV 刪除 | ✅ | <1s | ABFqbY_rmEk.wav 已刪除 |
| SRT 刪除 | ✅ | <1s | ABFqbY_rmEk.srt 已刪除 |

**輸出腳本：** `C:\Users\qwqwh\.claude\video-scripts\How-to-Install---Use-Whisper-AI-Voice-to-Text.md`
**字數：** 2,447 | **段落數：** 109
**品質：** 優秀 — 標點正確、大小寫準確、時間碼精準、無幻覺段落

**品質門檻檢查：**
- ✅ script_word_count (2,447) > 100
- ✅ transcription_ok = true
- ✅ language_detected = en (符合預期)
- ✅ errors = []
- ✅ cleanup_ok = true — 所有暫存檔案已刪除
- ✅ Agent 3 不需要觸發

**重要觀察：**
- CPU-only (FP32) 轉錄速度約 0.27x 即時（12.7 分鐘音檔需 ~46 分鐘），這是最大瓶頸
- 建議未來安裝 CUDA 版 PyTorch 或改用 faster-whisper（CTranslate2, ~4x 加速）
- medium 模型下載僅在首次執行時需要，後續執行直接使用快取

---

## 9. 專案結論

> *待工具完成後記錄：哪些技能證明有用、哪些浪費了 token、下次開發時會改進的地方。*

---

## 10. 開發時間軸

| 日期 | 事件 |
|------|------|
| 2026-04-29 | PRD 完成，環境診斷完成，JOURNAL.md 建立 |
| 2026-04-29 | **Phase 0 完成**：7/7 工具安裝通過（ffmpeg, yt-dlp, BBDown, node, npx, whisper, jq） |
| 2026-04-29 | 追加安裝：page-agent 1.8.1（alibaba）、markitdown 0.1.5（microsoft）、prompt-optimizer 2.9.6（linshenkx） |
| 2026-04-29 | **Phase 1 完成**：基礎設施建立 — CLI 入口腳本、config.json、3 個 Agent prompt、4 個 JSON schema |
| 2026-04-29 | **Phase 2 測試 #1**：Agent 1 YouTube 搜尋與下載成功 (764s, 15.7MB, 360p) |
| 2026-04-29 | **Phase 2 測試 #2**：Agent 2 語音提取與轉錄成功 — whisper medium, 2,447 詞, 109 段落, 全清潔 ✅ |
| — | Phase 2：剩餘項目（Bilibili 搜尋/下載、page-agent 整合、auto 模式） |
| — | Phase 3：Agent 3 品質與進化（待執行） |
| — | Phase 4：Agent 3 開發（待執行） |
| — | Phase 5：整合測試（待執行） |
| 2026-04-29 | **GitHub 推送**：初始化 repo，18 個檔案，commit `29f5705`，推送至 github.com/mmmmmmmm5455/extract-video-script |

---

---

## 11. Phase 1 交付清單（2026-04-29）

| 檔案 | 狀態 | 說明 |
|------|------|------|
| `extract-video-script.sh` | ✅ | CLI 入口腳本（~220行），含參數解析、3-Agent 編排、品質門檻、清理邏輯 |
| `config.json` | ✅ | 預設工具配置（whisper, download, evolution, paths） |
| `prompts/agent1_search_download.md` | ✅ | Agent 1 系統提示（搜尋 + 下載策略，BBDown/yt-dlp） |
| `prompts/agent2_extract_transcribe.md` | ✅ | Agent 2 系統提示（ffmpeg→whisper→markdown→delete） |
| `prompts/agent3_quality_evolve.md` | ✅ | Agent 3 系統提示（5 類根因診斷 + 自我進化） |
| `schemas/agent1_input.schema.json` | ✅ | Agent 1 輸入 JSON Schema（keyword, source, max_results, language） |
| `schemas/agent1_output.schema.json` | ✅ | Agent 1 輸出 JSON Schema（video_path + metadata 或 error） |
| `schemas/agent2_input.schema.json` | ✅ | Agent 2 輸入 JSON Schema（video_path + metadata） |
| `schemas/agent2_output.schema.json` | ✅ | Agent 2 輸出 JSON Schema（script_path + extraction_report） |
| `JOURNAL.md` | ✅ | 本日誌 — Phase 1 記錄完成 |

### 待 Phase 2 處理
- `tests/` 目錄中的 3 個測試腳本（test_bilibili_search.sh, test_youtube_search.sh, test_extraction_pipeline.sh）

---

## 12. GitHub 推送記錄（2026-04-29）

| 項目 | 內容 |
|------|------|
| **Repo URL** | https://github.com/mmmmmmmm5455/extract-video-script |
| **SSH Remote** | git@github.com:mmmmmmmm5455/extract-video-script.git |
| **Commit** | `29f5705` — feat: extract-video-script — 本機影片腳本提取工具 v1.0.0 |
| **檔案數** | 18 files, 2123 insertions |
| **授權** | MIT License（原創部分） |
| **致謝** | ATTRIBUTIONS.md（11 個開源專案） |

### 推送內容清單

| 檔案 | 說明 |
|------|------|
| `README.md` | 工具概述、安裝、使用方式、技術棧 |
| `ATTRIBUTIONS.md` | 開源致謝（BBDown, yt-dlp, whisper, FFmpeg, page-agent, markitdown, prompt-optimizer, Node.js, jq, Claude Code, OpenClaw） |
| `PRD.md` | 完整產品需求文件（12 章節） |
| `extract-video-script.sh` | CLI 入口腳本（~220行，3-Agent 編排） |
| `.env.sh` | 環境變數設定（工具 PATH） |
| `config.json` | 工具配置（whisper, download, evolution, paths） |
| `JOURNAL.md` | 專案日誌（含環境診斷、測試記錄、決策記錄） |
| `devlog.md` | 人類可讀開發日誌 |
| `devlog.jsonl` | 機器可解析開發日誌（JSON Lines） |
| `prompts/agent1_search_download.md` | Agent 1 系統提示 |
| `prompts/agent2_extract_transcribe.md` | Agent 2 系統提示 |
| `prompts/agent3_quality_evolve.md` | Agent 3 系統提示 |
| `schemas/agent1_input.schema.json` | Agent 1 輸入 Schema |
| `schemas/agent1_output.schema.json` | Agent 1 輸出 Schema |
| `schemas/agent2_input.schema.json` | Agent 2 輸入 Schema |
| `schemas/agent2_output.schema.json` | Agent 2 輸出 Schema |
| `.gitignore` | 忽略 cache、IDE、OS 檔案 |
| `examples/How-to-Install---Use-Whisper-AI-Voice-to-Text.md` | 範例輸出（2,447 詞，109 段落） |

---

*日誌維護者：Claude Code（extract-video-script 開發團隊）*
