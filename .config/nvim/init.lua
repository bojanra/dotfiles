-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.filetype.add({
  pattern = {
    [".*%.html%.ep"] = "html",
    [".*%.tt"] = "html",
    [".*%.md"] = "markdown",
  },
  filename = {
    ["todo.txt"] = "todotxt",
  },
})

vim.opt.title = true
vim.opt.titlestring = [[%f %h%m%r%w %{v:progname} (%{tabpagenr()} of %{tabpagenr('$')})]]

require("lualine").setup({
  sections = {
    lualine_b = {
      {
        require("micropython_nvim").statusline,
        cond = package.loaded["micropython_nvim"] and require("micropython_nvim").exists,
      },
    },
  },
})
