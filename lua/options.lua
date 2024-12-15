local opt = vim.opt
opt.swapfile = false
opt.splitright = true
opt.list = true
opt.number = true
opt.relativenumber = true
opt.encoding = "utf-8"
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.cursorline = true
opt.cursorcolumn = false
opt.mouse = 'a'
opt.clipboard = ""
opt.termguicolors = true
opt.backup = false
opt.writebackup = false
opt.updatetime = 300
opt.signcolumn = "yes"
opt.pumheight = 15
opt.pumblend = 15
opt.laststatus = 3
opt.splitkeep = "screen"
opt.mousemoveevent = true

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.python3_host_prog = "C:\\Users\\Zz1\\scoop\\apps\\python\\3.12.1\\python.exe"
vim.g.rime_enabled = false

if vim.fn.has("nvim-0.10") == 1 then
    opt.smoothscroll = true
end
