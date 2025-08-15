
-- Customize None-ls sources

---@type LazySpec
return {
  "nvimtools/none-ls.nvim",
  opts = function(_, opts)
    local null_ls = require "null-ls"

    local function is_site_packages(path)
      return path:match("/site%-packages/") or path:match("/dist%-packages/")
          or path:match("\\Lib\\site%-packages\\")
    end

    opts.sources = require("astrocore").list_insert_unique(opts.sources, {
      null_ls.builtins.diagnostics.mypy.with({
          runtime_condition = function(params)
            return params.bufname ~= "" and not is_site_packages(params.bufname)
          end,
        timeout = -1,
      }),
    })
  end,
}
