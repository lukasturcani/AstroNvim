return {
  "lewis6991/gitsigns.nvim",
  opts = function(_, opts)
    local orig = opts.on_attach
    opts.on_attach = function(bufnr)
      if orig then orig(bufnr) end
      local diff_tab = nil

      local function open_diff(base, suffix)
        vim.keymap.set("n", "<Leader>g" .. suffix, function()
          if diff_tab and vim.api.nvim_tabpage_is_valid(diff_tab) then
            -- Close the diff tab, which restores us to the previous tab
            local tab_nr = vim.api.nvim_tabpage_get_number(diff_tab)
            vim.cmd("tabclose " .. tab_nr)
            diff_tab = nil
          else
            -- Open a new tab with the current buffer, then diff
            vim.cmd("tab split")
            diff_tab = vim.api.nvim_get_current_tabpage()
            require("gitsigns").diffthis(base)
          end
        end, { buffer = bufnr, desc = "Toggle Git diff" .. (base and (" against " .. base) or "") })
      end
      open_diff(nil, "d")
      open_diff("main", "dm")
    end
  end,
}
