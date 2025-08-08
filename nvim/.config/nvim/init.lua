-- ===========================
--   Neovim Starter Config
-- ===========================

-- --- Basic Settings ---
vim.opt.number = true           -- Show absolute line number
vim.opt.syntax = "on"            -- Syntax highlighting
vim.opt.tabstop = 4              -- Tab width (spaces displayed as 4)
vim.opt.shiftwidth = 4           -- Auto-indent size
vim.opt.expandtab = true         -- Convert tabs to spaces
vim.opt.smartindent = true       -- Auto-indent intelligently
vim.opt.mouse = "a"              -- Enable mouse support (handy if new)

-- --- Leader Key ---
vim.g.mapleader = ','            -- Easier leader key

-- --- Copy to Clipboard ---
vim.opt.clipboard = "unnamedplus"

-- --- Norwegian Keyboard Remaps (Normal Mode) ---
vim.keymap.set('n', 'æ', '$')          -- End of line
vim.keymap.set('n', 'ø', '0')          -- Start of line
vim.keymap.set('n', '<A-k>', '{')      -- Paragraph up
vim.keymap.set('n', '<A-j>', '}')      -- Paragraph down
vim.keymap.set('n', '¨', '|')          -- Move to column
vim.keymap.set('n', '<A-~>', '~')      -- Swap case

-- --- Norwegian Keyboard Remaps (Insert Mode) ---
vim.keymap.set('i', '<A-4>', '$')      -- AltGr+4 fix
vim.keymap.set('i', '<A-7>', '{')
vim.keymap.set('i', '<A-0>', '}')
vim.keymap.set('i', '<A-¨>', '~')
vim.keymap.set('i', '<A-<>', '|')

-- --- Quality of Life ---
vim.opt.ignorecase = true              -- Case-insensitive search
vim.opt.smartcase = true               -- ...unless uppercase is used
vim.opt.clipboard = "unnamedplus"      -- Use system clipboard

-- --- line number and line color ---
vim.opt.cursorline = true
vim.api.nvim_set_hl(0, "CursorLine", { bg = "#2A2A2A" }) -- Subtle background highlight

-- Line numbers: make them orange
vim.api.nvim_set_hl(0, "LineNr", { fg = "#FFA500" })   -- Normal line numbers
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#FFB52E", bold = true }) -- Current line number

-- Make 'd' delete (discard) without copying
vim.keymap.set({'n', 'v'}, 'd', '"_d', { desc = 'Delete without yanking' })
vim.keymap.set('n', 'dd', '"_dd', { desc = 'Delete line without yanking' })

-- Make 'D' cut (delete + copy into register, old Vim behavior)
vim.keymap.set({'n', 'v'}, 'D', 'd', { desc = 'Cut (delete + yank)' })

-- 'x' deletes character silently (black hole register)
vim.keymap.set('n', 'x', '"_x', { desc = 'Delete char without yanking' })
vim.keymap.set('v', 'x', '"_x', { desc = 'Delete selection without yanking' })

-- 'X' becomes traditional cut behavior (delete + yank)
vim.keymap.set('n', 'X', 'x', { desc = 'Cut char (like traditional Vim)' })
vim.keymap.set('v', 'X', 'd', { desc = 'Cut selection (like traditional Vim)' })

-- Center after search/jump actions
vim.keymap.set('n', 'n', 'nzz')     -- next search result
vim.keymap.set('n', 'N', 'Nzz')     -- previous search result
vim.keymap.set('n', 'G', 'Gzz')     -- end of file
vim.keymap.set('n', '{', '{zz')     -- paragraph back
vim.keymap.set('n', '}', '}zz')     -- paragraph forward
