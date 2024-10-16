vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "term://*",
    callback = function()
        local opts = { buffer = 0 }
        vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
        vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
    end
})

vim.api.nvim_create_autocmd({ 'BufLeave', 'WinLeave' }, {
    callback = function()
        vim.wo.winbar = ''
    end,
    desc = "only show winbar in the window of cursor"
})

vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = { "Markdown" },
    callback = function(event)
        vim.keymap.set("n", "<leader>ll", "<CMD>MarkdownPreviewToggle<CR>", { buffer = event.buf, silent = true })
    end
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = {
        "PlenaryTestPopup",
        "help",
        "lspinfo",
        "notify",
        "qf",
        "spectre_panel",
        "startuptime",
        "tsplayground",
        "neotest-output",
        "checkhealth",
        "neotest-summary",
        "neotest-output-panel",
        "dbout",
        "gitsigns.blame",
        "query"
    },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
    end,
})
