return {
  "Mofiqul/dracula.nvim",
  opts = {
    overrides = function(colors)
      return {
        -- Subtle tinted backgrounds so syntax highlighting remains visible
        DiffAdd = { bg = "#2e4940", fg = "NONE" },
        DiffChange = { bg = "#3e3a53", fg = "NONE" },
        DiffDelete = { bg = "#48303b", fg = colors.red },
        DiffText = { bg = "#534641", fg = "NONE" },
      }
    end,
  },
}
