return {
  {
    name = "claude-code",
    dir = vim.fn.stdpath("config"),
    lazy = false,
    config = function()
      require('claude-code').setup({
        claude_executable = "claude",
        auto_status = false, -- Disabled to prevent loops
        status_refresh_interval = 5000,
        default_mode = "terminal", -- "terminal" or "floating"
        terminal = {
          position = "right",
          size = 80,
          close_on_exit = false,
          modes = {
            chat = true,
            edit = true,
          },
        },
        floating = {
          width = 0.8,
          height = 0.8,
          border = "rounded",
          animation = {
            enabled = true,
            duration = 200,
          },
          help_commands = true,
        },
      })
    end,
    keys = {
      { "<leader>cc", function() require('claude-code').chat() end, desc = "Claude Chat (default mode)" },
      { "<leader>ct", function() require('claude-code').chat_terminal() end, desc = "Claude Chat Terminal" },
      { "<leader>cf", function() require('claude-code').chat_floating() end, desc = "Claude Chat Floating" },
      { "<leader>cT", function() require('claude-code').toggle_terminal() end, desc = "Toggle Claude Terminal" },
      { "<leader>cF", function() require('claude-code').toggle_floating() end, desc = "Toggle Claude Floating" },
      { "<leader>cs", function() require('claude-code').status() end, desc = "Claude Status" },
      { "<leader>ce", function() require('claude-code').explain_selection() end, mode = "v", desc = "Claude Explain" },
      { "<leader>cr", function() require('claude-code').review_file() end, desc = "Claude Review" },
      { "<leader>cR", function() require('claude-code').refresh_status() end, desc = "Claude Refresh" },
      { "<leader>cm", function() 
        local claude = require('claude-code')
        local mode = claude.get_mode() == "terminal" and "floating" or "terminal"
        claude.set_mode(mode)
      end, desc = "Toggle Claude Mode" },
    },
    cmd = {
      "ClaudeChat",
      "ClaudeChatTerminal",
      "ClaudeChatFloating",
      "ClaudeToggle",
      "ClaudeToggleFloating", 
      "ClaudeMode",
      "ClaudeStatus", 
      "ClaudeExplain",
      "ClaudeReview",
      "ClaudeRefresh",
    },
  },
}