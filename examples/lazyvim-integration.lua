-- LazyVim Integration Example
-- Place this file at ~/.config/nvim/lua/plugins/claude-code.lua for LazyVim

return {
  "integrate-your-mind/claude.vim",
  
  -- Lazy loading for better startup performance
  cmd = {
    "ClaudeChat",
    "ClaudeFloating", 
    "ClaudeToggle",
    "ClaudeStatus",
    "ClaudeExplain",
    "ClaudeReview",
    "ClaudeMode",
  },
  
  -- Key mappings that trigger lazy loading
  keys = {
    { 
      "<leader>ac", 
      "<cmd>ClaudeChat<cr>", 
      desc = "Claude Chat",
      mode = "n" 
    },
    { 
      "<leader>at", 
      "<cmd>ClaudeToggle<cr>", 
      desc = "Toggle Claude Terminal",
      mode = "n" 
    },
    { 
      "<leader>af", 
      "<cmd>ClaudeFloating<cr>", 
      desc = "Claude Floating Window",
      mode = "n" 
    },
    { 
      "<leader>as", 
      "<cmd>ClaudeStatus<cr>", 
      desc = "Claude Status",
      mode = "n" 
    },
    { 
      "<leader>ae", 
      "<cmd>ClaudeExplain<cr>", 
      desc = "Explain Selection",
      mode = "v" 
    },
    { 
      "<leader>ar", 
      "<cmd>ClaudeReview<cr>", 
      desc = "Review File",
      mode = "n" 
    },
  },
  
  -- Plugin configuration optimized for LazyVim
  config = function()
    require("claude-code").setup({
      claude_executable = "claude",
      default_mode = "terminal",
      
      terminal = {
        position = "right",
        size = 80,
        close_on_exit = false,
      },
      
      floating = {
        width = 0.85,
        height = 0.85,
        border = "rounded",
        animation = {
          enabled = true,
          duration = 250,
        },
        help_commands = true,
      },
      
      auto_status = false, -- Disable to avoid conflicts with LazyVim status
    })
    
    -- Integration with LazyVim's which-key (if available)
    if pcall(require, "which-key") then
      require("which-key").register({
        ["<leader>a"] = { name = "+ai (Claude)" },
      })
    end
    
    -- Optional: Add Claude status to LazyVim's status line
    -- This requires modification to your status line configuration
    if pcall(require, "lualine") then
      -- Example lualine integration
      local function claude_status()
        local status = require("claude-code").get_status_line()
        return status and status ~= "" and "󰧑 " .. status or ""
      end
      
      -- You can add this to your lualine sections configuration:
      -- sections = {
      --   lualine_x = { claude_status, "encoding", "fileformat", "filetype" },
      -- }
    end
  end,
  
  -- Ensure proper initialization order
  priority = 50,
}