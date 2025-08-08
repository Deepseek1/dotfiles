#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"  # run from repo root

# --- CONFIG ---
PACKAGES=(stow tree gh)
STOW_PKGS=(zsh tmux nvim git starship)
OMZ_DIR="$HOME/.oh-my-zsh"
REPO_CUSTOM="$PWD/oh-my-zsh/.oh-my-zsh/custom"

# sudo if not root
SUDO=""
[ "${EUID:-$(id -u)}" -ne 0 ] && SUDO="sudo"

echo "[*] Checking dependencies..."
missing=()
for pkg in "${PACKAGES[@]}"; do
  command -v "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
done

if [ "${#missing[@]}" -gt 0 ]; then
  if command -v apt-get >/dev/null 2>&1; then
    $SUDO apt-get update -y
    $SUDO apt-get install -y --no-install-recommends "${missing[@]}"
  elif command -v apk >/dev/null 2>&1; then
    $SUDO apk add --no-cache "${missing[@]}"
  else
    echo "[-] No supported package manager found. Install: ${missing[*]}"
    exit 1
  fi
else
  echo "  [=] all deps present: ${PACKAGES[*]}"
fi

# --- oh-my-zsh (clone if missing, link custom if present) ---
if [ ! -d "$OMZ_DIR" ]; then
  echo "[*] Cloning oh-my-zsh..."
  git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$OMZ_DIR"
else
  # keep it fresh, but don't fail the whole run if network is sad
  git -C "$OMZ_DIR" pull --ff-only || true
fi

if [ -d "$REPO_CUSTOM" ]; then
  echo "[*] Linking OMZ custom/"
  rm -rf "$OMZ_DIR/custom"
  ln -s "$REPO_CUSTOM" "$OMZ_DIR/custom"
fi

# --- STOW DOTFILES ---
echo "[*] Symlinking dotfiles into \$HOME"
STOW_FLAGS=(--target="$HOME" --restow)
# first run heuristic: if ~/.zshrc is not a symlink, adopt existing files
if [ ! -L "$HOME/.zshrc" ] && [ -e "$HOME/.zshrc" ]; then
  STOW_FLAGS=(--target="$HOME" --adopt)
fi
stow "${STOW_FLAGS[@]}" "${STOW_PKGS[@]}"

echo "[+] Dotfiles installed successfully!"
