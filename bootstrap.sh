#!/usr/bin/env bash
# dotfiles bootstrap: fresh Linux => apply my configs
set -Eeuo pipefail

REPO="${REPO:-https://github.com/Deepseek1/dotfiles.git}"
DEST="${DEST:-$HOME/dotfiles}"

# Flags you can override
INSTALL_STARSHIP="${INSTALL_STARSHIP:-1}"
INSTALL_OMZ="${INSTALL_OMZ:-1}"
SET_DEFAULT_SHELL="${SET_DEFAULT_SHELL:-1}"
ADOPT="${ADOPT:-0}"
FULL_INSTALL="${FULL_INSTALL:-1}"  # New flag for full vs minimal install

say() { printf '[bootstrap] %s\n' "$*"; }

# 0) Pre-auth sudo once (if present)
if [ "$EUID" -ne 0 ] && command -v sudo >/dev/null 2>&1; then sudo -v || true; fi

# 1) Install deps
install_pkgs() {
  # Core packages (always installed)
  local PKGS_CORE="git stow zsh curl"
  
  # Development packages (installed if FULL_INSTALL=1)
  local PKGS_DEV=""
  
  if [ "$FULL_INSTALL" = 1 ]; then
    if   command -v apt    >/dev/null 2>&1; then 
      PKGS_DEV="neovim tmux tree gh openssh-client less file ripgrep fd-find build-essential"
      sudo apt update && sudo apt install -y $PKGS_CORE $PKGS_DEV
      # Fix fd name on Debian/Ubuntu
      [ -f /usr/bin/fdfind ] && sudo ln -sf /usr/bin/fdfind /usr/local/bin/fd
      
    elif command -v dnf    >/dev/null 2>&1; then 
      PKGS_DEV="neovim tmux tree gh openssh-clients less file ripgrep fd-find gcc make"
      sudo dnf install -y $PKGS_CORE $PKGS_DEV
      
    elif command -v pacman >/dev/null 2>&1; then 
      PKGS_DEV="neovim tmux tree github-cli openssh less file ripgrep fd base-devel"
      sudo pacman -Sy --needed $PKGS_CORE $PKGS_DEV
      
    elif command -v zypper >/dev/null 2>&1; then 
      PKGS_DEV="neovim tmux tree gh openssh less file ripgrep fd gcc make"
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
if [ "$FULL_INSTALL" = 1 ]; then
  # Check for all packages in full install
  need=0
  for c in git stow zsh curl nvim tmux; do 
    command -v "$c" >/dev/null 2>&1 || need=1
  done
else
  # Check only core packages
  need=0
  for c in git stow zsh curl; do 
    command -v "$c" >/dev/null 2>&1 || need=1
  done
fi
[ "$need" = 1 ] && install_pkgs

# 2) Optional: install oh-my-zsh
if [ "$INSTALL_OMZ" = 1 ] && [ ! -d "$HOME/.oh-my-zsh" ]; then
  say "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# 3) Optional: install starship
if [ "$INSTALL_STARSHIP" = 1 ] && ! command -v starship >/dev/null 2>&1; then
  say "Installing starship..."
  curl -fsSL https://starship.rs/install.sh | sh -s -- -y
fi

# 4) Clone or update repo
if [ ! -d "$DEST/.git" ]; then
  say "Cloning $REPO to $DEST"
  git clone --recurse-submodules "$REPO" "$DEST"
else
  say "Updating repo at $DEST"
  git -C "$DEST" pull --ff-only
fi

# 5) Apply dotfiles with stow
cd "$DEST"
PKGS=()
for d in zsh tmux git nvim starship shell; do [ -d "$d" ] && PKGS+=("$d"); done

if [ "${#PKGS[@]}" -gt 0 ]; then
  if [ "$ADOPT" = 1 ]; then
    # Move existing files into the repo and replace with symlinks
    stow -v -R --adopt -t "$HOME" "${PKGS[@]}"
    git status -s || true
  else
    stow -v -R -t "$HOME" "${PKGS[@]}"
  fi
else
  say "No stow packages found. Skipping."
fi

# 6) Make zsh the default shell (optional)
if [ "$SET_DEFAULT_SHELL" = 1 ] && [ "$SHELL" != "$(command -v zsh)" ]; then
  if command -v chsh >/dev/null 2>&1; then
    say "Setting default shell to zsh (new sessions only)"
    chsh -s "$(command -v zsh)" "$USER" || true
  fi
fi

say "Done. Open a new shell or run: exec zsh"

# Show what was installed
if [ "$FULL_INSTALL" = 1 ]; then
  say "Full development environment installed (neovim, tmux, ripgrep, etc.)"
else
  say "Minimal install complete. Run with FULL_INSTALL=1 for all dev tools."
fi
