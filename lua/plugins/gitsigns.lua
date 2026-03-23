return {
  "lewis6991/gitsigns.nvim",
  opts = function(_, opts)
    local orig = opts.on_attach
    opts.on_attach = function(bufnr)
      if orig then orig(bufnr) end
      local diff_tab = nil

      local function get_neotree_source()
        local ok, manager = pcall(require, "neo-tree.sources.manager")
        if not ok then return nil end
        for _, source in ipairs({ "git_diff_main", "git_status" }) do
          local state = manager.get_state(source)
          if state and state.path then return source end
        end
        return nil
      end

      vim.keymap.set("n", "<Leader>gd", function()
        if diff_tab and vim.api.nvim_tabpage_is_valid(diff_tab) then
          local tab_nr = vim.api.nvim_tabpage_get_number(diff_tab)
          vim.cmd("tabclose " .. tab_nr)
          diff_tab = nil
        else
          local source = get_neotree_source()
          local base = nil
          if source == "git_diff_main" then base = "main" end
          vim.cmd("tab split")
          diff_tab = vim.api.nvim_get_current_tabpage()
          local file_win = vim.api.nvim_get_current_win()
          if source then vim.cmd("Neotree show " .. source) end
          vim.api.nvim_set_current_win(file_win)
          require("gitsigns").diffthis(base)
        end
      end, { buffer = bufnr, desc = "Toggle Git diff (auto-detects base from Neo-tree)" })
    end
  end,
}
