local M = {}

local defaults = {
  key = "<leader>?",
  favorites_key = "<leader>H",
  desc = "Cheat Sheet",
  favorites_desc = "Cheat Sheet (favorites)",
}

M._config = vim and vim.deepcopy and vim.deepcopy(defaults) or {
  key = defaults.key,
  favorites_key = defaults.favorites_key,
  desc = defaults.desc,
  favorites_desc = defaults.favorites_desc,
}

--- Show the cheat sheet using Telescope if available, else a tiny fallback.
function M.show()
  local ok, tb = pcall(require, 'telescope.builtin')
  if ok and type(tb.keymaps) == 'function' then
    tb.keymaps()
    return
  end

  -- Fallback: minimal floating window with a hint
  if not vim or not vim.api then
    if vim and vim.notify then vim.notify("Cheat Sheet: Telescope not found", vim.log.levels.INFO)
    else print("Cheat Sheet: Telescope not found") end
    return
  end

  local buf = vim.api.nvim_create_buf(false, true)
  local lines = {
    "Cheat Sheet",
    "",
    "Telescope not found.",
    "Install nvim-telescope/telescope.nvim or run :Telescope keymaps",
  }
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')

  local width = math.min(80, math.max(40, math.floor((vim.o.columns or 80) * 0.6)))
  local height = #lines + 2
  local row = math.max(0, math.floor(((vim.o.lines or 24) - height) / 2))
  local col = math.max(0, math.floor(((vim.o.columns or 80) - width) / 2))

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
  })

  vim.keymap.set('n', 'q', function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end, { buffer = buf, nowait = true, silent = true, desc = 'Close' })
end

local favorites_groups = {
  { title = "Files", items = {
    {"<leader>ff", "Find Files"},
    {"<leader>fr", "Recent Files"},
    {"<leader>fe", "Explorer (Neo-tree)"},
  }},
  { title = "Search", items = {
    {"<leader>/", "Live Grep"},
    {"<leader>sg", "Grep (root)"},
    {"<leader>sb", "Search Buffer"},
  }},
  { title = "Git", items = {
    {"<leader>gs", "Status"},
    {"<leader>gc", "Commits"},
    {"]h/[h", "Next/Prev Hunk"},
  }},
  { title = "Code (LSP)", items = {
    {"gd/gr/gI/gy", "Defs/Refs/Impl/Type"},
    {"K", "Hover"},
    {"<leader>ca", "Code Action"},
    {"<leader>cr", "Rename"},
  }},
  { title = "Claude", items = {
    {"<leader>cc", "Chat"},
    {"<leader>ct", "Chat Terminal"},
    {"<leader>cf", "Chat Floating"},
    {"<leader>cs", "Status"},
  }},
}

local function render_favorites_lines()
  local lines = {"Cheat Sheet (favorites)", ""}
  for _, group in ipairs(favorites_groups) do
    table.insert(lines, group.title)
    for _, it in ipairs(group.items) do
      table.insert(lines, string.format("  %-16s %s", it[1], it[2]))
    end
    table.insert(lines, "")
  end
  table.insert(lines, "Press q to close")
  return lines
end

function M.favorites()
  if not vim or not vim.api then
    if vim and vim.notify then vim.notify("Favorites view requires Neovim", vim.log.levels.WARN)
    else print("Favorites view requires Neovim") end
    return
  end

  local buf = vim.api.nvim_create_buf(false, true)
  local lines = render_favorites_lines()
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')

  local width = math.min(80, math.max(40, math.floor((vim.o.columns or 80) * 0.6)))
  local height = #lines + 2
  local row = math.max(0, math.floor(((vim.o.lines or 24) - height) / 2))
  local col = math.max(0, math.floor(((vim.o.columns or 80) - width) / 2))

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
  })

  vim.keymap.set('n', 'q', function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end, { buffer = buf, nowait = true, silent = true, desc = 'Close' })
end

--- Setup the plugin and keymap.
---@param opts { key?: string, favorites_key?: string, desc?: string, favorites_desc?: string }|nil
function M.setup(opts)
  opts = opts or {}
  if vim and vim.tbl_deep_extend then
    M._config = vim.tbl_deep_extend('force', defaults, opts)
  else
    M._config.key = opts.key or defaults.key
    M._config.favorites_key = opts.favorites_key or defaults.favorites_key
    M._config.desc = opts.desc or defaults.desc
    M._config.favorites_desc = opts.favorites_desc or defaults.favorites_desc
  end

  if vim and vim.keymap and vim.keymap.set then
    vim.keymap.set('n', M._config.key, M.show, { desc = M._config.desc, silent = true })
    vim.keymap.set('n', M._config.favorites_key, M.favorites, { desc = M._config.favorites_desc, silent = true })
  end

  -- user commands
  if vim and vim.api and vim.api.nvim_create_user_command then
    vim.api.nvim_create_user_command('CheatSheet', function() M.show() end, { desc = 'Open cheat sheet (Telescope)' })
    vim.api.nvim_create_user_command('CheatSheetFavorites', function() M.favorites() end, { desc = 'Open favorites cheat sheet' })
  end
end

return M

