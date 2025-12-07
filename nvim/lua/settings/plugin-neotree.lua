require("neo-tree").setup({
  filesystem = {
    filtered_items = {
      visible = true, -- This is what you want: If you set this to `true`, all "hide" just mean "dimmed out"
      hide_dotfiles = false,
      hide_gitignored = false,
    },
  },
  window = {
    mappings = {
      ["P"] = function(state)
        local node = state.tree:get_node()
        require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
      end,
    },
  },
  close_if_last_window = true,
})

vim.keymap.set("n", "nt", "<Cmd>Neotree toggle<CR>")
vim.keymap.set("n", "<C-\\>", "<Cmd>Neotree reveal<CR>")
