-- agent_live.nvim — watch a repo for external (AI-agent) edits, live.
-- Two modes:
--   :AgentLive start [root]  — 2x2 dashboard tab: 4 most-recently-edited files,
--                              changed lines flash green (UI-only extmarks).
--   :AgentLive log   [root]  — calm append-only feed: one line per file write.
--   :AgentLive stop
--
-- v2 fixes: ALL git calls are ASYNC (vim.system) with a re-entrancy guard, so a
-- slow/locked git (agent committing) can never freeze the UI; dashboard buffers
-- load with swapfile off + shortmess+=A, so the E325 ATTENTION dialog can never
-- block a timer; the watcher never clobbers a buffer with unsaved user edits.
local M = {}
local uv = vim.uv or vim.loop
local ns = vim.api.nvim_create_namespace("agent_live_flash")

local state = {
  timer = nil, root = nil, mode = nil, polling = false,
  tab = nil, slots = {}, snap = {},
  log_buf = nil, log_mtime = {},
}

vim.api.nvim_set_hl(0, "AgentLiveFlash", { bg = "#374d2b", default = true })
-- persistent diff-vs-HEAD marks (gitsigns-lite for the --clean viewers):
vim.api.nvim_set_hl(0, "AgentLiveAdd", { bg = "#16301f", default = true })
vim.api.nvim_set_hl(0, "AgentLiveChange", { bg = "#172a40", default = true })
vim.api.nvim_set_hl(0, "AgentLiveAddSign", { fg = "#4ade80", default = true })
vim.api.nvim_set_hl(0, "AgentLiveChangeSign", { fg = "#60a5fa", default = true })
vim.api.nvim_set_hl(0, "AgentLiveDeleteSign", { fg = "#fb7185", default = true })
local ns_diff = vim.api.nvim_create_namespace("agent_live_diff")

local function notify(msg, level)
  pcall(vim.notify, msg, level or vim.log.levels.INFO, { title = "agent-live" })
end

-- ---------- async git ----------
-- One in-flight poll at a time; results land via vim.schedule. Never blocks UI.
local function git_async(args, on_lines)
  local ok = pcall(vim.system, vim.list_extend({ "git", "-C", state.root }, args),
    { text = true, timeout = 4000 },
    vim.schedule_wrap(function(out)
      if out.code ~= 0 or not out.stdout then on_lines(nil) return end
      on_lines(vim.split(out.stdout, "\n", { trimempty = true }))
    end))
  if not ok then on_lines(nil) end
end

local function parse_porcelain(lines)
  local files = {}
  for _, line in ipairs(lines or {}) do
    local rest = line:sub(4)
    if rest:find(" -> ") then rest = rest:gsub(".* %-> ", "") end
    rest = rest:gsub('^"', ""):gsub('"$', "")
    if rest ~= "" and not rest:match("/$") then
      files[#files + 1] = state.root .. "/" .. rest
    end
  end
  return files
end

-- ---------- buffers ----------
local function buf_of(path)
  local b = vim.fn.bufnr(path)
  if b == -1 then b = vim.fn.bufadd(path) end
  if not vim.api.nvim_buf_is_loaded(b) then
    -- no swapfile (never raise ATTENTION) and load with ALL events suppressed:
    -- otherwise every load fires the full LSP/treesitter attach storm, which is
    -- what wedged the viewer on churn-heavy agent worktrees.
    pcall(function() vim.bo[b].swapfile = false end)
    local saved = vim.o.eventignore
    vim.o.eventignore = "all"
    pcall(vim.fn.bufload, b)
    vim.o.eventignore = saved
    pcall(function() vim.bo[b].swapfile = false end)
    -- eventignore suppressed filetype detection; set it explicitly so syntax
    -- highlighting works (regex syntax only — LSP/treesitter never attach in
    -- the --clean viewers, which is the whole point).
    pcall(function()
      if vim.bo[b].filetype == "" then
        local ft = vim.filetype.match({ buf = b, filename = path })
        if ft then vim.bo[b].filetype = ft end
      end
    end)
  end
  return b
end

local function lines_of(buf)
  if not vim.api.nvim_buf_is_loaded(buf) then return {} end
  return vim.api.nvim_buf_get_lines(buf, 0, -1, false)
end

local function flash(buf, old)
  local new = lines_of(buf)
  local a, b = table.concat(old, "\n"), table.concat(new, "\n")
  if a == b then return end
  local ok, hunks = pcall(vim.diff, a, b, { result_type = "indices" })
  if not ok or type(hunks) ~= "table" then return end
  for _, h in ipairs(hunks) do
    local s, c = h[3], math.max(h[4], 1)
    for l = math.max(s, 1), s + c - 1 do
      pcall(vim.api.nvim_buf_set_extmark, buf, ns, l - 1, 0,
        { line_hl_group = "AgentLiveFlash" })
    end
  end
  vim.defer_fn(function() pcall(vim.api.nvim_buf_clear_namespace, buf, ns, 0, -1) end, 2600)
end

-- ---------- persistent HEAD-diff marks ----------
-- WHAT the agent changed, visible until it commits: async `git show HEAD:file`
-- diffed against the buffer; added lines tint green, modified blue, deletions a
-- red underbar in the gutter. Re-marked on every reload; never fades.
local function mark_head_diff(buf, path)
  if state.diffing and state.diffing[buf] then return end
  state.diffing = state.diffing or {}
  state.diffing[buf] = true
  local rel = path:gsub("^" .. vim.pesc(state.root) .. "/", "")
  git_async({ "show", "HEAD:" .. rel }, function(head_lines)
    state.diffing[buf] = false
    if not vim.api.nvim_buf_is_valid(buf) then return end
    local cur = lines_of(buf)
    pcall(vim.api.nvim_buf_clear_namespace, buf, ns_diff, 0, -1)
    local mark = function(l, line_hl, sign, sign_hl)
      pcall(vim.api.nvim_buf_set_extmark, buf, ns_diff, math.max(l - 1, 0), 0, {
        line_hl_group = line_hl, sign_text = sign, sign_hl_group = sign_hl,
        priority = 8,
      })
    end
    if head_lines == nil then -- untracked/new file: everything is an addition
      for l = 1, #cur do mark(l, "AgentLiveAdd", "▎", "AgentLiveAddSign") end
      return
    end
    local ok, hunks = pcall(vim.diff, table.concat(head_lines, "\n") .. "\n",
      table.concat(cur, "\n") .. "\n", { result_type = "indices" })
    if not ok or type(hunks) ~= "table" then return end
    for _, h in ipairs(hunks) do
      local ca, sb, cb = h[2], h[3], h[4]
      if cb == 0 then -- pure deletion: red underbar at the join line
        mark(math.max(sb, 1), nil, "▁", "AgentLiveDeleteSign")
      else
        local hl = (ca == 0) and "AgentLiveAdd" or "AgentLiveChange"
        local sign_hl = (ca == 0) and "AgentLiveAddSign" or "AgentLiveChangeSign"
        for l = sb, sb + cb - 1 do mark(l, hl, "▎", sign_hl) end
      end
    end
  end)
end

-- ---------- dashboard mode ----------
-- Slot 1 is ALWAYS the status pane (what's being watched, agent state, recent
-- writes) so a clean worktree shows "agent idle — all committed", never an
-- unexplained empty pane. Slots 2-4 hold the most recently edited files.
local function set_status(lines)
  local buf = state.status_buf
  if not (buf and vim.api.nvim_buf_is_valid(buf)) then return end
  pcall(function()
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
  end)
end

local function ensure_dashboard()
  if state.tab and vim.api.nvim_tabpage_is_valid(state.tab) then
    if #vim.api.nvim_tabpage_list_wins(state.tab) >= 4 then return end
  end
  vim.cmd("tabnew")
  vim.cmd("setlocal nobuflisted")
  vim.cmd("belowright split | wincmd t | belowright vsplit | wincmd b | belowright vsplit | wincmd =")
  state.tab = vim.api.nvim_get_current_tabpage()
  local wins = vim.api.nvim_tabpage_list_wins(state.tab)
  -- status pane in slot 1
  local sbuf = vim.api.nvim_create_buf(false, true)
  state.status_buf = sbuf
  pcall(vim.api.nvim_buf_set_name, sbuf, "AGENT-STATUS")
  vim.bo[sbuf].buftype, vim.bo[sbuf].bufhidden, vim.bo[sbuf].swapfile = "nofile", "hide", false
  pcall(vim.api.nvim_win_set_buf, wins[1], sbuf)
  set_status({ "agent-live · " .. (state.root or "?"), "waiting for first poll…" })
  -- file slots 2-4
  state.slots = {}
  for i = 2, math.min(4, #wins) do
    state.slots[#state.slots + 1] = { win = wins[i], path = nil, order = 0 }
  end
end

local tick_n = 0

local function slot_for(path)
  for _, s in ipairs(state.slots) do
    if s.path == path then return s end
  end
  local lru = state.slots[1]
  for _, s in ipairs(state.slots) do
    if not s.path then return s end
    if s.order < lru.order then lru = s end
  end
  return lru
end

local function show(path)
  ensure_dashboard()
  local s = slot_for(path)
  if not (s and s.win and vim.api.nvim_win_is_valid(s.win)) then return end
  local buf = buf_of(path)
  if vim.bo[buf] and vim.bo[buf].modified then return end -- user's unsaved edits win
  local old = state.snap[path] or lines_of(buf)
  pcall(vim.api.nvim_win_set_buf, s.win, buf)
  pcall(function() vim.wo[s.win].signcolumn = "yes" end)
  pcall(vim.api.nvim_buf_call, buf, function() pcall(vim.cmd, "silent! checktime") end)
  flash(buf, old)
  mark_head_diff(buf, path) -- persistent: WHAT changed vs last commit
  state.snap[path] = lines_of(buf)
  tick_n = tick_n + 1
  s.path, s.order = path, tick_n
end

local function dash_tick()
  if state.polling then return end
  state.polling = true
  git_async({ "-c", "core.quotepath=false", "status", "--porcelain" }, function(lines)
    if state.mode ~= "dash" then state.polling = false return end
    local files = parse_porcelain(lines)
    local shown = 0
    for _, path in ipairs(files) do
      local st = uv.fs_stat(path)
      if st and st.size < 300 * 1024 then -- skip generated megafiles
        local m = st.mtime.sec * 1e9 + (st.mtime.nsec or 0)
        -- only act when the file ACTUALLY changed since last tick; reloading
        -- every dirty file every tick is what churned the UI to death.
        if (state.log_mtime[path] or 0) < m then
          state.log_mtime[path] = m
          pcall(show, path)
          shown = shown + 1
          if shown >= 3 then break end -- one dashboard's worth per tick, max
        end
      end
    end
    -- status pane: always explain what you're (not) seeing
    git_async({ "log", "-1", "--format=%h %s (%cr)" }, function(loglines)
      state.polling = false
      local head = (loglines or {})[1] or "?"
      local status
      if #files == 0 then
        status = { "agent-live · " .. state.root,
          "state:  ✓ WORKTREE CLEAN — agent idle or finished (all work committed)",
          "head:   " .. head,
          "",
          "panes will light up when the agent writes its next file." }
      else
        status = { "agent-live · " .. state.root,
          ("state:  ✎ AGENT WORKING — %d uncommitted file(s)"):format(#files),
          "head:   " .. head, "" }
        for i = 1, math.min(#files, 10) do
          status[#status + 1] = "  · " .. files[i]:gsub("^" .. vim.pesc(state.root) .. "/", "")
        end
      end
      status[#status + 1] = ""
      status[#status + 1] = "updated " .. os.date("%H:%M:%S")
      set_status(status)
    end)
  end)
end

-- ---------- log mode ----------
local function log_append(line)
  local buf = state.log_buf
  if not (buf and vim.api.nvim_buf_is_valid(buf)) then return end
  pcall(function()
    vim.bo[buf].modifiable = true
    local n = vim.api.nvim_buf_line_count(buf)
    vim.api.nvim_buf_set_lines(buf, n, n, false, { line })
    vim.bo[buf].modifiable = false
    for _, w in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(w) == buf then
        vim.api.nvim_win_set_cursor(w, { vim.api.nvim_buf_line_count(buf), 0 })
      end
    end
  end)
end

local function log_tick()
  if state.polling then return end
  state.polling = true
  git_async({ "-c", "core.quotepath=false", "status", "--porcelain" }, function(slines)
    if state.mode ~= "log" then state.polling = false return end
    local touched = {}
    for _, path in ipairs(parse_porcelain(slines)) do
      local st = uv.fs_stat(path)
      if st then
        local m = st.mtime.sec * 1e9 + (st.mtime.nsec or 0)
        if (state.log_mtime[path] or 0) < m then
          state.log_mtime[path] = m
          touched[path:gsub("^" .. vim.pesc(state.root) .. "/", "")] = true
        end
      end
    end
    if not next(touched) then state.polling = false return end
    -- one async numstat for ALL files (never per-file sync calls)
    git_async({ "diff", "--numstat" }, function(nlines)
      state.polling = false
      local stat = {}
      for _, l in ipairs(nlines or {}) do
        local a, d, f = l:match("^(%S+)%s+(%S+)%s+(.+)$")
        if f then stat[f] = { a = a, d = d } end
      end
      for rel in pairs(touched) do
        local s = stat[rel] or { a = "new", d = "0" }
        log_append(("%s  %-40s  +%s / -%s"):format(os.date("%H:%M:%S"), rel, s.a, s.d))
      end
    end)
  end)
end

-- ---------- lifecycle ----------
local function start_timer(interval, fn)
  state.timer = uv.new_timer()
  state.timer:start(0, interval, vim.schedule_wrap(function() pcall(fn) end))
end

function M.stop()
  if state.timer then
    pcall(function() state.timer:stop(); state.timer:close() end)
    state.timer = nil
    notify("stopped")
  end
  state.mode, state.polling = nil, false
end

function M.start(root)
  M.stop()
  state.root = root or vim.fn.getcwd()
  state.mode = "dash"
  state.snap, state.slots, state.tab, state.log_mtime = {}, {}, nil, {}
  vim.opt.autoread = true
  vim.opt.shortmess:append("A") -- never block on swap ATTENTION
  ensure_dashboard()
  start_timer(1500, dash_tick)
  notify("watching " .. state.root)
end

function M.log_start(root)
  M.stop()
  state.root = root or vim.fn.getcwd()
  state.mode = "log"
  state.log_mtime = {}
  vim.cmd("tabnew")
  local buf = vim.api.nvim_get_current_buf()
  state.log_buf = buf
  vim.bo[buf].buftype, vim.bo[buf].bufhidden, vim.bo[buf].swapfile = "nofile", "hide", false
  pcall(vim.api.nvim_buf_set_name, buf, "AGENT-LIVE-LOG")
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
    "agent-live activity log  ·  " .. state.root,
    "each line = a file an agent just wrote (+adds / -dels vs last commit).",
    string.rep("─", 70), "",
  })
  vim.bo[buf].modifiable = false
  start_timer(1500, log_tick)
  notify("calm log mode on — scroll at your pace")
end

vim.api.nvim_create_user_command("AgentLive", function(opts)
  local sub = opts.fargs[1]
  if sub == "stop" then M.stop()
  elseif sub == "log" then M.log_start(opts.fargs[2])
  else M.start(opts.fargs[2]) end
end, { nargs = "*", complete = function() return { "log", "start", "stop" } end })

return M
