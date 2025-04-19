-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local opts = { noremap = true, silent = true }

local keymap = vim.api.nvim_set_keymap

keymap("i", "hh", "=>", opts)
keymap("i", "kk", "->", opts)
keymap("i", "kkk", "->{}<ESC>i", opts)
-- keymap("i", "ddd", '<Esc>:r ! date +"\\#\\# \\%Y-\\%m-\\%d \\%H:\\%M" <CR>', opts)

-- Navigate buffers
keymap("n", "<S-l>", ":bnext<CR>", opts)
keymap("n", "<S-h>", ":bprevious<CR>", opts)

-- Move text up and down
-- keymap("n", "<A-j>", "<Esc>:m .+1<CR>==gi", opts)
-- keymap("n", "<A-k>", "<Esc>:m .-2<CR>==gi", opts)

-- Insert --
-- Press jk fast to exit insert mode
-- keymap("i", "jk", "<ESC>", opts)
-- keymap("i", "kj", "<ESC>", opts)

-- Visual --
-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

keymap("v", "p", '"_dP', opts)

-- Save file
-- keymap("n", "<leader>w", "<cmd>w<cr>", opts)
local function toggle_list()
  if vim.opt.list:get() then
    vim.cmd("setlocal nolist")
    vim.cmd("IBLDisable")
    vim.b.miniindentscope_disable = true
  else
    vim.cmd("setlocal list")
    vim.cmd("IBLEnable")
    vim.b.miniindentscope_disable = false
  end
end

vim.keymap.set("n", "<leader>um", toggle_list, { desc = "Toggle listchars" })
