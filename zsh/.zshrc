export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

plugins=(
  git
  zsh-completions
  history-substring-search
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# RM SAFELY SCRIPT LOCATION ##
[ -f ~/.rm-safety.sh ] && source ~/.rm-safety.sh

source "$ZSH/oh-my-zsh.sh"
export EDITOR=nvim
alias ll='ls -lah --color=auto'
alias la='ls -A'
alias dotpush='cd ~/dotfiles && git add -u && git commit -m "Update configs" && git push && cd -'
eval "$(starship init zsh)"
export LS_COLORS="$LS_COLORS:ow=01;36:tw=01;34:"
export TERM=xterm-256color

# Warn if dotfiles repo has uncommitted or unpushed changes
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

autoload -Uz add-zsh-hook
add-zsh-hook precmd check_dotfiles_changes

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# History settings
HISTFILE="$HOME/.zsh_history"
HISTSIZE=200000
SAVEHIST=200000
setopt HIST_IGNORE_ALL_DUPS HIST_IGNORE_DUPS HIST_REDUCE_BLANKS SHARE_HISTORY EXTENDED_HISTORY INC_APPEND_HISTORY

# Completion caching
autoload -Uz compinit
compinit -C

# fzf config
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --no-ignore-vcs 2>/dev/null || fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# History substring search keybinds
bindkey -M emacs '^[[A' history-substring-search-up
bindkey -M emacs '^[[B' history-substring-search-down

# Sudo from Alt+s
zle -N sudo-command-line
sudo-command-line() { zle beginning-of-line; LBUFFER="sudo $LBUFFER"; }
bindkey '^[s' sudo-command-line

alias fd=fdfind

