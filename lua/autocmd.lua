vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('LspConfig', {}),
    callback = function(ev)
        -- For other keybindings, see https://neovim.io/doc/user/lsp.html#grr
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
        local opts = { buffer = ev.buf }
        if not vim.version().prerelease then
            vim.keymap.set('n', 'grn', vim.lsp.buf.rename, opts)
            vim.keymap.set('n', 'gra', vim.lsp.buf.code_action, opts)
            vim.keymap.set('n', 'grr', vim.lsp.buf.references, opts)
            vim.keymap.set('n', 'gri', vim.lsp.buf.implementation, opts)
            vim.keymap.set('n', 'gO', vim.lsp.buf.document_symbol, opts)
            vim.keymap.set('i', '<C-s>', vim.lsp.buf.signature_help, opts)
        end
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
        vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
        vim.keymap.set('n', '<space>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, opts)
        vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
        vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', '<space>f', function()
            local has_conform, conform = pcall(require, "conform")
            if has_conform then
                conform.format()
            else
                vim.lsp.buf.format()
            end
        end, opts)
    end,
})

vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "term://*",
    callback = function()
        local opts = { buffer = 0 }
        vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
        vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
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
        "query",
        "fugitive"
    },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
    end,
})
--
-- vim.api.nvim_create_autocmd("TermEnter", {
--     pattern = "*",
--     callback = function()
--         local buf = vim.api.nvim_get_current_buf() -- 获取当前缓冲区 ID
--         local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf })
--
--         if buftype == "terminal" then
--             vim.g.last_terminal_buf = buf -- 更新全局变量
--             print("Recorded terminal buffer:", buf)
--         end
--     end,
-- })
