return {
  "folke/flash.nvim",
  version = "*", -- use latest release; lockfile will pin exact commit
  opts = {
    jump = { autojump = true, register = true, nohlsearch = true },
    modes = { search = { enabled = true } },
  },
  -- no `event` here → lazy-load on keys below
  keys = {
    { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,   desc = "Flash jump" },
    { "<c-s>", mode = "c",               function() require("flash").toggle() end, desc = "Toggle Flash in /? search" },
  },
}

