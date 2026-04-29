#!/usr/bin/env bash
# extract-video-script — Search, download, transcribe Bilibili/YouTube videos locally
# Usage: extract-video-script "<keyword>" --source <bilibili|youtube|auto> [flags]
# Sources: source "$HOME/.claude/video-scripts/.env.sh"

set -euo pipefail

# --- Paths ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$HOME/.claude/video-scripts/.env.sh"
OUTPUT_DIR="$HOME/.claude/video-scripts"
CACHE_DIR="$OUTPUT_DIR/.cache"
CONFIG_FILE="$OUTPUT_DIR/config.json"
PROMPTS_DIR="$SCRIPT_DIR/prompts"
LOG_MD="$OUTPUT_DIR/devlog.md"
LOG_JSONL="$OUTPUT_DIR/devlog.jsonl"

# --- Defaults ---
SOURCE="auto"
MAX_RESULTS=5
LANGUAGE="auto"
WHISPER_MODEL="medium"
KEEP_CACHE=false
DRY_RUN=false

# --- Parse args ---
KEYWORD=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --source)       SOURCE="$2"; shift 2 ;;
        --max-results)  MAX_RESULTS="$2"; shift 2 ;;
        --language)     LANGUAGE="$2"; shift 2 ;;
        --whisper-model) WHISPER_MODEL="$2"; shift 2 ;;
        --keep-cache)   KEEP_CACHE=true; shift ;;
        --dry-run)      DRY_RUN=true; shift ;;
        --help|-h)
            echo "Usage: extract-video-script <keyword> --source <bilibili|youtube|auto> [flags]"
            echo ""
            echo "Flags:"
            echo "  --source <src>        bilibili, youtube, or auto (default: auto)"
            echo "  --max-results <n>     Number of search results (default: 5)"
            echo "  --language <lang>     zh, en, or auto (default: auto)"
            echo "  --whisper-model <m>   tiny/base/small/medium/large (default: medium)"
            echo "  --keep-cache          Keep temp video/audio files (debug only)"
            echo "  --dry-run             Search only, don't download or transcribe"
            echo "  --help, -h            Show this help"
            exit 0
            ;;
        *) KEYWORD="$1"; shift ;;
    esac
done

if [[ -z "$KEYWORD" ]]; then
    echo "ERROR: Keyword required. Use --help for usage."
    exit 1
fi

# --- Validate source ---
if [[ "$SOURCE" != "bilibili" && "$SOURCE" != "youtube" && "$SOURCE" != "auto" ]]; then
    echo "ERROR: --source must be bilibili, youtube, or auto. Got: $SOURCE"
    exit 1
fi

# --- Load environment ---
if [[ -f "$ENV_FILE" ]]; then
    source "$ENV_FILE"
else
    echo "WARNING: .env.sh not found at $ENV_FILE — tools may not be on PATH"
fi

# --- Setup ---
mkdir -p "$CACHE_DIR"
mkdir -p "$OUTPUT_DIR"

# --- Write default config if missing ---
if [[ ! -f "$CONFIG_FILE" ]]; then
    cat > "$CONFIG_FILE" << 'ENDCONFIG'
{
  "version": "1.0.0",
  "whisper": {
    "default_model": "medium",
    "fallback_chain": ["medium", "small", "base"],
    "language_hint": "auto"
  },
  "download": {
    "bilibili": {
      "tool": "BBDown",
      "quality": 16,
      "max_duration_seconds": 7200
    },
    "youtube": {
      "tool": "yt-dlp",
      "format": "worst[ext=mp4]",
      "max_filesize_mb": 500
    }
  },
  "evolution": {
    "enabled": true,
    "max_retries": 2,
    "excluded_video_ids": []
  }
}
ENDCONFIG
fi

# --- Log helper ---
log_jsonl() {
    local event="$1"
    local msg="$2"
    local ts
    ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "{\"ts\":\"$ts\",\"event\":\"$event\",\"keyword\":\"$KEYWORD\",\"source\":\"$SOURCE\",\"msg\":\"$msg\"}" >> "$LOG_JSONL"
}

log_md() {
    local ts
    ts=$(date +"%Y-%m-%d %H:%M:%S")
    echo "## $ts | $1" >> "$LOG_MD"
    echo "$2" >> "$LOG_MD"
    echo "" >> "$LOG_MD"
}

# --- Dry-run mode ---
if $DRY_RUN; then
    echo "[DRY-RUN] Would search '$KEYWORD' on $SOURCE (max $MAX_RESULTS results)"
    echo "[DRY-RUN] No download or transcription performed."
    exit 0
fi

# ===================================================================
# Agent 1: Search & Download
# ===================================================================
log_jsonl "agent1_start" "Searching $KEYWORD on $SOURCE"
log_md "Agent 1 Start" "- **關鍵字：** $KEYWORD
- **來源：** $SOURCE
- **最大結果數：** $MAX_RESULTS"

AGENT1_OUTPUT="$CACHE_DIR/agent1_output.json"

echo ">>> Agent 1: Searching & downloading '$KEYWORD' (source: $SOURCE)..."

claude --print --model deepseek-v4-pro \
    --output-format json \
    --allowedTools "Bash,Read,Write,Glob,Grep" \
    < "$PROMPTS_DIR/agent1_search_download.md" \
    > "$AGENT1_OUTPUT" 2>"$CACHE_DIR/agent1_stderr.log"

if [[ ! -s "$AGENT1_OUTPUT" ]]; then
    log_jsonl "agent1_fail" "Empty output"
    echo "ERROR: Agent 1 produced empty output"
    exit 1
fi

if jq -e '.error' "$AGENT1_OUTPUT" > /dev/null 2>&1; then
    err=$(jq -r '.error' "$AGENT1_OUTPUT")
    log_jsonl "agent1_fail" "$err"
    echo "ERROR: Agent 1 failed: $err"
    exit 1
fi

VIDEO_PATH=$(jq -r '.video_path // ""' "$AGENT1_OUTPUT")
TITLE=$(jq -r '.metadata.title // "unknown"' "$AGENT1_OUTPUT")
log_jsonl "agent1_done" "Downloaded: $TITLE"
log_md "Agent 1 Done" "- **影片：** $TITLE
- **路徑：** $VIDEO_PATH"

echo ">>> Downloaded: $TITLE"

# ===================================================================
# Agent 2: Extract & Transcribe
# ===================================================================
log_jsonl "agent2_start" "Extracting audio and transcribing"
log_md "Agent 2 Start" "- **影片：** $VIDEO_PATH
- **語言：** $LANGUAGE
- **模型：** $WHISPER_MODEL"

AGENT2_OUTPUT="$CACHE_DIR/agent2_output.json"

echo ">>> Agent 2: Extracting audio & transcribing..."

claude --print --model deepseek-v4-pro \
    --output-format json \
    --allowedTools "Bash,Read,Write,Glob,Grep" \
    < "$PROMPTS_DIR/agent2_extract_transcribe.md" \
    > "$AGENT2_OUTPUT" 2>"$CACHE_DIR/agent2_stderr.log"

if [[ ! -s "$AGENT2_OUTPUT" ]]; then
    log_jsonl "agent2_fail" "Empty output"
    echo "ERROR: Agent 2 produced empty output"
    exit 1
fi

if jq -e '.extraction_report.errors[0]' "$AGENT2_OUTPUT" > /dev/null 2>&1; then
    err=$(jq -r '.extraction_report.errors[0]' "$AGENT2_OUTPUT")
    log_jsonl "agent2_error" "$err"
fi

SCRIPT_PATH=$(jq -r '.script_path // ""' "$AGENT2_OUTPUT")
WORD_COUNT=$(jq -r '.extraction_report.script_word_count // 0' "$AGENT2_OUTPUT")
log_jsonl "agent2_done" "Script: $SCRIPT_PATH ($WORD_COUNT words)"
log_md "Agent 2 Done" "- **腳本：** $SCRIPT_PATH
- **字數：** $WORD_COUNT"

echo ">>> Script: $SCRIPT_PATH ($WORD_COUNT words)"

# ===================================================================
# Quality gate → Agent 3 if needed
# ===================================================================
if [[ "$WORD_COUNT" -lt 100 ]] || jq -e '.extraction_report.errors[0]' "$AGENT2_OUTPUT" > /dev/null 2>&1; then
    log_jsonl "agent3_triggered" "word_count=$WORD_COUNT, quality gate failed"
    log_md "Agent 3 Triggered" "- **原因：** 字數不足（$WORD_COUNT）或 Agent 2 有錯誤"

    AGENT3_OUTPUT="$CACHE_DIR/agent3_output.json"

    echo ">>> Agent 3: Quality check & self-evolution..."

    claude --print --model deepseek-v4-pro \
        --output-format json \
        --allowedTools "Bash,Read,Write,Glob,Grep,WebSearch" \
        < "$PROMPTS_DIR/agent3_quality_evolve.md" \
        > "$AGENT3_OUTPUT" 2>>"$CACHE_DIR/agent3_stderr.log"

    GRADE=$(jq -r '.quality_report.overall_grade // "unknown"' "$AGENT3_OUTPUT")
    log_jsonl "agent3_done" "Grade: $GRADE"
    log_md "Agent 3 Done" "- **品質等級：** $GRADE"
    echo ">>> Quality grade: $GRADE"
else
    echo ">>> Quality gate: PASS (no Agent 3 needed)"
fi

# ===================================================================
# Cleanup
# ===================================================================
if ! $KEEP_CACHE; then
    rm -f "$CACHE_DIR"/*.wav "$CACHE_DIR"/*.mp4 "$CACHE_DIR"/*.txt 2>/dev/null || true
    echo ">>> Cache cleaned"
else
    echo ">>> Cache kept (--keep-cache)"
fi

log_jsonl "extraction_complete" "Done: $SCRIPT_PATH"
echo ""
echo "Done. Script: $SCRIPT_PATH"
