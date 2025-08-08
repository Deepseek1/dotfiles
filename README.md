
```markdown
# Dotfiles – Stow + GitHub Managed

Personal configuration files for Zsh, Tmux, Neovim, Starship, and Git.  
Arranged for easy installation using GNU Stow and stored in GitHub for portability.

---

## 📂 Structure

```

git/.gitconfig
zsh/.zshrc
tmux/.tmux.conf
nvim/.config/nvim/init.lua
starship/.config/starship.toml

````

Each subfolder represents a “package” for Stow, mirroring the layout inside `$HOME`.

---

## 🚀 Installation

```bash
git clone https://github.com/Deepseek1/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./install.sh
```
````

This will:

* Install `stow` if missing
* Symlink configs into `$HOME`
* Skip reinstallation if already applied

---

## 🔄 Sync Changes

**Check for changes:**

```bash
cd ~/dotfiles
git status
```

**Commit & push:**

```bash
git add -A
git commit -m "Update configs"
git push
```

---

## ⚠ Zsh Prompt Warnings

Your `.zshrc` includes a `precmd` hook that warns if:

* There are uncommitted changes:
  ⚠ Dotfiles have uncommitted changes
* There are commits not pushed to GitHub:
  ⬆ Dotfiles have commits not pushed to GitHub

---

## 📝 Nvim Quick Ops

**Delete all & paste cleanly:**

```vim
:%d
:set paste
i      " paste via terminal shortcut
:set nopaste
```

**Visual mode delete:**

```vim
ggVGd
```

---

## 🐳 Docker Usage

**Start:**

```bash
docker compose up -d
```

**Enter shell:**

```bash
docker exec -it unraid-mgmt zsh
```

**Rebuild:**

```bash
docker compose build --no-cache && docker compose up -d
```

---

## 👤 UID/GID Mapping

Inside the container:

```bash
id
# uid=99(hugo) gid=100(users) groups=100(users)
```

Ensures files in `/mnt/user` are owned by `nobody:users` on Unraid.

---

## 📦 Handy Tools Installed in Container

* `tree`
* `gh` (GitHub CLI)
* `stow`
* `neovim`
* `tmux`
* `starship`
* `git`
* `zsh`

```
Here you go — clean, copy-paste Markdown for your repo. No fluff, just the bits you’ll actually need later.

````markdown
# Dotfiles (Stow-managed)

Portable configs for Zsh, Tmux, Neovim, Starship, and Git. Applied via GNU Stow and stored in GitHub.

---

## Quick start

```bash
git clone https://github.com/Deepseek1/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./install.sh
exec zsh -l
````

---

## Layout

```
git/.gitconfig
zsh/.zshrc
tmux/.tmux.conf
nvim/.config/nvim/init.lua
starship/.config/starship.toml
oh-my-zsh/.oh-my-zsh/custom/   # only my custom bits go here (themes/plugins I tweak)
```

Stow symlinks these into `$HOME`.

---

## What `install.sh` does

* Ensures dependencies: `stow` (required). `tree`, `gh` (optional).
* Clones/updates **oh-my-zsh** into `~/.oh-my-zsh`.
* Links `oh-my-zsh/custom` from this repo (or merges, if you prefer).
* Installs common plugins if present in the script (or install manually).
* Runs Stow:

  * First run: `--adopt` (moves existing dotfiles into the repo structure).
  * Later runs: `--restow`.

Re-run anytime; it’s idempotent.

---

## Oh My Zsh: policy

* I **don’t track the framework** in Git.
* I keep only **custom** files under `oh-my-zsh/.oh-my-zsh/custom/`.
* Plugins are installed normally into `~/.oh-my-zsh/custom/plugins`.

Ignore third-party plugin code in this repo:

```gitignore
oh-my-zsh/.oh-my-zsh/custom/plugins/
oh-my-zsh/.oh-my-zsh/custom/cache/
```

### Install plugins (manual)

```bash
mkdir -p ~/.oh-my-zsh/custom/plugins
cd ~/.oh-my-zsh/custom/plugins
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting
git clone --depth=1 https://github.com/zsh-users/zsh-completions
```

`.zshrc` plugin list:

```zsh
plugins=(
  git
  zsh-completions
  history-substring-search
  zsh-autosuggestions
  zsh-syntax-highlighting
)
```

> Tip: keep `zsh-syntax-highlighting` last.

---

## Daily workflow

* Edit configs normally (`~/.zshrc`, `~/.tmux.conf`, etc.). They’re symlinks into `~/dotfiles/...`.
* Commit and push when ready:

```bash
cd ~/dotfiles
git add -u           # or: git add -A  (if you added new files)
git commit -m "Update configs"
git push
```

Optional alias:

```zsh
alias dotpush='(cd ~/dotfiles && git add -u && git commit -m "Update configs" && git push)'
```

### Prompt reminder (optional)

Add this to `.zshrc` to warn about pending changes:

```zsh
check_dotfiles_changes() {
  local df="$HOME/dotfiles"
  [[ -d "$df/.git" ]] || return
  if [[ -n "$(git -C "$df" status --porcelain --untracked-files=no)" ]]; then
    print -P "%F{yellow}⚠ Dotfiles have uncommitted changes%f"
  elif ! git -C "$df" diff --quiet HEAD origin/$(git -C "$df" symbolic-ref --short HEAD 2>/dev/null) 2>/dev/null; then
    print -P "%F{yellow}⬆ Dotfiles have commits not pushed%f"
  fi
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd check_dotfiles_changes
```

---

## Re-stowing / first-run adoption

* First run: `install.sh` uses `--adopt` if it finds real files (not symlinks) at targets.
* Later runs: `--restow` refreshes links.
* Force adoption manually:

```bash
stow --target="$HOME" --adopt zsh tmux nvim git starship
```

---

## GitHub SSH (optional quick bootstrap)

```bash
mkdir -p ~/.ssh && chmod 700 ~/.ssh
# paste private key from Vaultwarden
cat > ~/.ssh/id_ed25519_github <<'KEY'
<your private key>
KEY
chmod 600 ~/.ssh/id_ed25519_github
ssh-keygen -y -f ~/.ssh/id_ed25519_github > ~/.ssh/id_ed25519_github.pub
cat >> ~/.ssh/config <<'EOF'
Host github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_github
    IdentitiesOnly yes
EOF
chmod 600 ~/.ssh/config
ssh -T git@github.com
```

---

## Troubleshooting

* **Plugins “not found”**: install them under `~/.oh-my-zsh/custom/plugins`, ensure names in `.zshrc` match.
* **Green background dirs in `ls`**: those are world-writable (`ow`). Adjust `LS_COLORS` or permissions.
* **Stow collisions**: use `--adopt` once, then `--restow`.
* **Container file ownership** (Unraid): user is UID 99/GID 100. Files under `/mnt/user` land as `nobody:users`.

---

```
