# claude.vim

A Neovim plugin that integrates [Claude Code](https://claude.ai/code) directly into your editor, providing seamless AI assistance without leaving your development environment.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Neovim](https://img.shields.io/badge/Neovim-0.8+-green.svg)

## Features

- 🚀 **Direct Claude Code Integration** - Access Claude's AI capabilities directly from Neovim
- 🖥️ **Terminal Mode** - Interactive Claude terminal in a split window (like Cursor)
- 🪟 **Floating Window Mode** - Quick responses in beautiful floating windows
- 🎯 **Smart Window Management** - Singleton terminal behavior, focus stays in main editor
- 📁 **Automatic File Tracking** - Auto-open and monitor files Claude is working on in real-time
- ⚡ **Quick Actions** - Explain code, review files, get status with simple commands
- 🎨 **Highly Configurable** - Customize terminal position, size, animations, and more
- 🔧 **LazyVim Compatible** - Works seamlessly with LazyVim and other Neovim distributions

## Requirements

- Neovim 0.8+
- [Claude Code CLI](https://claude.ai/code) installed and configured
- Terminal emulator support (for terminal mode)

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "integrate-your-mind/claude.vim",
  config = function()
    require("claude-code").setup({
      -- Your configuration here (optional)
    })
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "integrate-your-mind/claude.vim",
  config = function()
    require("claude-code").setup()
  end
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'integrate-your-mind/claude.vim'

" In your init.vim or init.lua:
lua require("claude-code").setup()
```

## Quick Start

1. Install the plugin using your preferred plugin manager
2. Ensure Claude Code CLI is installed and authenticated
3. Use the default keybindings or commands to start using Claude

### Basic Usage

```vim
" Open Claude terminal
:ClaudeChat

" Ask a question
:ClaudeChat "Explain this code"

" Get Claude status
:ClaudeStatus

" Toggle terminal visibility
:ClaudeToggle
```

## Configuration

The plugin comes with sensible defaults but is highly configurable:

```lua
require("claude-code").setup({
  claude_executable = "claude",  -- Claude CLI command
  auto_status = true,           -- Auto-refresh status
  status_refresh_interval = 5000, -- Status refresh interval (ms)
  default_mode = "terminal",    -- "terminal" or "floating"
  
  terminal = {
    position = "right",         -- "right", "left", "bottom", "top"
    size = 80,                 -- Width for vertical, height for horizontal
    close_on_exit = false,     -- Keep terminal open when Claude exits
    modes = {
      chat = true,             -- Enable interactive chat mode
      edit = true,             -- Enable file editing assistance
    },
  },
  
  floating = {
    width = 0.8,               -- Percentage of screen width
    height = 0.8,              -- Percentage of screen height
    border = "rounded",        -- Border style
    animation = {
      enabled = true,          -- Enable animations
      duration = 200,          -- Animation duration (ms)
    },
    help_commands = true,      -- Show help in floating windows
  },
  
  file_tracking = {
    enabled = true,            -- Enable automatic file tracking
    auto_open = true,          -- Auto-open files mentioned by Claude
    auto_reload = true,        -- Auto-reload files when Claude changes them
    patterns = {               -- File patterns to watch for
      "([%w%./%-_]+%.%w+)",          -- Basic file patterns
      "editing%s+([%w%./%-_]+%.%w+)", -- Explicit edit mentions
      "creating%s+([%w%./%-_]+%.%w+)", -- File creation
      "modified%s+([%w%./%-_]+%.%w+)", -- File modifications
    },
  },
})
```

## Commands

| Command | Description |
|---------|-------------|
| `:ClaudeChat [prompt]` | Open Claude terminal or send prompt |
| `:ClaudeFloating [prompt]` | Open floating window with prompt |
| `:ClaudeToggle` | Toggle Claude terminal visibility |
| `:ClaudeStatus` | Show Claude connection status |
| `:ClaudeExplain` | Explain selected code (visual mode) |
| `:ClaudeReview` | Review current file |
| `:ClaudeMode <mode>` | Switch between "terminal" and "floating" modes |
| `:ClaudeFileStatus` | Show file tracking status and watched files |
| `:ClaudeFileToggle` | Toggle file tracking on/off |
| `:ClaudeFileOpen [path]` | Open file in main window with tracking |
| `:ClaudeFileStop` | Stop all file watchers |

## Keybindings

Default keybindings (can be customized):

| Key | Mode | Action |
|-----|------|--------|
| `<leader>cc` | Normal | Open Claude chat |
| `<leader>ct` | Normal | Toggle Claude terminal |
| `<leader>cf` | Normal | Open Claude floating window |
| `<leader>cs` | Normal | Show Claude status |
| `<leader>ce` | Visual | Explain selected code |
| `<leader>cr` | Normal | Review current file |
| `<leader>cfs` | Normal | Show file tracking status |
| `<leader>cft` | Normal | Toggle file tracking |
| `<leader>cfo` | Normal | Open file in main window |
| `<leader>cfx` | Normal | Stop all file watchers |

### Terminal Mode Keybindings

| Key | Mode | Action |
|-----|------|--------|
| `<C-q>` | Terminal | Exit terminal mode |
| `q` | Normal (in terminal) | Close terminal |

### Floating Window Keybindings

| Key | Mode | Action |
|-----|------|--------|
| `q` | Normal | Close floating window |
| `<Esc>` | Normal | Close floating window |
| `<C-t>` | Normal | Switch to terminal mode |

## Usage Examples

### Interactive Terminal Mode

```lua
-- Open Claude terminal for interactive chat
require("claude-code").chat_terminal()

-- Send a specific prompt to terminal
require("claude-code").chat_terminal("How do I optimize this function?")
```

### Floating Window Mode

```lua
-- Quick question in floating window
require("claude-code").chat_floating("Explain async/await in JavaScript")

-- Get status in floating window
require("claude-code").status()
```

### Code Analysis

```lua
-- Explain selected code (use in visual mode)
require("claude-code").explain_selection()

-- Review current file
require("claude-code").review_file()
```

### File Tracking

The plugin automatically tracks files that Claude is working on, opening them in your main editor window and monitoring for changes:

```lua
-- Check file tracking status
require("claude-code").show_file_tracking_status()

-- Toggle file tracking on/off
require("claude-code").toggle_file_tracking()

-- Manually open a file in main window with tracking
require("claude-code").open_file_in_main("/path/to/file.lua")

-- Stop all file watchers
require("claude-code").stop_all_file_watchers()

-- Get currently tracked file
local current_file = require("claude-code").get_current_tracked_file()

-- Get list of all tracked files
local tracked_files = require("claude-code").get_tracked_files()
```

**How it works:**
- When Claude mentions editing or creating a file, it's automatically opened in your main editor window
- Files are monitored for external changes and auto-reloaded if not modified in Neovim
- The terminal stays on the right while you can see the file Claude is working on in the main area
- Multiple files can be tracked simultaneously

## Advanced Configuration

### Custom Keybindings

```lua
-- Disable default keybindings and set your own
vim.keymap.set("n", "<leader>ai", function()
  require("claude-code").chat_terminal()
end, { desc = "Open Claude AI" })

vim.keymap.set("v", "<leader>ae", function()
  require("claude-code").explain_selection()
end, { desc = "Explain code with Claude" })
```

### Integration with Statusline

```lua
-- Add Claude status to your statusline
local claude_status = require("claude-code").get_status_line()
```

### LazyVim Configuration

For LazyVim users, create `~/.config/nvim/lua/plugins/claude-code.lua`:

```lua
return {
  "integrate-your-mind/claude.vim",
  cmd = {
    "ClaudeChat",
    "ClaudeFloating", 
    "ClaudeToggle",
    "ClaudeStatus",
    "ClaudeExplain",
    "ClaudeReview",
  },
  keys = {
    { "<leader>cc", "<cmd>ClaudeChat<cr>", desc = "Claude Chat" },
    { "<leader>ct", "<cmd>ClaudeToggle<cr>", desc = "Toggle Claude Terminal" },
    { "<leader>cf", "<cmd>ClaudeFloating<cr>", desc = "Claude Floating" },
    { "<leader>cs", "<cmd>ClaudeStatus<cr>", desc = "Claude Status" },
    { "<leader>ce", "<cmd>ClaudeExplain<cr>", mode = "v", desc = "Explain Selection" },
    { "<leader>cr", "<cmd>ClaudeReview<cr>", desc = "Review File" },
  },
  config = function()
    require("claude-code").setup({
      terminal = {
        position = "right",
        size = 80,
      },
      floating = {
        border = "rounded",
        animation = { enabled = true },
      },
    })
  end,
}
```

## Troubleshooting

### Claude CLI Not Found

If you get "claude command not found":

1. Install Claude Code CLI from [https://claude.ai/code](https://claude.ai/code)
2. Ensure it's in your PATH
3. Configure the executable path in plugin settings:

```lua
require("claude-code").setup({
  claude_executable = "/path/to/claude",  -- Full path to Claude CLI
})
```

### Terminal Not Opening

1. Check that your terminal supports Neovim's terminal features
2. Verify Claude CLI is working: `claude --help`
3. Check debug logs in `~/.config/nvim/claude_debug.log`

### LazyVim Import Order Issues

If you see LazyVim import order warnings:

```lua
-- In your lazy.lua config
vim.g.lazyvim_check_order = false
```

## Contributing

We welcome contributions! Please feel free to submit issues, feature requests, and pull requests.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built for the [Claude Code](https://claude.ai/code) CLI
- Inspired by AI integration patterns in modern editors
- Thanks to the Neovim community for the amazing ecosystem

## Related Projects

- [Claude Code CLI](https://claude.ai/code) - The official Claude Code command-line interface
- [copilot.vim](https://github.com/github/copilot.vim) - GitHub Copilot for Vim/Neovim
- [ChatGPT.nvim](https://github.com/jackMort/ChatGPT.nvim) - ChatGPT integration for Neovim

---

Made with ❤️ for the Neovim community