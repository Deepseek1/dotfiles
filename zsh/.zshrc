# Core oh-my-zsh setup
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

# Plugins (enhanced list with all the best ones)
plugins=(
  git
  z                              # Jump to frequent directories
  fzf                            # Fuzzy finder integration
  sudo                           # Double ESC to add sudo
  extract                        # Extract any archive
  command-not-found              # Suggest packages to install
  colored-man-pages              # Better man page readability
  aliases                        # 'acs' to list all aliases
  zsh-completions
  history-substring-search
  zsh-autosuggestions
  zsh-syntax-highlighting
  fzf-tab                        # Better tab completion with fzf
)

# PATH exports
export PATH="$HOME/.local/bin:$HOME/.bun/bin:$PATH"
export BUN_INSTALL="$HOME/.bun"

# NVM setup (for Node.js development)
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# Source private environment variables (for API keys, etc.)
[ -f ~/.env ] && source ~/.env

# RM SAFELY SCRIPT LOCATION
[ -f ~/.rm-safety.sh ] && source ~/.rm-safety.sh

# Source oh-my-zsh
source "$ZSH/oh-my-zsh.sh"

# Editor and terminal settings
export EDITOR=nvim
export TERM=xterm-256color
export LS_COLORS="$LS_COLORS:ow=01;36:tw=01;34:"

# Aliases
alias ll='ls -lah --color=auto'
alias la='ls -A'
alias gpt='chatgpt'
alias ccusage='bunx --bun ccusage'
alias dotpush='cd ~/dotfiles && git add -u && git commit -m "Update configs" && git push && cd -'
alias fd=fdfind

# Modern tool aliases (if available)
command -v eza >/dev/null 2>&1 && alias ls='eza --icons' && alias ll='eza -l --icons' && alias la='eza -la --icons'
command -v bat >/dev/null 2>&1 && export BAT_THEME="gruvbox-dark" && alias cat='bat --style=plain'
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

# History settings
HISTFILE="$HOME/.zsh_history"
HISTSIZE=200000
SAVEHIST=200000
setopt HIST_IGNORE_ALL_DUPS HIST_IGNORE_DUPS HIST_REDUCE_BLANKS SHARE_HISTORY EXTENDED_HISTORY INC_APPEND_HISTORY

# Completion caching
autoload -Uz compinit
compinit -C

# FZF configuration
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --no-ignore-vcs 2>/dev/null || fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Keybindings
# History substring search
bindkey -M emacs '^[[A' history-substring-search-up
bindkey -M emacs '^[[B' history-substring-search-down

# Sudo from Alt+s
zle -N sudo-command-line
sudo-command-line() { 
    zle beginning-of-line
    LBUFFER="sudo $LBUFFER"
}
bindkey '^[s' sudo-command-line

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

# Add the dotfiles check as a precmd hook
autoload -Uz add-zsh-hook
add-zsh-hook precmd check_dotfiles_changes

# Bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Initialize starship prompt
eval "$(starship init zsh)"

# Set default file permissions
umask 002
