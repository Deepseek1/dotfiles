````markdown
# Dotfiles (Stow + GitHub)

Portable configs for Zsh, Tmux, Neovim, Starship, and Git. Managed with GNU Stow and versioned on GitHub.

---

## Quick start

```bash
git clone https://github.com/Deepseek1/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./install.sh
exec zsh -l
````

---

## Structure

```
git/.gitconfig
zsh/.zshrc
tmux/.tmux.conf
nvim/.config/nvim/init.lua
starship/.config/starship.toml
oh-my-zsh/.oh-my-zsh/custom/   # only my custom OMZ bits (themes/plugins I tweak)
```

Each subfolder is a Stow “package” that mirrors its location under `$HOME`.

---

## What `install.sh` does

* Ensures dependencies: `stow` (required), `tree` and `gh` (optional).
* Clones/updates **Oh My Zsh** into `~/.oh-my-zsh`.
* Links `oh-my-zsh/custom` from this repo (or merges, depending on your script).
* Runs Stow:

  * First run: `--adopt` (moves existing dotfiles into the repo structure).
  * Subsequent runs: `--restow` (refreshes symlinks).
* Idempotent; safe to re-run anytime.

---

## Oh My Zsh

**Policy**

* Do **not** track the OMZ framework in git.
* Keep only **custom** files under `oh-my-zsh/.oh-my-zsh/custom/`.
* Install third-party plugins into `~/.oh-my-zsh/custom/plugins/`.

**Ignore third-party plugin code in this repo**
Add to `.gitignore`:

```gitignore
oh-my-zsh/.oh-my-zsh/custom/plugins/
oh-my-zsh/.oh-my-zsh/custom/cache/
```

**Install plugins (manual)**

```bash
mkdir -p ~/.oh-my-zsh/custom/plugins
cd ~/.oh-my-zsh/custom/plugins
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting
git clone --depth=1 https://github.com/zsh-users/zsh-completions
```

**`.zshrc` plugin list**

```zsh
plugins=(
  git
  zsh-completions
  history-substring-search
  zsh-autosuggestions
  zsh-syntax-highlighting
)
```

> Keep `zsh-syntax-highlighting` last.

---

## Daily workflow

* Edit configs normally (`~/.zshrc`, `~/.tmux.conf`, etc.). They are symlinks into `~/dotfiles/...`.
* Commit and push when ready:

  ```bash
  cd ~/dotfiles
  git add -u            # or: git add -A if you added new files
  git commit -m "Update configs"
  git push
  ```

**Optional helper alias**

```zsh
alias dotpush='(cd ~/dotfiles && git add -u && git commit -m "Update configs" && git push)'
```

**Optional prompt reminder (warn on pending changes)**

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

## Re-stowing / adoption

* First run: `install.sh` auto-detects and uses `--adopt` if targets are real files.
* Later runs: `--restow` refreshes symlinks.
* Manual adoption:

  ```bash
  stow --target="$HOME" --adopt zsh tmux nvim git starship
  ```

---

## Docker notes (Unraid)

* Container user maps to UID 99 / GID 100. Files under `/mnt/user` are created as `nobody:users`.
* Common commands:

  ```bash
  docker compose up -d
  docker exec -it unraid-mgmt zsh
  docker compose build --no-cache && docker compose up -d
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

* **OMZ plugin “not found”**: ensure it’s cloned under `~/.oh-my-zsh/custom/plugins` and listed in `.zshrc`.
* **Green background dirs in `ls`**: world-writable (`ow`). Adjust `LS_COLORS` or directory permissions.
* **Stow collisions**: run once with `--adopt`, then `--restow`.
* **Unraid ownership**: `id` should show `uid=99(...) gid=100(users)`. Files in `/mnt/user` will be `nobody:users`.

---

```
```
