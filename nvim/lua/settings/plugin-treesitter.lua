local config = require("nvim-treesitter.configs")
config.setup({
  -- A list of parser names, or "all" (the five listed parsers should always be installed)
  ensure_installed = { "lua", "vim", "vimdoc", "yaml", "json", "bash", "javascript", "ruby", "diff" },
  auto_install = true,
  indent = {
    enable = true,
  },
  highlight = {
    enable = true,
  },
})
