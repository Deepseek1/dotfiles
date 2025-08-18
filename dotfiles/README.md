# Dotfiles

Personal development environment configuration files managed with **bare git repository** method.

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/Deepseek1/dotfiles/main/dotfiles/bootstrap-bare.sh | bash
```

This will:
- Clone the repository as a bare git repo to `~/.dotfiles.git`
- Check out configuration files directly to their proper locations in `$HOME`
- Set up the `dot` alias for managing dotfiles
- Handle conflicts by backing up existing files

## Manual Installation

If you prefer to see what's happening:

```bash
# Clone as bare repository
git clone --bare https://github.com/Deepseek1/dotfiles.git $HOME/.dotfiles.git

# Create the dot alias
alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles.git/ --work-tree=$HOME'

# Configure to hide untracked files
dot config --local status.showUntrackedFiles no

# Backup existing configs that might conflict
mkdir -p ~/.config-backup
dot checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} ~/.config-backup/{} 2>/dev/null || true

# Checkout the files
dot checkout

# Add alias to shell config
echo "alias dot='/usr/bin/git --git-dir=\$HOME/.dotfiles.git/ --work-tree=\$HOME'" >> ~/.zshrc
```

## What's Included

- **zsh** - Shell configuration with oh-my-zsh
- **nvim** - Neovim configuration with Lazy.nvim and plugins
- **tmux** - Terminal multiplexer configuration with TPM and plugins
- **git** - Git configuration and aliases
- **starship** - Cross-shell prompt configuration
- **kitty** - Terminal emulator configuration
- **oh-my-posh** - Alternative prompt (disabled by default)
- **eza** - Modern ls replacement with custom theme
- **shell functions** - Additional utilities (rm-safety, fuzzy commands)

## Directory Structure

With bare git repository method, files live directly in their expected locations:

```
$HOME/
├── .zshrc
├── .gitconfig
├── .rm-safety.sh
├── functions/
│   ├── dotfiles-check.zsh
│   ├── fuzzy-listing.zsh
│   ├── fuzzy-nvim.zsh
│   └── index-config.zsh
└── .config/
    ├── nvim/
    │   ├── init.lua
    │   └── lua/
    ├── tmux/
    │   └── tmux.conf
    ├── starship.toml
    ├── kitty/
    │   ├── kitty.conf
    │   └── theme.conf
    ├── oh-my-posh/
    │   └── config.json
    └── eza/
        └── theme.yml
```

## Managing Dotfiles

After installation, use the `dot` alias to manage your dotfiles:

```bash
# Check status
dot status

# Add new config files
dot add ~/.config/newapp/config.toml

# Commit changes
dot commit -m "Update configs"

# Push to remote
dot push

# Pull updates
dot pull
```

## Updating on Another Machine

To update your dotfiles:

```bash
dot pull
```

That's it! No symlink management needed.

## Legacy Stow Setup

If you're migrating from the old stow-based setup:

1. **Backup current setup**: Push any uncommitted changes
2. **Remove stow symlinks**: `stow -D` all packages
3. **Use new bootstrap**: Run `bootstrap-bare.sh` 

Your old stow setup is preserved in the `stow-backup` branch.

## Customization

### Adding New Configs

To add a new program's configuration:

```bash
# Move config to proper location
mv ~/.config/newapp ~/.config/newapp

# Track with dot
dot add ~/.config/newapp

# Commit
dot commit -m "Add newapp configuration"
dot push
```

### Environment Variables

The bootstrap script supports several environment variables:

```bash
# Skip full install (only core packages)
FULL_INSTALL=0 bash bootstrap-bare.sh

# Skip oh-my-zsh installation
INSTALL_OMZ=0 bash bootstrap-bare.sh

# Skip starship installation  
INSTALL_STARSHIP=0 bash bootstrap-bare.sh

# Skip setting zsh as default shell
SET_DEFAULT_SHELL=0 bash bootstrap-bare.sh
```

## Troubleshooting

### Conflicting Files

If checkout fails due to existing files, they're automatically backed up to `~/.config-backup/`. Review and remove if not needed.

### Missing Oh-My-Zsh Plugins

If zsh plugins aren't working, they'll be installed automatically by the bootstrap script. Manual installation:

```bash
git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
```

### Tmux Plugins

If tmux plugins aren't working:

```bash
# Install TPM if missing
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm

# Install plugins manually (if prefix+I doesn't work)
~/.config/tmux/plugins/tpm/scripts/install_plugins.sh

# Reload tmux config
tmux source ~/.config/tmux/tmux.conf
```

### Neovim Issues

If Neovim plugins aren't installed:

```bash
nvim --headless "+Lazy! sync" +qa
```

## Advantages of Bare Git Method

- **No symlinks** - Files live where they belong
- **No extra tools** - Just git
- **Clean home directory** - No `~/dotfiles` folder cluttering
- **Standard git workflow** - Familiar commands with `dot` alias
- **Simpler mental model** - Your home directory IS the repo

## Supported Systems

- Linux (Debian/Ubuntu, Fedora/RHEL, Arch, openSUSE)
- macOS (with Homebrew)
- Android/Termux
- Docker containers
- WSL

## License

MIT