-- set leaders BEFORE lazy.setup
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({ { "Failed to clone lazy.nvim:\n", "ErrorMsg" }, { out, "WarningMsg" } }, true, {})
    vim.fn.getchar(); os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- load all plugin specs from lua/plugins/*
require("lazy").setup({
  spec = { { import = "plugins" } },
  -- optional niceties:
  -- install = { colorscheme = { "habamax" } },
  -- checker = { enabled = true },
})

