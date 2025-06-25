-- Example configuration for packer.nvim
-- Add this to your packer configuration

use {
  "integrate-your-mind/claude.vim",
  
  -- Optional: specify a tag for stability
  -- tag = "v1.0.0",
  
  -- Configuration function
  config = function()
    require("claude-code").setup({
      -- Claude executable path
      claude_executable = "claude",
      
      -- Default interaction mode
      default_mode = "terminal", -- or "floating"
      
      -- Terminal settings
      terminal = {
        position = "right",     -- Position of terminal split
        size = 80,             -- Size of terminal window
        close_on_exit = false, -- Keep terminal open when Claude exits
      },
      
      -- Floating window settings
      floating = {
        width = 0.8,           -- 80% of screen width
        height = 0.8,          -- 80% of screen height
        border = "rounded",    -- Border style
        animation = {
          enabled = true,      -- Enable animations
          duration = 200,      -- Animation duration in ms
        },
        help_commands = true,  -- Show help in floating windows
      },
      
      -- Auto-refresh status
      auto_status = true,
      status_refresh_interval = 5000,
    })
    
    -- Set up keybindings after plugin loads
    local opts = { noremap = true, silent = true }
    vim.keymap.set('n', '<leader>cc', '<cmd>ClaudeChat<cr>', opts)
    vim.keymap.set('n', '<leader>ct', '<cmd>ClaudeToggle<cr>', opts) 
    vim.keymap.set('n', '<leader>cf', '<cmd>ClaudeFloating<cr>', opts)
    vim.keymap.set('n', '<leader>cs', '<cmd>ClaudeStatus<cr>', opts)
    vim.keymap.set('v', '<leader>ce', '<cmd>ClaudeExplain<cr>', opts)
    vim.keymap.set('n', '<leader>cr', '<cmd>ClaudeReview<cr>', opts)
  end,
  
  -- Optional: only load when needed
  cmd = {
    "ClaudeChat",
    "ClaudeFloating",
    "ClaudeToggle", 
    "ClaudeStatus",
    "ClaudeExplain",
    "ClaudeReview",
  },
}