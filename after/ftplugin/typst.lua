vim.opt_local.textwidth = 80
vim.keymap.set('i', '<M-f>', function()
    utils.edit.next_pattern(true, "[ \t]+")
end, { buffer = true, noremap = true, silent = true })
vim.keymap.set('i', '<M-b>', function()
    utils.edit.next_pattern(false, "[ \t]+")
end, { buffer = true, noremap = true, silent = true })
vim.treesitter.start()
vim.keymap.set("n", "<M-P>", "<CMD>TypstPreviewToggle<CR>", { buf = 0, noremap = true,  silent = true })

