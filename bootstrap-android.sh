#!/data/data/com.termux/files/usr/bin/bash
# dotfiles bootstrap: Termux Android => apply my configs
set -Eeuo pipefail

REPO="${REPO:-https://github.com/Deepseek1/dotfiles.git}"
DEST="${DEST:-$HOME/dotfiles}"

# Flags you can override
INSTALL_OHMYPOSH="${INSTALL_OHMYPOSH:-1}"
INSTALL_OMZ="${INSTALL_OMZ:-1}"
FULL_INSTALL="${FULL_INSTALL:-1}"
SETUP_STORAGE="${SETUP_STORAGE:-1}"

say() { printf '[bootstrap-android] %s\n' "$*"; }

# Ensure we're running in Termux
if [[ ! -d "/data/data/com.termux" ]]; then
  say "Error: This script is designed for Termux on Android"
  say "Please run this script inside the Termux app"
  exit 1
fi

# Setup storage access if requested
if [ "$SETUP_STORAGE" = 1 ] && [ ! -d "$HOME/storage" ]; then
  say "Setting up storage access..."
  termux-setup-storage || say "Storage setup failed or denied - continuing anyway"
fi

# 1) Install packages using pkg (Termux package manager)
install_pkgs() {
  local PKGS_CORE="git stow curl wget unzip"
  local PKGS_DEV=""
  
  say "Updating package lists..."
  pkg update
  
  if [ "$FULL_INSTALL" = 1 ]; then
    # Full development environment packages for Termux
    PKGS_DEV="tmux tree gh openssh less file ripgrep fd build-essential neovim procps htop jq python fzf bat eza zoxide nodejs"
    say "Installing full development environment..."
    pkg install -y $PKGS_CORE $PKGS_DEV
  else
    say "Installing core packages..."
    pkg install -y $PKGS_CORE
  fi
}

# Check if we need to install packages
need=0
if [ "$FULL_INSTALL" = 1 ]; then
  # Check for all the tools we need
  for c in git stow curl wget tmux nvim tree gh less rg fd htop jq python fzf bat eza zoxide; do 
    command -v "$c" >/dev/null 2>&1 || need=1
  done
else
  for c in git stow curl wget unzip; do 
    command -v "$c" >/dev/null 2>&1 || need=1
  done
fi
[ "$need" = 1 ] && install_pkgs

# Install zsh separately as it requires additional setup
if ! command -v zsh >/dev/null 2>&1; then
  say "Installing zsh..."
  pkg install -y zsh
fi

# 2) Clone or update repo
if [ ! -d "$DEST/.git" ]; then
  say "Cloning $REPO to $DEST"
  git clone --recurse-submodules "$REPO" "$DEST"
else
  say "Updating repo at $DEST"
  git -C "$DEST" pull --ff-only
fi

# 3) Apply dotfiles with stow BEFORE installing oh-my-zsh
cd "$DEST"
PKGS=""
for d in zsh tmux git nvim shell kitty oh-my-posh eza; do 
  if [ -d "$d" ]; then
    PKGS="$PKGS $d"
  fi
done

PKGS="${PKGS# }"  # Trim leading space

if [ -n "$PKGS" ]; then
  say "Applying dotfiles: $PKGS"
  # Remove any existing config files that might interfere
  [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ] && mv "$HOME/.zshrc" "$HOME/.zshrc.backup"
  
  # Apply our configs
  stow -v -R -t "$HOME" $PKGS
else
  say "No stow packages found. Check your dotfiles structure."
fi

# 4) Install oh-my-zsh (AFTER stowing, so it sees our .zshrc exists)
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
  [ ! -d "$ZSH_CUSTOM/plugins/fzf-tab" ] && \
    git clone https://github.com/Aloxaf/fzf-tab "$ZSH_CUSTOM/plugins/fzf-tab"
fi

# 5) Install oh-my-posh for Termux
if [ "$INSTALL_OHMYPOSH" = 1 ] && ! command -v oh-my-posh >/dev/null 2>&1; then
  say "Installing oh-my-posh for Termux..."
  
  # Create local bin directory
  mkdir -p "$HOME/.local/bin"
  
  # Download and install oh-my-posh binary for Android ARM64
  if [ "$(uname -m)" = "aarch64" ]; then
    ARCH="arm64"
  else
    ARCH="arm"
  fi
  
  say "Downloading oh-my-posh for Android ($ARCH)..."
  curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$HOME/.local/bin"
  
  # Add to PATH if not already there
  if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
    say "Added ~/.local/bin to PATH"
  fi
fi

# 6) Install Neovim plugins
if command -v nvim >/dev/null 2>&1 && [ -d "$HOME/.config/nvim" ]; then
  say "Installing Neovim plugins..."
  nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
fi

# 7) Install TPM (Tmux Plugin Manager)
if command -v tmux >/dev/null 2>&1 && [ ! -d "$HOME/.config/tmux/plugins/tpm" ]; then
  say "Installing TPM (Tmux Plugin Manager)..."
  mkdir -p "$HOME/.config/tmux/plugins"
  git clone https://github.com/tmux-plugins/tpm "$HOME/.config/tmux/plugins/tpm"
fi

# 8) Install NVM (Node Version Manager) if not already installed via pkg
if [ "$FULL_INSTALL" = 1 ] && [ ! -d "$HOME/.nvm" ] && ! command -v node >/dev/null 2>&1; then
  say "Installing NVM (Node Version Manager)..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
  
  # Source NVM immediately for current session
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  
  # Install latest LTS Node by default
  say "Installing Node.js LTS..."
  nvm install --lts
  nvm use --lts
fi

# 9) Install Nerd Fonts for icons in prompt and terminal
say "Installing Nerd Fonts for better icon support..."
mkdir -p "$HOME/.termux"

# Download and install JetBrainsMono Nerd Font (reliable choice for terminals)
if [ ! -f "$HOME/.termux/font.ttf" ]; then
  say "Downloading JetBrainsMono Nerd Font..."
  cd "$HOME/.termux"
  curl -fLO "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip"
  
  if [ -f "JetBrainsMono.zip" ]; then
    # Extract and install font with overwrite
    unzip -o JetBrainsMono.zip
    
    # Copy the regular variant as font.ttf
    if [ -f "JetBrainsMonoNerdFont-Regular.ttf" ]; then
      cp "JetBrainsMonoNerdFont-Regular.ttf" "font.ttf"
      
      # Cleanup zip and other font files (keep font.ttf)
      rm -f JetBrainsMono.zip
      find . -name "*.ttf" -not -name "font.ttf" -delete 2>/dev/null || true
      find . -name "*.otf" -delete 2>/dev/null || true
      
      say "Nerd Font installed successfully."
      
      # Reload Termux settings if command exists
      if command -v termux-reload-settings >/dev/null 2>&1; then
        say "Reloading Termux settings..."
        termux-reload-settings
      else
        say "Please restart Termux to apply the new font."
      fi
    else
      say "Warning: Could not find JetBrainsMonoNerdFont-Regular.ttf. Manual installation may be needed."
      rm -f *.zip 2>/dev/null || true
    fi
  else
    say "Warning: Could not download JetBrainsMono Nerd Font."
  fi
  
  cd "$DEST"
fi

# 10) Create a shell switching script since chsh is not available in Termux
if command -v zsh >/dev/null 2>&1; then
  say "Creating zsh launcher script..."
  cat > "$HOME/.switch-to-zsh" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# Launch zsh as default shell in Termux
# Add this to your .bashrc: [ -f ~/.switch-to-zsh ] && exec ~/.switch-to-zsh
if [ "$SHELL" != "$(command -v zsh)" ]; then
  export SHELL="$(command -v zsh)"
  exec zsh
fi
EOF
  chmod +x "$HOME/.switch-to-zsh"
  
  # Add to .bashrc if it exists and doesn't already contain the launcher
  if [ -f "$HOME/.bashrc" ] && ! grep -q ".switch-to-zsh" "$HOME/.bashrc"; then
    echo '# Auto-switch to zsh' >> "$HOME/.bashrc"
    echo '[ -f ~/.switch-to-zsh ] && exec ~/.switch-to-zsh' >> "$HOME/.bashrc"
    say "Added zsh auto-switch to .bashrc"
  fi
fi

# 11) Termux-specific optimizations
say "Applying Termux-specific optimizations..."

# Enable hardware keyboard support
if [ ! -f "$HOME/.termux/termux.properties" ]; then
  mkdir -p "$HOME/.termux"
  cat > "$HOME/.termux/termux.properties" << 'EOF'
# Hardware keyboard support
extra-keys = [['ESC','/','-','HOME','UP','END','PGUP'],['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN']]

# Allow external apps to execute commands
allow-external-apps = true
EOF
fi

say "Done! Please restart Termux or run: exec zsh"

# Show what was installed
if [ "$FULL_INSTALL" = 1 ]; then
  say "Full development environment installed for Termux"
else
  say "Minimal install complete. Run with FULL_INSTALL=1 for all dev tools."
fi

# Termux-specific notes
say "Termux-specific notes:"
say "  - Your dotfiles are in: $DEST"
say "  - Configuration files are in: $HOME"
say "  - Termux prefix (system files): $PREFIX"
say "  - To access Android storage, ensure you ran termux-setup-storage"
say "  - Use 'pkg install <package>' to install additional packages"
say "  - Hardware keyboard shortcuts are configured in ~/.termux/termux.properties"