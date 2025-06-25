local M = {}

local health = vim.health or require("health")

function M.check()
  health.start("claude.vim Health Check")
  
  -- Check Neovim version
  local nvim_version = vim.version()
  if nvim_version.major == 0 and nvim_version.minor >= 8 then
    health.ok("Neovim version: " .. tostring(nvim_version))
  else
    health.error("Neovim 0.8+ required. Current version: " .. tostring(nvim_version))
  end
  
  -- Check for Claude CLI
  local claude_executable = "claude"
  local config_ok, config = pcall(require, "claude-code")
  if config_ok and config._config and config._config.claude_executable then
    claude_executable = config._config.claude_executable
  end
  
  -- Test Claude CLI availability
  local claude_available = vim.fn.executable(claude_executable) == 1
  if claude_available then
    health.ok("Claude CLI found: " .. claude_executable)
    
    -- Test Claude CLI functionality
    local result = vim.fn.system(claude_executable .. " --version 2>/dev/null")
    local exit_code = vim.v.shell_error
    
    if exit_code == 0 then
      health.ok("Claude CLI is functional")
    else
      health.warn("Claude CLI found but may not be properly configured")
      health.info("Try running: " .. claude_executable .. " --help")
    end
  else
    health.error("Claude CLI not found: " .. claude_executable)
    health.info("Install Claude CLI from: https://claude.ai/code")
    health.info("Ensure it's in your PATH or configure claude_executable in setup()")
  end
  
  -- Check terminal support
  local terminal_support = false
  
  -- Check if termopen function exists (modern Neovim)
  if vim.fn.exists("*termopen") == 1 then
    -- Test if termopen actually works
    local termopen_ok = pcall(function()
      vim.fn.termopen("echo test")  -- This creates the test but won't run in headless
    end)
    
    if termopen_ok then
      terminal_support = true
      health.ok("Terminal support available (termopen functional)")
    else
      health.warn("termopen exists but may not be functional")
    end
  -- Fallback check for older versions
  elseif vim.fn.has("terminal") == 1 then
    terminal_support = true
    health.ok("Terminal support available (legacy)")
  else
    health.error("Terminal support not available")
    health.info("termopen function not found - update Neovim")
  end
  
  -- Check plugin configuration
  if config_ok then
    health.ok("Plugin loaded successfully")
    
    -- Check configuration validity
    local conf = config._config or {}
    
    -- Validate terminal position
    local valid_positions = { "right", "left", "top", "bottom" }
    local terminal_position = conf.terminal and conf.terminal.position or "right"
    if vim.tbl_contains(valid_positions, terminal_position) then
      health.ok("Terminal position valid: " .. terminal_position)
    else
      health.warn("Invalid terminal position: " .. terminal_position)
    end
    
    -- Validate floating window configuration
    if conf.floating then
      local width = conf.floating.width or 0.8
      local height = conf.floating.height or 0.8
      
      if width > 0 and width <= 1 then
        health.ok("Floating window width valid: " .. width)
      else
        health.warn("Floating window width should be between 0 and 1: " .. width)
      end
      
      if height > 0 and height <= 1 then
        health.ok("Floating window height valid: " .. height)
      else
        health.warn("Floating window height should be between 0 and 1: " .. height)
      end
    end
  else
    health.error("Plugin not loaded properly")
  end
  
  -- Check for potential conflicts
  local conflicting_plugins = {
    "ChatGPT.nvim",
    "copilot.vim",
    "copilot.lua",
  }
  
  for _, plugin in ipairs(conflicting_plugins) do
    local plugin_loaded = pcall(require, plugin:gsub("%..*", ""))
    if plugin_loaded then
      health.info("Detected " .. plugin .. " - ensure keybindings don't conflict")
    end
  end
  
  -- Check debug log
  local debug_file = vim.fn.stdpath("config") .. "/claude_debug.log"
  if vim.fn.filereadable(debug_file) == 1 then
    local file_size = vim.fn.getfsize(debug_file)
    if file_size > 1024 * 1024 then  -- 1MB
      health.warn("Debug log is large (" .. math.floor(file_size / 1024) .. "KB)")
      health.info("Consider clearing: " .. debug_file)
    else
      health.ok("Debug log available: " .. debug_file)
    end
  end
  
  -- Environment checks
  health.start("Environment Checks")
  
  -- Check if we're in a terminal that supports colors
  if vim.env.TERM and not vim.env.TERM:match("xterm") and not vim.env.TERM:match("screen") then
    health.info("Terminal type: " .. (vim.env.TERM or "unknown"))
    health.info("Some features may not work optimally in this terminal")
  else
    health.ok("Terminal supports expected features")
  end
  
  -- Check PATH
  local path = vim.env.PATH or ""
  if path:match("/usr/local/bin") or path:match("/usr/bin") then
    health.ok("Standard binary paths in PATH")
  else
    health.warn("Standard binary paths may not be in PATH")
  end
end

return M