# cheatsheet.nvim

A dead-simple Neovim plugin that shows a searchable keymap cheatsheet and a tiny curated favorites sheet.

- <leader>? — Open Telescope keymaps (cheatsheet)
- <leader>H — Open favorites cheatsheet (floating window)
- :CheatSheet — Open Telescope keymaps
- :CheatSheetFavorites — Open favorites sheet

## Install

lazy.nvim:

```lua
{
  "<your-account>/cheatsheet.nvim",
  config = function()
    require("cheatsheet").setup()
  end,
}
```

vim-plug:

```vim
Plug '<your-account>/cheatsheet.nvim'
lua << EOF
require('cheatsheet').setup()
EOF
```

## Configure (optional)

```lua
require('cheatsheet').setup({
  key = "<leader>?",           -- key for Telescope keymaps
  favorites_key = "<leader>H", -- key for favorites floating sheet
  desc = "Cheat Sheet",
  favorites_desc = "Cheat Sheet (favorites)",
})
```

## Notes
- Requires nvim-telescope/telescope.nvim for the searchable keymap view.
- The favorites sheet is a tiny floating window and works without Telescope.
