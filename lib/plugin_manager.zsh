# ~/.config/zsh/lib/plugin_manager.zsh
# Original: GitHub: https://github.com/ChristianChiarulli/machfiles/tree/new YouTube: chris@machine
# Modified by: Numan Syed & ChatGPT
# Description: A plugin manager for ZSH.
# Version: 1.0.0
# License: MIT License
# Date: July 2025

git_clone() {
  local REPO="$1" DEST="$2"
  local CALLER="${funcstack[2]}"

  echo -e "\n📦 \e[0;33mgit-clone\e[0m \e[0;47m <$CALLER> \e[0m: \e[0;32mCloning \e[32;47m $REPO\e[31m → \e[32;47m $DEST \e[0m"
  git clone --depth=1 "https://github.com/$REPO.git" "$DEST" && return 0

  echo "\t===\e[0;33;47m git-clone\e[33;41m <$CALLER> \e[33;47m:❌ Failed to clone $REPO.git \e[0m==="
  return 1
}

zsh_add_file() {
    local CALLER="${funcstack[2]}"

    [[ -f "$ZDOTFOLDER/$1" ]] && source "$ZDOTFOLDER/$1" && {
        [[ $ZSHF_VERBOSE == false ]] || {
            {
                [[ "$CALLER" == *".zshrc"* ]] &&
                echo -e "zsh_add_file: \e[0;32mFile\e[0m \"$1\" \e[0;32msourced successfully\e[0m "
            } || {
                [[ "$CALLER" != *".zshrc"* ]] &&
                echo -e "zsh_add_file\e[0;33m <$CALLER>\e[0m: \e[0;32mFile\e[0m \"$1\" \e[32msourced successfully\e[0m "
            } ||
            true
        }
    }
}

zsh_add_plugin() {
    local REPO="$1"
    local PLUGIN_NAME="${REPO##*/}"
    local PLUGIN_PATH="$ZDOTFOLDER/plugins/$PLUGIN_NAME"

    # if folder is not available, clone it from github
    [[ ! -d "$PLUGIN_PATH" ]] && git_clone $REPO $PLUGIN_PATH

    # Source the plugin-file : either of the 2 possible ones
    local TRY1="plugins/$PLUGIN_NAME/$PLUGIN_NAME.plugin.zsh"
    local TRY2="plugins/$PLUGIN_NAME/$PLUGIN_NAME.zsh"
    { zsh_add_file "$TRY1" || zsh_add_file "$TRY2" ;} || \
    { echo -e "\t===\e[0;31;47m zsh_add_plugin:❌ Couldn't source file: \e[36m["$TRY1"]\e[31m or \e[36m["$TRY2"]\e[31m \e[0m==="; }
}

zsh_add_completion() {
    local REPO="$1"
    local DO_COMPINIT="$2"
    local PLUGIN_NAME="${REPO##*/}"
    local PLUGIN_PATH="$ZDOTFOLDER/plugins/$PLUGIN_NAME"

    # if folder is not available, clone it from github
    [[ ! -d "$PLUGIN_PATH" ]] && git_clone $REPO $PLUGIN_PATH

    # Source the plugin-file
    zsh_add_file "plugins/$PLUGIN_NAME/$PLUGIN_NAME.plugin.zsh" || \
    { echo -e "\t===\e[0;31;47m zsh_add_completion:❌ Missing completions source: [""${PLUGIN_PATH/$HOME/~}"/$PLUGIN_NAME.plugin.zsh"] \e[0m==="; }

    [[ "$DO_COMPINIT" == true ]] && compinit -u
}

zsh_update_plugins() {
  for DIR in "$ZDOTFOLDER"/plugins/*/.git; do
    local PLUGIN_PATH="${DIR%/.git}"
    echo "Updating ${PLUGIN_PATH##*/}..."
    git -C "$PLUGIN_PATH" pull --quiet --rebase
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
