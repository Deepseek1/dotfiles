return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  lazy = false,
  opts = {
    ensure_installed = {
      "lua", "python", "javascript", "typescript", "json", "yaml",
      "markdown", "bash", "html", "css", "go", "rust", "c", "cpp"
    },
    sync_install = false,
    auto_install = true,
    highlight = { enable = true },
    indent = { enable = true },
  },
}