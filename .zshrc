#!/usr/bin/env zsh
# Set up basic history
HISTFILE=$ZDOTDIR/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

# Source interactive shell behaviour (only works because we're interactive here)
[[ -o interactive ]] && . "$ZDOTDIR/zsh-optionrc"

[[ -f $ZDOTDIR/lib/keybinds.zsh ]] && . "$ZDOTDIR/lib/keybinds.zsh"
[[ -f $ZDOTDIR/lib/plugin_manager.zsh ]] && . $ZDOTDIR/lib/plugin_manager.zsh

echo -e "\n\t=== === === T E S T I N G === === ===\n"

# Enable hook, completion & colors
autoload -Uz add-zsh-hook
autoload -Uz compinit; compinit
autoload -Uz colors && colors

zstyle ':completion:*' menu select
zmodload zsh/complist

_comp_options+=(globdots)  # Show hidden/dotfiles

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^P' up-line-or-beginning-search    # Ctrl+P for up
bindkey '^N' down-line-or-beginning-search  # Ctrl+N for down


# Add zsh plugins wth my plugin manager
if [[ -f ~/.config/zsh/env.zsh ]]; then
	# Useful Functions
	source ~/.config/zsh/env.zsh        # important! must set first!

	# Normal z-files to source
	zsh_add_file "lib/pathtools.zsh"    # - Use EXPORT intelligently without bloating PATH environment var: creates logfile in ~/.config/zsh/logs/pathlog.zlog
	zsh_add_file "zsh-exports"          # - All export variables
	zsh_add_file "zsh-vim-mode"         # - Vim mode, etc.
	zsh_add_file "zsh-aliases"          # - Keep all your aliases in one place
    zsh_add_file "zsh-prompt"           # - This file sources .prompt.zsh and sets up the prompt
    zsh_add_file "zsh-functions"        # Functions like: - brew_log_summary(), - clear_brew_logs() etc.
    zsh_add_file "zsh-git-utils"        # - Git utilities like: - gsync, - grepo, - gsub etc.

	# Load z-plugins
	zsh_add_plugin zsh-users/zsh-autosuggestions
	zsh_add_plugin zsh-users/zsh-syntax-highlighting
	zsh_add_plugin zsh-users/zsh-history-substring-search
    zsh_add_plugin smnuman/zsh-history-search-end-match
    # zsh_add_plugin supercrabtree/k
	# Load z-completions
	zsh_add_completion zsh-users/zsh-completions true
fi


# autoload -Uz vcs_info

# zstyle ':vcs_info:*' enable git
# zstyle ':vcs_info:git:*' check-for-changes true

# zstyle ':vcs_info:*' stagedstr ' %F{yellow}●%f'
# zstyle ':vcs_info:*' unstagedstr ' %F{red}✗%f'

# # zstyle ':vcs_info:git:*' formats '[ %F{cyan}%b%f%c ]'
# zstyle ':vcs_info:git:*' actionformats '[ %F{cyan}%b%f %F{red}%a%f%c ]'

# # Update hook
# my_vcs_precmd() {
#   vcs_info
# }
# add-zsh-hook precmd my_vcs_precmd


# # --- Setup fzf if available ---
# if command -v fzf >/dev/null 2>&1; then
#   if [[ -f ~/.fzf/shell/completion.zsh ]] && [[ -f ~/.fzf/shell/key-bindings.zsh ]]; then
#     source ~/.fzf/shell/completion.zsh
#     source ~/.fzf/shell/key-bindings.zsh
#   elif command -v fzf-share >/dev/null 2>&1; then
#     # In case of alternative installations like via brew
#     source "$(brew --prefix)/opt/fzf/shell/completion.zsh"
#     source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"
#   fi
# fi

# --- Setup zoxide if installed ---
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi
