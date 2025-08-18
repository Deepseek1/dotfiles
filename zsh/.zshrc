# Core oh-my-zsh setup
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

# Plugins (keeping all for better functionality)
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


# FZF setup - auto-detect installation path
if [ -d "/opt/homebrew/opt/fzf" ]; then
  export FZF_BASE="/opt/homebrew/opt/fzf"  # macOS Apple Silicon
elif [ -d "/usr/local/opt/fzf" ]; then
  export FZF_BASE="/usr/local/opt/fzf"     # macOS Intel
elif [ -d "/usr/share/fzf" ]; then
  export FZF_BASE="/usr/share/fzf"         # Ubuntu/Debian
elif [ -d "/usr/share/doc/fzf" ]; then
  export FZF_BASE="/usr/share/doc/fzf"     # Some other Linux distros
fi

# Source private environment variables (for API keys, etc.)
# WARNING: Only source if you trust the contents and need these vars in all shells
# Consider using direnv or manual sourcing for project-specific variables
[ -f ~/.env ] && [ -r ~/.env ] && source ~/.env


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
alias vim='nvim'              # Use neovim instead of vim
alias zvim='znvim'            # Shorter alias for fuzzy nvim
# fd/fdfind compatibility (Ubuntu/Debian use fdfind)
if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
  alias fd=fdfind
fi

# Modern tool aliases (if available)
if command -v eza >/dev/null 2>&1; then
  # Colorful eza setup
  export EXA_COLORS="di=1;36:ln=1;35:so=1;32:pi=1;33:ex=1;31:bd=1;34:cd=1;33:su=1;41:sg=1;46:tw=1;42:ow=1;43"
  alias ls='eza --icons --color=always --group-directories-first'
  alias ll='eza -l --icons --color=always --group-directories-first --git'
  alias la='eza -la --icons --color=always --group-directories-first --git'
  alias lt='eza --tree --icons --color=always --level=2'
fi
command -v bat >/dev/null 2>&1 && export BAT_THEME="gruvbox-dark" && alias cat='bat --style=numbers'
# Initialize zoxide normally (lazy loading was causing issues)
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# History settings
HISTFILE="$HOME/.zsh_history"
HISTSIZE=200000
SAVEHIST=200000
setopt HIST_IGNORE_ALL_DUPS HIST_IGNORE_DUPS HIST_REDUCE_BLANKS SHARE_HISTORY EXTENDED_HISTORY INC_APPEND_HISTORY

# Completion caching
autoload -Uz compinit
# Use -C for faster startup (skips security check) - only safe if you trust all completion files
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

# Sudo from Alt+s (and Ctrl+X+S for macOS compatibility)
zle -N sudo-command-line
sudo-command-line() { 
    zle beginning-of-line
    LBUFFER="sudo $LBUFFER"
}
bindkey '^[s' sudo-command-line    # Alt+S (if Meta key enabled)
bindkey '^Xs' sudo-command-line    # Ctrl+X then S (always works on macOS)

# Load custom functions and utilities
# - rm-safety.sh: Safe rm command with trash functionality
# - dotfiles-check.zsh: Git status warnings for uncommitted dotfiles
# - fuzzy-listing.zsh: Smart directory listing (zls, zll, zla) 
# - fuzzy-nvim.zsh: Intelligent file finder and editor (znvim)
[ -f ~/.rm-safety.sh ] && source ~/.rm-safety.sh

# Load shell functions
source "$HOME/dotfiles/shell/functions/dotfiles-check.zsh"
source "$HOME/dotfiles/shell/functions/fuzzy-listing.zsh" 
source "$HOME/dotfiles/shell/functions/fuzzy-nvim.zsh"
source "$HOME/dotfiles/shell/functions/index-config.zsh"

# Add the dotfiles check as a precmd hook (disabled for performance)
# autoload -Uz add-zsh-hook
# add-zsh-hook precmd check_dotfiles_changes

# Bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Enable tab completion for hidden files/directories
setopt globdots

# Hide . and .. from tab completion
zstyle ':completion:*' special-dirs false

# Initialize Oh-My-Posh with transient prompt for clean history
if command -v oh-my-posh >/dev/null 2>&1; then
  eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/config.json)"
  # Enable transient prompt to minimize previous prompts
  enable_poshtransientprompt
fi

# Add spacing before each prompt (disabled)
# precmd() {
#   echo
# }

# Initialize Starship prompt
# if command -v starship >/dev/null 2>&1; then
#   eval "$(starship init zsh)"
# fi

# Set default file permissions
umask 002

# Benchmark function to test shell startup time
zsh-bench() {
  echo "Testing shell startup time (10 runs)..."
  for i in {1..10}; do
    time zsh -i -c exit
  done
}


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

