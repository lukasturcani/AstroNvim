local renderer = require("neo-tree.ui.renderer")
local file_items = require("neo-tree.sources.common.file-items")
local log = require("neo-tree.log")
local git = require("neo-tree.git")

local M = {}

local function parse_name_status(output, worktree_root)
  local lookup = {}
  for line in output:gmatch("[^\n]+") do
    local status, rest = line:match("^(%S+)\t(.+)$")
    if status and rest then
      -- Handle renames/copies: "R100\told\tnew" or "C100\told\tnew"
      local new_path = rest:match("\t(.+)$")
      local path = new_path or rest
      local full_path = worktree_root .. "/" .. path
      lookup[full_path] = status:sub(1, 1)
    end
  end
  return lookup
end

local function render_items(state, worktree_root, status_lookup)
  local context = file_items.create_context()
  context.state = state
  local root = file_items.create_item(context, state.path, "directory")
  root.name = vim.fn.fnamemodify(root.path, ":~")
  root.loaded = true
  root.search_pattern = state.search_pattern
  context.folders[root.path] = root

  if worktree_root then
    if status_lookup and git.worktrees[worktree_root] then
      git.worktrees[worktree_root].status_diff = git.worktrees[worktree_root].status_diff or {}
      git.worktrees[worktree_root].status_diff["main"] = status_lookup
    end
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
            item.extra = { git_status = status }
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
end

M.get_git_status = function(state)
  if state.loading then
    return
  end
  state.loading = true

  local worktree_root = git.find_worktree_info(state.path or vim.fn.getcwd())
  state.path = worktree_root or state.path or vim.fn.getcwd()

  if not worktree_root then
    render_items(state, nil, nil)
    state.loading = false
    return
  end

  vim.system(
    { "git", "-C", worktree_root, "diff", "--name-status", "main" },
    { text = true },
    vim.schedule_wrap(function(result)
      local status_lookup = nil
      if result.code == 0 and result.stdout then
        status_lookup = parse_name_status(result.stdout, worktree_root)
      end
      render_items(state, worktree_root, status_lookup)
      state.loading = false
    end)
  )
end

return M
