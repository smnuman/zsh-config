#!/usr/bin/env zsh
# ~/.config/zsh/lib/pathtools.zsh
# The file is added in my shell(by .zshrc) from $ZDOTFOLDER/lib/pathtools.zsh 
# Best to source it from $ZDOTFOLDER/zsh-exports before any export PATH commands

# Usage e.g.: export_path "$HOME/.cargo/bin"
# Better use it with the alias below
export_path() {
    local dir="$1"
    local log_file="$ZDOTFOLDER/logs/pathlog.zlog"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    local before="$PATH"

    mkdir -p "${log_file:h}"  # creates the parent folder safely if "logs/" not available

    [[ ! -d "$dir" ]] && {
        echo "❌ Skipped: $dir not found"
        echo "[$timestamp] ❌ Not a directory: $dir" >> "$log_file"
        return 1
    }

    for existing in ${(s/:/)PATH}; do
        [[ "$existing" == "$dir" ]] && {
            echo "⚠️  Skipped: $dir already in PATH"
            echo "[$timestamp] ⚠️  Already present: $dir" >> "$log_file"
            return
        }
    done

    # Add and export
    PATH="$dir:$PATH"
    \export PATH

    local after="$PATH"
    echo "✅ Added: $dir"
    {
        echo "[$timestamp] ✅ PATH UPDATED: $dir"
        echo "    --- BEFORE ---"
        echo "$before" | tr ':' '\n' | sed 's/^/    /'
        echo "    --- AFTER ----"
        echo "$after" | tr ':' '\n' | sed 's/^/    /'
        echo ""
    } >> "$log_file"
}

# Usage e.g.: export "$HOME/.cargo/bin"
alias 'export PATH'='export_path'      # !important! do not remove this alias from here

# Usage e.g.: dedup_path()
dedup_path() {
    local -a seen deduped
    for dir in ${(s/:/)PATH}; do
        [[ -d "$dir" && ! ${seen[(r)$dir]} ]] && deduped+="$dir" && seen+="$dir"
    done
    typeset -g PATH="${(j<:>)deduped}"
    print -P "%F{blue}🧹 PATH deduplicated:%f"
}

# Usage e.g.: remove_path "$HOME/.cargo/bin"
remove_path() {
    local target="$1" new_path=""
    for dir in ${(s/:/)PATH}; do
        [[ "$dir" != "$target" ]] && new_path+="$dir:"
    done
    typeset -g PATH="${new_path%:}"
    print -P "%F{red}❌ Removed from PATH:%f $target"
}

# Usage: path_audit_run ./install.sh or path_audit_run brew install ...
path_audit_run() {
    local cmd=("$@")
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    local log_file="$ZDOTFOLDER/logs/pathlog.zlog"

    mkdir -p "${log_file:h}"

    local before_path="$PATH"
    local before_formatted=$(echo "$before_path" | tr ':' '\n')

    echo "\033[1;36m[$timestamp] 🚧 Running command: ${cmd[*]}\033[0m" >> "$log_file"
    echo "    --- PATH BEFORE ---" >> "$log_file"
    echo "$before_formatted" | sed 's/^/    /' >> "$log_file"

    # Run the command
    "${cmd[@]}"

    local after_path="$PATH"
    local after_formatted=$(echo "$after_path" | tr ':' '\n')

    echo "    --- PATH AFTER ----" >> "$log_file"
    echo "$after_formatted" | sed 's/^/    /' >> "$log_file"

    # Optional: Show diff inline
    echo "    --- DIFF (after - before) ---" >> "$log_file"
    diff <(echo "$before_formatted") <(echo "$after_formatted") | sed 's/^/    /' >> "$log_file"

    echo "" >> "$log_file"
}
