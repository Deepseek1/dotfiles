return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "<leader>e", function() require("nvim-tree.api").tree.toggle({ focus = true }) end, desc = "Explorer toggle" },
    { "<leader>E", function() require("nvim-tree.api").tree.find_file({ open = true, focus = true }) end, desc = "Explorer reveal file" },
  },
  init = function()
    -- recommended by nvim-tree: disable netrw early
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
  end,
  opts = {
    view = { width = 32, side = "left" },
    renderer = { group_empty = true },
    filters = {
      dotfiles = false,
      git_ignored = true,
    },
    update_focused_file = { enable = true, update_root = false },
    git = { enable = true },
  },
}

