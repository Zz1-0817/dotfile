vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.indentexpr = nil
vim.opt_local.smartindent = true
vim.opt_local.textwidth = 80

vim.keymap.set('i', '<M-f>', function()
    utils.edit.next_ptn(true, "[ \t]+")
end, { buffer = true })

vim.keymap.set('i', '<M-b>', function()
    utils.edit.next_ptn(false, "[ \t]+")
end, { buffer = true })
