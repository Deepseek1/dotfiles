#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"   # ensure CWD is the dotfiles repo

# example usage:
# $SUDO apt-get update && $SUDO apt-get install -y foo bar

# --- CONFIG ---
PACKAGES=(stow tree gh)

# --- INSTALL MISSING PACKAGES ---
echo "[*] Checking dependencies..."
if command -v apt-get &>/dev/null; then
    sudo apt-get update -y
    for pkg in "${PACKAGES[@]}"; do
        if ! command -v "$pkg" &>/dev/null; then
            echo "  [+] Installing $pkg"
            sudo apt-get install -y --no-install-recommends "$pkg"
        else
            echo "  [=] $pkg already installed"
        fi
    done
elif command -v apk &>/dev/null; then
    for pkg in "${PACKAGES[@]}"; do
        if ! command -v "$pkg" &>/dev/null; then
            echo "  [+] Installing $pkg"
            sudo apk add --no-cache "$pkg"
        else
            echo "  [=] $pkg already installed"
        fi
    done
else
    echo "[-] No supported package manager found. Install stow manually."
    exit 1
fi

# --- STOW DOTFILES ---
echo "[*] Symlinking dotfiles into $HOME"
stow --target="$HOME" --adopt zsh tmux nvim git starship

echo "[+] Dotfiles installed successfully!"

