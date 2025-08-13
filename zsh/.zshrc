# Core oh-my-zsh setup
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

# Plugins (enhanced list)
plugins=(
  git z fzf sudo extract command-not-found colored-man-pages aliases
  zsh-completions history-substring-search zsh-autosuggestions 
  zsh-syntax-highlighting fzf-tab
)

# PATH exports
export PATH="$HOME/.local/bin:$HOME/.bun/bin:$PATH"
export BUN_INSTALL="$HOME/.bun"

# Tool configurations
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# Source private environment variables
[ -f ~/.env ] && source ~/.env

# Source oh-my-zsh
source "$ZSH/oh-my-zsh.sh"

# Editor and terminal
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

# History settings
HISTFILE="$HOME/.zsh_history"
HISTSIZE=200000
SAVEHIST=200000
setopt HIST_IGNORE_ALL_DUPS HIST_IGNORE_DUPS HIST_REDUCE_BLANKS SHARE_HISTORY EXTENDED_HISTORY INC_APPEND_HISTORY

# FZF configuration
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --no-ignore-vcs 2>/dev/null || fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Keybindings
bindkey -M emacs '^[[A' history-substring-search-up
bindkey -M emacs '^[[B' history-substring-search-down
bindkey '^[s' sudo-command-line

# Custom functions
function check_dotfiles_changes() { ... }
add-zsh-hook precmd check_dotfiles_changes

# Completions
autoload -Uz compinit
compinit -C
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Other tools
[ -f ~/.rm-safety.sh ] && source ~/.rm-safety.sh
eval "$(starship init zsh)"

# Permissions
umask 002
