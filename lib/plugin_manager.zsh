# ~/.config/zsh/lib/plugin_manager.zsh
# Original: GitHub: https://github.com/ChristianChiarulli/machfiles/tree/new YouTube: chris@machine
# Modified by: Numan Syed & ChatGPT
# Description: A plugin manager for ZSH.
# Version: 1.0.0
# License: MIT License
# Date: July 2025

# Set default log file name for all zshlog calls
LOGFILE_NAME="plugin-manager.zlog"

# --- some helping functions ---
# zshlog() { [[ "$ZSHF_VERBOSE" == "true" ]] && echo "$@"; }
# zshlog() {
#     local msg="$*"

#     local logdir="${ZDOTDIR:-$HOME/.config/zsh}/logs"
#     local logfile="$logdir/zsh.zlog"

#     mkdir -p "$logdir"; touch "$logfile"

#     local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
#     local caller="📦 \e[0;33m${funcstack[2]:-main}\e[0m"

#     echo "\"$timestamp\",\"$caller\",\"$msg\"" >> "$logfile"

#     [[ "$ZSHF_VERBOSE" == "true" ]] && echo "$msg"
# }

# Helper: Usage message for zshlog
zshlog_usage() {
    echo "⚠️  Usage: zshlog [-f|-n|-t|-s|-v|-q] <message>"
    echo "    -f    Specify a log file name (default: zsh.zlog in ~/.config/zsh/logs)"
    echo "    -n    Add a newline before message"
    echo "    -t    Add a tab before message"
    echo "    -s    Skip logging (print only)"
    echo "    -v    Force verbosity ON (echo)"
    echo "    -q    Force verbosity OFF (quiet mode logging)"
}

zshlog() {
    [[ $# -eq 0 ]] && { zshlog_usage; return 1; }
    # Parse options
    local opt_echo="" opt_skiplog=false tab="" nl=""
    while [[ "$1" == -* ]]; do
        case "$1" in
            -h)
                zshlog_usage
                return 0
                ;;
            -f)
                shift
                logfile_name="$1"
                ;;                    # Add log file name
            -v) opt_echo=true ;;      # force verbosity on
            -q) opt_echo=false ;;     # quiet mode logging
            -s) opt_skiplog=true ;;   # skip logging
            -n) nl="\n" ;;            # add a newline before the message
            -t) tab="\t" ;;           # add a tab before the message
        esac
        shift
    done

    local msg="$*" # plain_msg
    local logdir="${ZDOTDIR:-$HOME/.config/zsh}/logs"
    local logfile="$logdir/${logfile_name:-${LOGFILE_NAME:-zsh.zlog}}"

    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    local caller="📦 <\e[0;33m${funcstack[2]:-main}\e[0m>"    # a yellow caller!
    mkdir -p "$logdir"

    [[ "$opt_skiplog" == false ]] && \
        echo "\"$timestamp\",\"$(clean "$caller")\",\"$(clean "$msg")\"" >> "$logfile"

    local verbosity="$opt_echo"
    # [[ "$ZSHF_VERBOSE" == "true" || "$opt_echo" == true ]] && \
    [[ "$verbosity" == "true" || ( -z "$verbosity" && "$ZSHF_VERBOSE" == "true" ) ]] && \
        print -P -- "$nl$tab$caller said:: $tab$msg"
}

# One-liner: Strip ANSI colour codes like \e[31m, \e[0;33m, etc.
clean() { echo "$1" | sed -E 's/\x1B\[[0-9;]*m//g' | sed -E 's/%F\{[^}]*\}//g; s/%K\{[^}]*\}//g; s/%f//g; s/%k//g' | perl -CSDA -pe 's/[\x{1F300}-\x{1FAFF}\x{2600}-\x{26FF}]//gu'; }

# # Full-step multiline: Strip ANSI escape codes, Zsh prompt formatting, and emoji
# clean() {
#     echo "$1" | \
#         # Remove ANSI escape codes
#         sed -E 's/\x1B\[[0-9;]*m//g' | \
#         # Remove Zsh prompt formatting: %F{color}, %K{color}, %f, %k
#         sed -E 's/%F\{[^}]*\}//g; s/%K\{[^}]*\}//g; s/%f//g; s/%k//g' | \
#         # Remove emoji (unicode ranges)
#         perl -CSDA -pe 's/[\x{1F300}-\x{1FAFF}\x{2600}-\x{26FF}]//gu'
# }

git_clone() {
    [[ $# -eq 0 ]] && { echo "\n\t===\n\t⚠️  Usage: git_clone <repo> <dest> \n\t===\n"; return 0; }

    local REPO="$1" DEST="$2"
    local CALLER="\e[0;47m${funcstack[2]}\e[0m"

    # echo -e "\n"
    zshlog -n " <$CALLER> : \e[0;32mCloning \e[32;47m $REPO\e[31m → \e[32m $DEST \e[0m"
    # echo -e "\n📦 \e[0;33mgit-clone\e[0m \e[0;47m <$CALLER> \e[0m: \e[0;32mCloning \e[32;47m $REPO\e[31m → \e[32;47m $DEST \e[0m"
    git clone --depth=1 "git@github.com:$REPO.git" "$DEST" && return 0

    zshlog -v -t " <$CALLER> \e[33;47m:❌ Failed to clone $REPO.git \e[0m"
    # echo "\t===\e[0;33;47m git-clone\e[33;41m <$CALLER> \e[33;47m:❌ Failed to clone $REPO.git \e[0m==="
    return 1
}

zsh_add_file() {
    local CALLER="${funcstack[2]}"

    [[ -f "$ZDOTDIR/$1" ]] && source "$ZDOTDIR/$1" && {
        if [[ "$CALLER" == *".zshrc"* ]]; then
            zshlog " \e[0;32mFile\e[0m \"$1\" \e[0;32msourced successfully\e[0m "
        else
            zshlog " <\e[0;33m$CALLER\e[0m>: \e[0;32mFile\e[0m \"$1\" \e[32msourced successfully\e[0m "
        fi
        return 0
    }
    return 1
}

zsh_add_plugin() {
    local REPO="$1"
    local PLUGIN_NAME="${REPO##*/}"
    local PLUGIN_PATH="$ZDOTDIR/plugins/$PLUGIN_NAME"

    # if folder is not available, clone it from github
    [[ ! -d "$PLUGIN_PATH" ]] && git_clone $REPO $PLUGIN_PATH

    # Source the plugin-file : either of the 2 possible ones
    local TRY1="plugins/$PLUGIN_NAME/$PLUGIN_NAME.plugin.zsh"
    local TRY2="plugins/$PLUGIN_NAME/$PLUGIN_NAME.zsh"
    { zsh_add_file "$TRY1" || zsh_add_file "$TRY2" ;} || \
    { zshlog -v -t "===\e[0;31m:❌ Couldn't source file: \e[36m["$TRY1"]\e[31m or \e[36m["$TRY2"]\e[31m \e[0m==="; }
    # { echo -e "\t===\e[0;31;47m zsh_add_plugin:❌ Couldn't source file: \e[36m["$TRY1"]\e[31m or \e[36m["$TRY2"]\e[31m \e[0m==="; }
}

zsh_add_completion() {
    local REPO="$1"
    local DO_COMPINIT="$2"
    local PLUGIN_NAME="${REPO##*/}"
    local PLUGIN_PATH="$ZDOTDIR/plugins/$PLUGIN_NAME"

    # if folder is not available, clone it from github
    [[ ! -d "$PLUGIN_PATH" ]] && git_clone $REPO $PLUGIN_PATH

    # Source the plugin-file
    zsh_add_file "plugins/$PLUGIN_NAME/$PLUGIN_NAME.plugin.zsh" || \
    { zshlog -t "===\e[0;31;47m:❌ Missing completions source: [""${PLUGIN_PATH/$HOME/~}"/$PLUGIN_NAME.plugin.zsh"] \e[0m==="; }
    # { echo -e "\t===\e[0;31;47m zsh_add_completion:❌ Missing completions source: [""${PLUGIN_PATH/$HOME/~}"/$PLUGIN_NAME.plugin.zsh"] \e[0m==="; }

    [[ "$DO_COMPINIT" == true ]] && compinit -u
}

zsh_update_plugins() {
    for DIR in "$ZDOTDIR"/plugins/*/.git; do
        local PLUGIN_PATH="${DIR%/.git}"
        zshlog "Updating ${PLUGIN_PATH##*/}..."
        git -C "$PLUGIN_PATH" pull --quiet --rebase && zshlog "...done" || zshlog "...failed ❌"
    done
}

zsh_auto_update_plugins() {
    # running as a cronjob, variables are localized, as we need to store the variables in a file
    local ZDOTLOGS="$HOME/.config/zsh/logs"
    local CACHE_FILE="$ZDOTLOGS/plugin-update.timestamp"
    local LOG_FILE="$ZDOTLOGS/plugin-update.log"
    local NOW=$(date +%s)
    local WEEK_SECONDS=$((7 * 24 * 60 * 60))

    mkdir -p "$ZDOTLOGS"

    if [[ ! -f "$CACHE_FILE" ]] || (( NOW - $(cat "$CACHE_FILE") > WEEK_SECONDS )); then
        echo "[$(date)] Updating Zsh plugins..." | tee -a "$LOG_FILE"
        zsh_update_plugins 2>&1 | tee -a "$LOG_FILE"
        echo "$NOW" >| "$CACHE_FILE"
    fi
}
