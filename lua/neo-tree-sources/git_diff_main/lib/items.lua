local renderer = require("neo-tree.ui.renderer")
local file_items = require("neo-tree.sources.common.file-items")
local log = require("neo-tree.log")
local git = require("neo-tree.git")
local diff = require("neo-tree.git.diff")

local M = {}

M.get_git_status = function(state)
  if state.loading then
    return
  end
  state.loading = true

  local worktree_root = git.find_worktree_info(state.path or vim.fn.getcwd())
  state.path = worktree_root or state.path or vim.fn.getcwd()

  local context = file_items.create_context()
  context.state = state
  local root = file_items.create_item(context, state.path, "directory")
  root.name = vim.fn.fnamemodify(root.path, ":~")
  root.loaded = true
  root.search_pattern = state.search_pattern
  context.folders[root.path] = root

  if worktree_root then
    local status_lookup = diff.diff_name_status(worktree_root, "main", false)
    -- Store in worktree cache so the git_status component renderer can find it
    if status_lookup and git.worktrees[worktree_root] then
      git.worktrees[worktree_root].status_diff["main"] = status_lookup
    end
    -- Set git_base so the component looks up from status_diff
    state.git_base_by_worktree = { [worktree_root] = "main" }
    if status_lookup then
      for path, status in pairs(status_lookup) do
        if type(status) ~= "table" and status ~= "!" then
          local success, item = pcall(file_items.create_item, context, path)
          if not success then
            log.error("Error creating git_diff_main item for " .. path .. ": " .. item)
          else
            if item.type == "unknown" then
              item.type = "file"
            end
            item.extra = {
              git_status = status,
            }
          end
        end
      end
    end
  end

  state.default_expanded_nodes = {}
  for id, _ in pairs(context.folders) do
    table.insert(state.default_expanded_nodes, id)
  end
  file_items.advanced_sort(root.children, state)
  renderer.show_nodes({ root }, state)
  state.loading = false
end

return M
