#!/usr/bin/env zsh
# =============================================================================
# Dotfiles Git Status Checker
# =============================================================================
# 
# Provides visual warnings when dotfiles have uncommitted changes or unpushed commits.
# Helps prevent losing configuration changes and maintains sync with remote repository.
#
# Features:
# - Shows ⚠ warning for uncommitted changes (modified, added, deleted files)
# - Shows ⬆ warning for unpushed commits ahead of origin
# - Integrates with prompt via precmd hook
# - Only checks if dotfiles directory is a git repository
#
# Usage:
# - Automatically runs before each prompt
# - Manually call: check_dotfiles_changes
#
# =============================================================================

# Dotfiles tracking warning function
function check_dotfiles_changes() {
    local dfdir="$HOME/dotfiles"
    # Only check if the repo exists
    [[ -d "$dfdir/.git" ]] || return
    # Check for uncommitted changes
    if [[ -n "$(git -C "$dfdir" status --porcelain)" ]]; then
        print -P "%F{yellow}⚠ Dotfiles have uncommitted changes%f"
    else
        # Check if branch is ahead of origin
        if ! git -C "$dfdir" diff --quiet HEAD origin/$(git -C "$dfdir" symbolic-ref --short HEAD 2>/dev/null) 2>/dev/null; then
            print -P "%F{yellow}⬆ Dotfiles have commits not pushed to GitHub%f"
        fi
    fi
}