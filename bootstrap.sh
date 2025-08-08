#!/usr/bin/env bash
# dotfiles bootstrap: fresh Linux => apply my configs
set -Eeuo pipefail

REPO="${REPO:-https://github.com/Deepseek1/dotfiles.git}"
DEST="${DEST:-$HOME/dotfiles}"

# Flags you can override: INSTALL_STARSHIP=0 SET_DEFAULT_SHELL=0 ADOPT=1
INSTALL_STARSHIP="${INSTALL_STARSHIP:-1}"
SET_DEFAULT_SHELL="${SET_DEFAULT_SHELL:-1}"
ADOPT="${ADOPT:-0}"

say() { printf '[bootstrap] %s\n' "$*"; }

# 0) Pre-auth sudo once (if present)
if [ "$EUID" -ne 0 ] && command -v sudo >/dev/null 2>&1; then sudo -v || true; fi

# 1) Install deps (git, stow, zsh, curl)
install_pkgs() {
  if   command -v apt    >/dev/null 2>&1; then sudo apt update && sudo apt install -y git stow zsh curl
  elif command -v dnf    >/dev/null 2>&1; then sudo dnf install -y git stow zsh curl
  elif command -v pacman >/dev/null 2>&1; then sudo pacman -Sy --needed git stow zsh curl
  elif command -v zypper >/dev/null 2>&1; then sudo zypper --non-interactive in git stow zsh curl
  else
    say "No supported package manager. Install git, stow, zsh, curl manually."
    exit 1
  fi
}
need=0; for c in git stow zsh curl; do command -v "$c" >/dev/null || need=1; done
[ "$need" = 1 ] && install_pkgs

# 2) Optional: install starship if missing
if [ "$INSTALL_STARSHIP" = 1 ] && ! command -v starship >/dev/null 2>&1; then
  say "Installing starship..."
  curl -fsSL https://starship.rs/install.sh | sh -s -- -y
fi

# 3) Clone or update repo
if [ ! -d "$DEST/.git" ]; then
  say "Cloning $REPO to $DEST"
  git clone --recurse-submodules "$REPO" "$DEST"
else
  say "Updating repo at $DEST"
  git -C "$DEST" pull --ff-only
fi

# 4) Apply dotfiles with stow
cd "$DEST"
PKGS=()
for d in zsh tmux git nvim starship; do [ -d "$d" ] && PKGS+=("$d"); done
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

# 5) Make zsh the default shell (optional)
if [ "$SET_DEFAULT_SHELL" = 1 ] && [ "$SHELL" != "$(command -v zsh)" ]; then
  if command -v chsh >/dev/null 2>&1; then
    say "Setting default shell to zsh (new sessions only)"
    chsh -s "$(command -v zsh)" "$USER" || true
  fi
fi

say "Done. Open a new shell or run: exec zsh"

