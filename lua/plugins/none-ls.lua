
-- Customize None-ls sources

---@type LazySpec
return {
  "nvimtools/none-ls.nvim",
  opts = function(_, opts)
    local null_ls = require "null-ls"
    local helpers = require "null-ls.helpers"

    local function is_site_packages(path)
      return path:match("/site%-packages/") or path:match("/dist%-packages/")
          or path:match("\\Lib\\site%-packages\\")
    end

    local function find_project_root(startpath)
      local dir = startpath
      while dir and dir ~= "/" do
        if vim.fn.isdirectory(dir .. "/dev/linter") == 1 then return dir end
        dir = vim.fn.fnamemodify(dir, ":h")
      end
      return nil
    end

    local platform_linter = {
      name = "platform-linter",
      method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
      filetypes = { "python" },
      generator = helpers.generator_factory({
        command = "./dev/linter/target/release/linter",
        args = { "." },
        to_stdin = false,
        ignore_stderr = true,
        format = "line",
        check_exit_code = { 0, 1 },
        runtime_condition = function(params)
          if params.bufname == "" or is_site_packages(params.bufname) then return false end
          local root = find_project_root(vim.fn.fnamemodify(params.bufname, ":h"))
          return root ~= nil
        end,
        cwd = function(params)
          return find_project_root(vim.fn.fnamemodify(params.bufname, ":h"))
        end,
        on_output = function(line, params)
          local path, row, col, sev, rule, msg =
            line:match("^([^:]+):(%d+):(%d+): (%w+) %[([^%]]+)%] (.+)")
          if not path then return nil end

          local root = find_project_root(vim.fn.fnamemodify(params.bufname, ":h"))
          if not root then return nil end
          local rel_bufname = params.bufname:sub(#root + 2)
          if path ~= rel_bufname then return nil end

          return {
            row = tonumber(row),
            col = tonumber(col),
            severity = sev == "error" and 1 or 2,
            source = "platform-linter",
            code = rule,
            message = msg,
          }
        end,
      }),
    }

    opts.sources = require("astrocore").list_insert_unique(opts.sources, {
      null_ls.builtins.diagnostics.mypy.with({
          runtime_condition = function(params)
            return params.bufname ~= "" and not is_site_packages(params.bufname)
          end,
        timeout = -1,
      }),
      platform_linter,
    })
  end,
}
