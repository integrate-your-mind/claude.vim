return {
  {
    name = "cheatsheet",
    dir = vim.fn.stdpath("config"),
    lazy = false,
    config = function()
      require('cheatsheet').setup()
    end,
  },
}

