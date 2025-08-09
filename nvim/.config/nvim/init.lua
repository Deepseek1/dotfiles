-- ===========================
--   Neovim Starter Config
-- ===========================

-- --- Load Lazy Lua --- --
require("config.lazy")

-- --- Basic Settings ---
vim.opt.number = true           -- Show absolute line number
vim.opt.tabstop = 4             -- Tab width (spaces displayed as 4)
vim.opt.shiftwidth = 4          -- Auto-indent size
vim.opt.expandtab = true        -- Convert tabs to spaces
vim.opt.smartindent = true      -- Auto-indent intelligently
vim.opt.mouse = "a"             -- Enable mouse support
vim.opt.clipboard = "unnamedplus" -- Use system clipboard
vim.opt.ignorecase = true       -- Case-insensitive search
vim.opt.smartcase = true        -- ...unless uppercase is used
vim.opt.cursorline = true       -- Highlight current line

-- Auto-copy visual selections to clipboard
vim.keymap.set('v', 'y', '"+y', { desc = 'Yank to system clipboard' })
vim.keymap.set('v', 'Y', '"+Y', { desc = 'Yank line to system clipboard' })

-- File operations
vim.keymap.set('n', '<leader>w', ':w<CR>', { desc = 'Save file' })
vim.keymap.set('n', '<leader>q', ':q<CR>', { desc = 'Quit' })

-- OSC 52 clipboard support for SSH sessions
vim.g.clipboard = {
  name = 'OSC 52',
  copy = {
    ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
    ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
  },
  paste = {
    ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
    ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
  },
}

-- --- Visual Styling ---
vim.api.nvim_set_hl(0, "CursorLine", { bg = "#2A2A2A" }) -- Subtle background highlight
vim.api.nvim_set_hl(0, "LineNr", { fg = "#FFA500" })   -- Normal line numbers
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#FFB52E", bold = true }) -- Current line number

-- --- Norwegian Keyboard Remaps (Normal Mode) ---
vim.keymap.set('n', 'æ', '$')          -- End of line
vim.keymap.set('n', 'ø', '0')          -- Start of line
vim.keymap.set('n', '¨', '|')          -- Move to column
vim.keymap.set('n', '<A-~>', '~')      -- Swap case

-- --- Norwegian Keyboard Remaps (Insert Mode) ---
vim.keymap.set('i', '<A-4>', '$')      -- AltGr+4 fix
vim.keymap.set('i', '<A-7>', '{')
vim.keymap.set('i', '<A-0>', '}')
vim.keymap.set('i', '<A-¨>', '~')
vim.keymap.set('i', '<A-<>', '|')

-- --- Enhanced Delete/Cut Operations ---
-- Leader-based delete without yanking
vim.keymap.set({'n', 'v'}, '<leader>d', '"_d', { desc = 'Delete without yanking' })
vim.keymap.set('n', '<leader>dd', '"_dd', { desc = 'Delete line without yanking' })
vim.keymap.set({'n', 'v'}, '<leader>D', 'd', { desc = 'Cut (delete + yank)' })

-- Character operations
vim.keymap.set('n', 'x', '"_x', { desc = 'Delete char without yanking' })
vim.keymap.set('v', 'x', '"_x', { desc = 'Delete selection without yanking' })
vim.keymap.set('n', 'X', 'x', { desc = 'Cut char (like traditional Vim)' })
vim.keymap.set('v', 'X', 'd', { desc = 'Cut selection (like traditional Vim)' })

-- --- Navigation Enhancements ---
-- Center after search/jump actions
vim.keymap.set('n', 'n', 'nzz')     -- next search result
vim.keymap.set('n', 'N', 'Nzz')     -- previous search result
vim.keymap.set('n', 'G', 'Gzz')     -- end of file
vim.keymap.set('n', '{', '{zz')     -- paragraph back
vim.keymap.set('n', '}', '}zz')     -- paragraph forward
