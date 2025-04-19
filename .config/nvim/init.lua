-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.filetype.add({
  pattern = {
    [".*%.html%.ep"] = "html",
    [".*%.tt"] = "html",
    [".*%.md"] = "markdown",
  },
})

vim.opt.title = true
vim.opt.titlestring = [[%f %h%m%r%w %{v:progname} (%{tabpagenr()} of %{tabpagenr('$')})]]
