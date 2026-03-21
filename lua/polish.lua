-- After session restore, the `diff` window option may be persisted from a
-- previous diff view, which causes gitsigns diffthis() to silently no-op.
vim.api.nvim_create_autocmd("User", {
  pattern = "ResessionLoadPost",
  group = vim.api.nvim_create_augroup("resession_diff_fix", { clear = true }),
  callback = function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.wo[win].diff then
        vim.wo[win].diff = false
      end
    end
  end,
})
