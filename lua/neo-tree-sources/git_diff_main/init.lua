local utils = require("neo-tree.utils")
local renderer = require("neo-tree.ui.renderer")
local items = require("neo-tree-sources.git_diff_main.lib.items")
local events = require("neo-tree.events")
local manager = require("neo-tree.sources.manager")
local git = require("neo-tree.git")

local M = {
  name = "git_diff_main",
  display_name = " 󰊢 Diff (main) ",
}

local wrap = function(func)
  return utils.wrap(func, M.name)
end

local debounce_timer = nil
local DEBOUNCE_MS = 500

local function ensure_git_base(state)
  local root = git.find_worktree_info(state.path or vim.fn.getcwd())
  if root then
    state.git_base_by_worktree = state.git_base_by_worktree or {}
    state.git_base_by_worktree[root] = "main"
  end
end

M.navigate = function(state, path, path_to_reveal, callback, async)
  state.path = path or state.path
  state.dirty = false
  ensure_git_base(state)
  if path_to_reveal then
    renderer.position.set(state, path_to_reveal)
  end
  items.get_git_status(state)
  if type(callback) == "function" then
    vim.schedule(callback)
  end
end

M.refresh = function()
  if debounce_timer then
    debounce_timer:stop()
  end
  debounce_timer = vim.defer_fn(function()
    debounce_timer = nil
    manager.refresh(M.name)
  end, DEBOUNCE_MS)
end

M.setup = function(config, global_config)
  if config.before_render then
    manager.subscribe(M.name, {
      event = events.BEFORE_RENDER,
      handler = function(state)
        local this_state = manager.get_state(M.name)
        if state == this_state then
          config.before_render(this_state)
        end
      end,
    })
  end

  if global_config.enable_refresh_on_write then
    manager.subscribe(M.name, {
      event = events.VIM_BUFFER_CHANGED,
      handler = function(args)
        if utils.is_real_file(args.afile) then
          M.refresh()
        end
      end,
    })
  end

  if config.bind_to_cwd then
    manager.subscribe(M.name, {
      event = events.VIM_DIR_CHANGED,
      handler = M.refresh,
    })
  end

  manager.subscribe(M.name, {
    event = events.GIT_EVENT,
    handler = M.refresh,
  })
end

return M
