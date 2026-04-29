# extract-video-script environment setup
# Source this file before running any pipeline commands:
#   source "$HOME/.claude/video-scripts/.env.sh"

WINGET_PKGS="/c/Users/qwqwh/AppData/Local/Microsoft/WinGet/Packages"

export PATH="/c/Tools/BBDown:$PATH"
export PATH="/c/Tools/nodejs/node-v24.15.0-win-x64:$PATH"
export PATH="/c/Users/qwqwh/AppData/Local/Python/pythoncore-3.14-64/Scripts:$PATH"
export PATH="$WINGET_PKGS/Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe/ffmpeg-8.1-full_build/bin:$PATH"
export PATH="$WINGET_PKGS/yt-dlp.yt-dlp_Microsoft.Winget.Source_8wekyb3d8bbwe:$PATH"
export PATH="$WINGET_PKGS/jqlang.jq_Microsoft.Winget.Source_8wekyb3d8bbwe:$PATH"

export PATH="/c/Tools/page-agent/node_modules/.bin:$PATH"
export PAGE_AGENT_HOME="/c/Tools/page-agent"
export PROMPT_OPTIMIZER_HOME="/c/Tools/prompt-optimizer"
export PYTHONIOENCODING=utf-8
