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

    -- Performance: skip per-file git status in the file tree (dedicated git tabs handle this)
    opts.enable_git_status = false
    opts.filesystem = opts.filesystem or {}
    opts.filesystem.async_directory_scan = "always"
    opts.filesystem.use_libuv_file_watcher = false
  end,
}
