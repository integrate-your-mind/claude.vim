if vim.g.loaded_cheatsheet_nvim then
  return
end
vim.g.loaded_cheatsheet_nvim = 1

pcall(function()
  require('cheatsheet').setup()
end)

