vim.opt_local.textwidth = 80
vim.keymap.set('i', '<M-f>', function()
    utils.edit.next_ptn(true, "[ \t]+")
end, { buffer = true })
vim.keymap.set('i', '<M-b>', function()
    utils.edit.next_ptn(false, "[ \t]+")
end, { buffer = true })
vim.treesitter.start()
