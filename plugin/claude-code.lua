if vim.g.loaded_claude_code then
  return
end
vim.g.loaded_claude_code = 1

local claude = require('claude-code')

vim.api.nvim_create_user_command('ClaudeChat', function(opts)
  claude.chat(opts.args)
end, {
  nargs = '?',
  desc = 'Chat with Claude (uses default mode)',
})

vim.api.nvim_create_user_command('ClaudeChatTerminal', function(opts)
  claude.chat_terminal(opts.args)
end, {
  nargs = '?',
  desc = 'Chat with Claude in terminal mode',
})

vim.api.nvim_create_user_command('ClaudeChatFloating', function(opts)
  claude.chat_floating(opts.args)
end, {
  nargs = '?',
  desc = 'Chat with Claude in floating window mode',
})

vim.api.nvim_create_user_command('ClaudeToggle', function()
  claude.toggle_terminal()
end, {
  desc = 'Toggle Claude terminal visibility',
})

vim.api.nvim_create_user_command('ClaudeToggleFloating', function()
  claude.toggle_floating()
end, {
  desc = 'Toggle Claude floating window visibility',
})

vim.api.nvim_create_user_command('ClaudeMode', function(opts)
  if opts.args and opts.args ~= "" then
    claude.set_mode(opts.args)
  else
    vim.notify("Current mode: " .. require('claude-code').get_mode(), vim.log.levels.INFO)
  end
end, {
  nargs = '?',
  complete = function() return {'terminal', 'floating'} end,
  desc = 'Set or show Claude interaction mode',
})

vim.api.nvim_create_user_command('ClaudeStatus', function()
  claude.status()
end, {
  desc = 'Show Claude Code status',
})

vim.api.nvim_create_user_command('ClaudeExplain', function()
  claude.explain_selection()
end, {
  desc = 'Explain selected code with Claude in terminal',
})

vim.api.nvim_create_user_command('ClaudeReview', function()
  claude.review_file()
end, {
  desc = 'Review current file with Claude in terminal',
})

vim.api.nvim_create_user_command('ClaudeRefresh', function()
  claude.refresh_status()
end, {
  desc = 'Refresh Claude status',
})

-- File tracking commands
vim.api.nvim_create_user_command('ClaudeFileStatus', function()
  claude.show_file_tracking_status()
end, {
  desc = 'Show file tracking status',
})

vim.api.nvim_create_user_command('ClaudeFileToggle', function()
  claude.toggle_file_tracking()
end, {
  desc = 'Toggle file tracking',
})

vim.api.nvim_create_user_command('ClaudeFileOpen', function(opts)
  claude.open_file_in_main(opts.args ~= "" and opts.args or nil)
end, {
  nargs = '?',
  complete = 'file',
  desc = 'Open file in main window',
})

vim.api.nvim_create_user_command('ClaudeFileStop', function()
  claude.stop_all_file_watchers()
end, {
  desc = 'Stop all file watchers',
})

local function setup_keymaps()
  vim.keymap.set('n', '<leader>cc', function() claude.chat() end, { desc = 'Claude Chat (default mode)' })
  vim.keymap.set('n', '<leader>ct', function() claude.chat_terminal() end, { desc = 'Claude Chat Terminal' })
  vim.keymap.set('n', '<leader>cf', function() claude.chat_floating() end, { desc = 'Claude Chat Floating' })
  vim.keymap.set('n', '<leader>cT', function() claude.toggle_terminal() end, { desc = 'Toggle Claude Terminal' })
  vim.keymap.set('n', '<leader>cF', function() claude.toggle_floating() end, { desc = 'Toggle Claude Floating' })
  vim.keymap.set('n', '<leader>cs', function() claude.status() end, { desc = 'Claude Status' })
  vim.keymap.set('v', '<leader>ce', function() claude.explain_selection() end, { desc = 'Claude Explain' })
  vim.keymap.set('n', '<leader>cr', function() claude.review_file() end, { desc = 'Claude Review' })
  vim.keymap.set('n', '<leader>cR', function() claude.refresh_status() end, { desc = 'Claude Refresh' })
  vim.keymap.set('n', '<leader>cm', function() 
    local mode = claude.get_mode() == "terminal" and "floating" or "terminal"
    claude.set_mode(mode)
  end, { desc = 'Toggle Claude Mode' })
  
  -- File tracking keybindings
  vim.keymap.set('n', '<leader>cfs', function() claude.show_file_tracking_status() end, { desc = 'File Tracking Status' })
  vim.keymap.set('n', '<leader>cft', function() claude.toggle_file_tracking() end, { desc = 'Toggle File Tracking' })
  vim.keymap.set('n', '<leader>cfo', function() claude.open_file_in_main() end, { desc = 'Open File in Main' })
  vim.keymap.set('n', '<leader>cfx', function() claude.stop_all_file_watchers() end, { desc = 'Stop File Watchers' })
end

setup_keymaps()

claude.setup()