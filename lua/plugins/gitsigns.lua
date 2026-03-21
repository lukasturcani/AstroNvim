return {
  "lewis6991/gitsigns.nvim",
  opts = function(_, opts)
    local orig = opts.on_attach
    opts.on_attach = function(bufnr)
      if orig then orig(bufnr) end
      vim.keymap.set("n", "<Leader>gd", function()
        if vim.wo.diff then
          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            if vim.wo[win].diff and vim.bo[vim.api.nvim_win_get_buf(win)].buftype ~= "" then
              vim.api.nvim_win_close(win, true)
              return
            end
          end
          vim.wo.diff = false
        else
          require("gitsigns").diffthis()
        end
      end, { buffer = bufnr, desc = "Toggle Git diff" })
    end
  end,
}
