vim.g.vim_markdown_math = 1
vim.pack.add({
    { src = "https://github.com/preservim/vim-markdown" },
})
vim.opt_local.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
