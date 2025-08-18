#!/usr/bin/env bash
# Bare Git Repository Dotfiles Bootstrap
# This replaces the old stow-based bootstrap.sh

set -Eeuo pipefail

BARE_REPO="${BARE_REPO:-https://github.com/Deepseek1/dotfiles.git}"

say() { printf '[bootstrap] %s\n' "$*"; }

# Check if bare repo already exists
if [ -d "$HOME/.dotfiles.git" ]; then
  say "Bare repository already exists. Updating..."
  /usr/bin/git --git-dir="$HOME/.dotfiles.git" --work-tree="$HOME" pull
else
  say "Cloning bare repository..."
  git clone --bare "$BARE_REPO" "$HOME/.dotfiles.git"
  
  # Create dot alias function for this session
  dot() { /usr/bin/git --git-dir="$HOME/.dotfiles.git" --work-tree="$HOME" "$@"; }
  
  # Configure to hide untracked files
  dot config --local status.showUntrackedFiles no
  
  # Backup existing files that might conflict
  mkdir -p ~/.config-backup
  dot checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} ~/.config-backup/{} 2>/dev/null || true
  
  # Now checkout the files
  dot checkout
  
  say "Dotfiles checked out. Add this to your shell config:"
  say "alias dot='/usr/bin/git --git-dir=\$HOME/.dotfiles.git/ --work-tree=\$HOME'"
fi

say "Done! Your dotfiles are now managed with bare git repository."
say "Use 'dot status', 'dot add', 'dot commit', 'dot push' to manage your dotfiles."