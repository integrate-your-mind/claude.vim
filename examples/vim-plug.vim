" Example configuration for vim-plug
" Add this to your vim-plug configuration in init.vim or init.lua

" In your vim-plug block:
Plug 'integrate-your-mind/claude.vim'

" After plug#end(), add configuration:
lua << EOF
require("claude-code").setup({
  -- Claude executable (ensure it's in your PATH or specify full path)
  claude_executable = "claude",
  
  -- Default mode for Claude interactions
  default_mode = "terminal", -- "terminal" or "floating"
  
  -- Terminal configuration
  terminal = {
    position = "right",      -- "right", "left", "bottom", "top"
    size = 80,              -- Window size (width for vertical, height for horizontal)
    close_on_exit = false,  -- Keep terminal open when Claude process exits
    modes = {
      chat = true,          -- Enable chat mode
      edit = true,          -- Enable edit mode
    },
  },
  
  -- Floating window configuration
  floating = {
    width = 0.8,            -- Percentage of screen width (0.1 to 1.0)
    height = 0.8,           -- Percentage of screen height (0.1 to 1.0)
    border = "rounded",     -- Border style: "single", "double", "rounded", "solid", "shadow"
    animation = {
      enabled = true,       -- Enable window animations
      duration = 200,       -- Animation duration in milliseconds
    },
    help_commands = true,   -- Show help commands in floating windows
  },
  
  -- Status line integration
  auto_status = true,             -- Automatically refresh Claude status
  status_refresh_interval = 5000, -- Refresh interval in milliseconds
})

-- Key mappings
local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<leader>cc', '<cmd>ClaudeChat<cr>', opts)
vim.keymap.set('n', '<leader>ct', '<cmd>ClaudeToggle<cr>', opts)
vim.keymap.set('n', '<leader>cf', '<cmd>ClaudeFloating<cr>', opts)
vim.keymap.set('n', '<leader>cs', '<cmd>ClaudeStatus<cr>', opts)
vim.keymap.set('v', '<leader>ce', '<cmd>ClaudeExplain<cr>', opts)
vim.keymap.set('n', '<leader>cr', '<cmd>ClaudeReview<cr>', opts)
vim.keymap.set('n', '<leader>cm', '<cmd>ClaudeMode terminal<cr>', opts)
EOF

" Alternative: Vimscript key mappings (if you prefer)
" nnoremap <leader>cc :ClaudeChat<CR>
" nnoremap <leader>ct :ClaudeToggle<CR>
" nnoremap <leader>cf :ClaudeFloating<CR>
" nnoremap <leader>cs :ClaudeStatus<CR>
" vnoremap <leader>ce :ClaudeExplain<CR>
" nnoremap <leader>cr :ClaudeReview<CR>