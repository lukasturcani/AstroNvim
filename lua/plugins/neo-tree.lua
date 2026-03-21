return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = function(_, opts)
    -- Add custom source
    table.insert(opts.sources, "neo-tree-sources.git_diff_main")

    -- Add tab to source selector
    table.insert(opts.source_selector.sources, {
      source = "git_diff_main",
      display_name = " 󰊢 Diff (main) ",
    })

    -- Reuse git_status config for the custom source
    opts.git_diff_main = vim.deepcopy(opts.git_status or {})
  end,
}
