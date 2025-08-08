Yeah, the code fences inside a code fence nuked the formatting — GitHub would render that like a drunk markdown parser at 3 AM.
Let’s untangle it so it’s clean, copy-paste-ready, and GitHub-pretty:

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

This one will render properly on GitHub — nice monospace blocks where needed, no random nesting disasters.  

I can also tack on a **“Pull latest changes from GitHub”** section if you want the full workflow in one file so you never have to remember a thing. Want me to add that?
```
