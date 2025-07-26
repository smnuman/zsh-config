export BREWDOTS="$HOME/.config/brew"
export ZDOTFOLDER="$HOME/.config/zsh"
export ZSHF_VERBOSE="false"                # zsh-functions verbosity

mkdir -p "$BREWDOTS" "$ZDOTFOLDER"

[[ -f "$ZDOTFOLDER/lib/plugin_manager.zsh" ]] && {
    # following file contains functions to manage plugins
    source "$ZDOTFOLDER/lib/plugin_manager.zsh"
    zsh_auto_update_plugins
} || \
    echo "$ZDOTFOLDER/env.zsh: ZSH Plugin manager not found (check: $ZDOTFOLDER/lib)"
