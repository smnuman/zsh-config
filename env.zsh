
export ZDOTDIR="$HOME/.config/zsh"
export BREWDOTS="$HOME/.config/brew"
export ZSHF_VERBOSE="false"                # zsh-functions verbosity

mkdir -p "$BREWDOTS" "$ZDOTDIR"

[[ -f "$ZDOTDIR/lib/plugin_manager.zsh" ]] && {
    # following file contains functions to manage plugins
    source "$ZDOTDIR/lib/plugin_manager.zsh"
    zsh_auto_update_plugins
} || \
    echo "$ZDOTDIR/env.zsh: ZSH Plugin manager not found (check: $ZDOTDIR/lib)"
