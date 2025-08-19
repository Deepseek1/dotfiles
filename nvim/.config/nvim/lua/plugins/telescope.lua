return {
  -- core
  {
    "nvim-telescope/telescope.nvim",
    version = false, -- latest
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", function() require("telescope.builtin").find_files() end, desc = "Files" },
      { "<leader>fg", function() require("telescope.builtin").live_grep() end,  desc = "Live grep" },
      { "<leader>fb", function() require("telescope.builtin").buffers() end,    desc = "Buffers" },
      { "<leader>fh", function() require("telescope.builtin").help_tags() end,  desc = "Help tags" },
      { "<leader>fr", function() require("telescope.builtin").oldfiles() end,   desc = "Recent files" },
      { "<leader>fs", function() require("telescope.builtin").grep_string() end,desc = "Grep word under cursor" },
      { "<leader>/",  function() require("telescope.builtin").current_buffer_fuzzy_find() end, desc = "Search in buffer" },
    },
    opts = {
      defaults = {
        path_display = { "smart" },
        file_ignore_patterns = { "%.git/", "node_modules/", "dist/" },
        vimgrep_arguments = {
          "rg", "--color=never", "--no-heading", "--with-filename",
          "--line-number", "--column", "--smart-case",
          "--hidden", "--glob", "!.git/*",
        },
      },
      pickers = {
        find_files = {
          find_command =
            (vim.fn.executable("fd") == 1 and { "fd", "--type", "f", "--hidden", "--follow", "--exclude", ".git" })
            or (vim.fn.executable("fdfind") == 1 and { "fdfind", "--type", "f", "--hidden", "--follow", "--exclude", ".git" })
            or nil,
        },
      },
    },
  },
  -- optional: faster sorting via native fzf
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    cond = function() return vim.fn.executable("make") == 1 end,
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      pcall(function() require("telescope").load_extension("fzf") end)
    end,
  },
}

