-- Example configuration for lazy.nvim
-- Place this in your lazy.nvim plugins table or in a separate file like ~/.config/nvim/lua/plugins/claude-code.lua

return {
  "integrate-your-mind/claude.vim",
  
  -- Lazy loading configuration
  cmd = {
    "ClaudeChat",
    "ClaudeFloating", 
    "ClaudeToggle",
    "ClaudeStatus",
    "ClaudeExplain",
    "ClaudeReview",
    "ClaudeMode",
  },
  
  -- Key mappings for lazy loading
  keys = {
    { "<leader>cc", "<cmd>ClaudeChat<cr>", desc = "Claude Chat" },
    { "<leader>ct", "<cmd>ClaudeToggle<cr>", desc = "Toggle Claude Terminal" },
    { "<leader>cf", "<cmd>ClaudeFloating<cr>", desc = "Claude Floating" },
    { "<leader>cs", "<cmd>ClaudeStatus<cr>", desc = "Claude Status" },
    { "<leader>ce", "<cmd>ClaudeExplain<cr>", mode = "v", desc = "Explain Selection" },
    { "<leader>cr", "<cmd>ClaudeReview<cr>", desc = "Review File" },
    { "<leader>cm", "<cmd>ClaudeMode<cr>", desc = "Change Claude Mode" },
  },
  
  -- Plugin configuration
  config = function()
    require("claude-code").setup({
      -- Claude executable path (optional if 'claude' is in PATH)
      claude_executable = "claude",
      
      -- Default mode: "terminal" or "floating"
      default_mode = "terminal",
      
      -- Terminal configuration
      terminal = {
        position = "right",  -- "right", "left", "bottom", "top"
        size = 80,          -- Width for vertical splits, height for horizontal
        close_on_exit = false,
      },
      
      -- Floating window configuration
      floating = {
        width = 0.8,        -- 80% of screen width
        height = 0.8,       -- 80% of screen height
        border = "rounded", -- "single", "double", "rounded", "solid", "shadow"
        animation = {
          enabled = true,
          duration = 200,   -- milliseconds
        },
        help_commands = true,
      },
      
      -- Status refresh settings
      auto_status = true,
      status_refresh_interval = 5000, -- 5 seconds
    })
  end,
}