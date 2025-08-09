#!/usr/bin/env bash
# dotfiles bootstrap: fresh Linux => apply my configs
set -Eeuo pipefail

REPO="${REPO:-https://github.com/Deepseek1/dotfiles.git}"
DEST="${DEST:-$HOME/dotfiles}"

# Flags you can override
INSTALL_STARSHIP="${INSTALL_STARSHIP:-1}"
INSTALL_OMZ="${INSTALL_OMZ:-1}"
SET_DEFAULT_SHELL="${SET_DEFAULT_SHELL:-1}"
FULL_INSTALL="${FULL_INSTALL:-1}"

say() { printf '[bootstrap] %s\n' "$*"; }

# 0) Pre-auth sudo once (if present)
if [ "$EUID" -ne 0 ] && command -v sudo >/dev/null 2>&1; then 
  sudo -v || true
fi

# 1) Install deps
install_pkgs() {
  local PKGS_CORE="git stow zsh curl wget"
  local PKGS_DEV=""
  
  if [ "$FULL_INSTALL" = 1 ]; then
    # Note: We don't install neovim from package manager - we'll get it from GitHub
    if   command -v apt    >/dev/null 2>&1; then 
      PKGS_DEV="tmux tree gh openssh-client less file ripgrep fd-find build-essential"
      sudo apt update && sudo apt install -y $PKGS_CORE $PKGS_DEV
      # Fix fd name on Debian/Ubuntu
      [ -f /usr/bin/fdfind ] && sudo ln -sf /usr/bin/fdfind /usr/local/bin/fd
      
    elif command -v dnf    >/dev/null 2>&1; then 
      PKGS_DEV="tmux tree gh openssh-clients less file ripgrep fd-find gcc make"
      sudo dnf install -y $PKGS_CORE $PKGS_DEV
      
    elif command -v pacman >/dev/null 2>&1; then 
      PKGS_DEV="tmux tree github-cli openssh less file ripgrep fd base-devel"
      sudo pacman -Sy --needed $PKGS_CORE $PKGS_DEV
      
    elif command -v zypper >/dev/null 2>&1; then 
      PKGS_DEV="tmux tree gh openssh less file ripgrep fd gcc make"
      sudo zypper --non-interactive in $PKGS_CORE $PKGS_DEV
    else
      say "No supported package manager. Install packages manually."
      exit 1
    fi
  else
    # Minimal install - just core packages
    if   command -v apt    >/dev/null 2>&1; then sudo apt update && sudo apt install -y $PKGS_CORE
    elif command -v dnf    >/dev/null 2>&1; then sudo dnf install -y $PKGS_CORE
    elif command -v pacman >/dev/null 2>&1; then sudo pacman -Sy --needed $PKGS_CORE
    elif command -v zypper >/dev/null 2>&1; then sudo zypper --non-interactive in $PKGS_CORE
    fi
  fi
}

# Check if we need to install packages
need=0
if [ "$FULL_INSTALL" = 1 ]; then
  for c in git stow zsh curl wget tmux; do 
    command -v "$c" >/dev/null 2>&1 || need=1
  done
else
  for c in git stow zsh curl wget; do 
    command -v "$c" >/dev/null 2>&1 || need=1
  done
fi
[ "$need" = 1 ] && install_pkgs

# 2) Install latest stable Neovim from GitHub
install_neovim() {
  if ! command -v nvim >/dev/null 2>&1; then
    say "Installing latest stable Neovim from GitHub..."
    cd /tmp
    
    # Get the latest stable AppImage (v0.11.3 as of now)
    wget -q https://github.com/neovim/neovim/releases/download/v0.11.3/nvim-linux-x86_64.appimage
    chmod u+x nvim-linux-x86_64.appimage
    
    # Extract it (works without FUSE)
    ./nvim-linux-x86_64.appimage --appimage-extract >/dev/null 2>&1
    
    # Move the entire extracted directory to /opt
    sudo rm -rf /opt/nvim
    sudo mv squashfs-root /opt/nvim
    
    # Create symlink for the binary
    sudo ln -sf /opt/nvim/usr/bin/nvim /usr/local/bin/nvim
    
    # Cleanup
    rm nvim-linux-x86_64.appimage
    
    say "Neovim installed: $(nvim --version | head -1)"
  else
    say "Neovim already installed: $(nvim --version | head -1)"
  fi
}

[ "$FULL_INSTALL" = 1 ] && install_neovim

# 3) Clone or update repo FIRST (before oh-my-zsh)
if [ ! -d "$DEST/.git" ]; then
  say "Cloning $REPO to $DEST"
  git clone --recurse-submodules "$REPO" "$DEST"
else
  say "Updating repo at $DEST"
  git -C "$DEST" pull --ff-only
fi

# 4) Apply dotfiles with stow BEFORE installing oh-my-zsh
# This ensures OUR configs are in place first
cd "$DEST"
PKGS=""
for d in zsh tmux git nvim starship shell; do 
  if [ -d "$d" ]; then
    PKGS="$PKGS $d"
  fi
done

PKGS="${PKGS# }"  # Trim leading space

if [ -n "$PKGS" ]; then
  say "Applying dotfiles: $PKGS"
  # Remove any existing config files that might interfere (they're probably from old installs)
  [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ] && mv "$HOME/.zshrc" "$HOME/.zshrc.backup"
  
  # Apply our configs
  stow -v -R -t "$HOME" $PKGS
else
  say "No stow packages found. Check your dotfiles structure."
fi

# 5) NOW install oh-my-zsh (AFTER stowing, so it sees our .zshrc exists)
if [ "$INSTALL_OMZ" = 1 ]; then
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    say "Installing Oh My Zsh..."
    # Just clone it, don't run the installer (which would overwrite .zshrc)
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
  fi
  
  # Install custom plugins if missing
  ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  [ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ] && \
    git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
  [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && \
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# 6) Install starship
if [ "$INSTALL_STARSHIP" = 1 ] && ! command -v starship >/dev/null 2>&1; then
  say "Installing starship..."
  curl -fsSL https://starship.rs/install.sh | sh -s -- -y
fi

# 7) Install Neovim plugins
if command -v nvim >/dev/null 2>&1 && [ -d "$HOME/.config/nvim" ]; then
  say "Installing Neovim plugins..."
  nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
fi

# 8) Make zsh the default shell
if [ "$SET_DEFAULT_SHELL" = 1 ] && [ "$SHELL" != "$(command -v zsh)" ]; then
  if command -v chsh >/dev/null 2>&1; then
    say "Setting default shell to zsh (new sessions only)"
    chsh -s "$(command -v zsh)" "$USER" || true
  fi
fi

say "Done! Open a new shell or run: exec zsh"

# Show what was installed
if [ "$FULL_INSTALL" = 1 ]; then
  say "Full development environment installed"
else
  say "Minimal install complete. Run with FULL_INSTALL=1 for all dev tools."
fi
