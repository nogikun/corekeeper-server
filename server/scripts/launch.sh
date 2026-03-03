#!/bin/bash
source "${SCRIPTSDIR}/helper-functions.sh"

# Switch to workdir
cd "${STEAMAPPDIR}" || exit

### Function for gracefully shutdown
function kill_corekeeperserver {
    if [[ -n "$ckpid" ]] && kill -0 "$ckpid" 2>/dev/null; then
        kill "$ckpid"
        wait "$ckpid"
    fi

    if [[ -n "$xvfbpid" ]] && kill -0 "$xvfbpid" 2>/dev/null; then
        kill "$xvfbpid"
        wait "$xvfbpid"
    fi

    # Sends stop message
    if [[ "${DISCORD_SERVER_STOP_ENABLED,,}" == true ]]; then
        wait=true
        SendDiscordMessage "$DISCORD_SERVER_STOP_TITLE" "$DISCORD_SERVER_STOP_MESSAGE" "$DISCORD_SERVER_STOP_COLOR" "$wait"
    fi
}

trap kill_corekeeperserver EXIT

if [ -f "GameID.txt" ]; then rm GameID.txt; fi
if [ -f "GameInfo.txt" ]; then rm GameInfo.txt; fi

# Compile Parameters
# Populates `params` array with parameters.
# Creates `logfile` var with log file path.
source "${SCRIPTSDIR}/compile-parameters.sh"

# Create the log file and folder.
mkdir -p "${STEAMAPPDIR}/logs"
touch "$logfile"

# OSとアーキテクチャを uname で取得し、クロスプラットフォーム対応にする
os=$(uname -s)
architecture=$(uname -m)

# Linux の場合のみ Xvfb (仮想ディスプレイ) を起動する
if [ "$os" = "Linux" ]; then
    Xvfb :99 -screen 0 1x1x24 -nolisten tcp &
    xvfbpid=$!
    export DISPLAY=:99
fi

# OSやアーキテクチャに応じて CoreKeeperServer の起動方法を切り替える
if [ "$os" = "Linux" ]; then
    if [ "$architecture" = "aarch64" ] || [ "$architecture" = "arm64" ]; then
        # Linux ARM64 の場合 (box64 エミュレータが必要)
        LD_LIBRARY_PATH="${STEAMCMDDIR}/linux64:/usr/lib:${LD_LIBRARY_PATH#:}" /usr/local/bin/box64 ./CoreKeeperServer "${params[@]}" &
    else
        # Linux x86_64 の場合
        LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${STEAMCMDDIR}/linux64/" ./CoreKeeperServer "${params[@]}" &
    fi
elif [ "$os" = "Darwin" ]; then
    # macOS の場合 (Apple Silicon は必要に応じてネイティブの Rosetta 2 で x86_64 エミュレーションを実行)
    ./CoreKeeperServer "${params[@]}" &
else
    # Windows (Git Bash/MSYS2 などの環境)
    ./CoreKeeperServer.exe "${params[@]}" &
fi
ckpid=$!

LogDebug "Started server process with pid ${ckpid}"

# Monitor server logs for player join/leave, server start, and server stop
source "${SCRIPTSDIR}/logfile-parser.sh"
tail --pid "$ckpid" -f "$logfile" | LogParser &

wait $ckpid
