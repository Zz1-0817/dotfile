require("options")
require("keymaps")
require("autocmd")

_G.utils = require("utils")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end

vim.opt.rtp:prepend(lazypath)
require("lazy").setup({ { import = "plugins" } })

vim.o.guifont = "JetBrainsMonoNL Nerd Font Mono:h14"
