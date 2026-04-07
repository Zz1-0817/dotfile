vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('lsp_key_config', { clear = true }),
    callback = function(event)
        vim.bo[event.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
        local opts = { buffer = event.buf, noremap = true, silent = true }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)

        vim.api.nvim_create_user_command('WorkspaceAdd', vim.lsp.buf.add_workspace_folder, { desc = "Add workspace" })
        vim.api.nvim_create_user_command('WorkspaceRemove', vim.lsp.buf.remove_workspace_folder,
            { desc = "Remove workspace" })
        vim.api.nvim_create_user_command('WorkspaceList', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, { desc = "List workspace" })
        vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
        vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)

        vim.keymap.set('n', "<M-F>", function()
            require("conform").format({ async = true })
        end, opts)
        vim.keymap.set("n", "<leader>o", "<CMD>AerialToggle<CR>", opts)
    end,
})

vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "term://*",
    callback = function()
        vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], { buffer = true, noremap = true, silent = true })
    end
})

vim.api.nvim_create_autocmd("CmdUndefined", {
    once = true,
    pattern = "Mason",
    group = vim.api.nvim_create_augroup('load_lsp_manager', { clear = true }),
    callback = function()
        require("modules.lsp").load_manager()
    end
})

vim.api.nvim_create_autocmd("CmdUndefined", {
    once = true,
    pattern = "Telescope",
    group = vim.api.nvim_create_augroup('load_fuzzy_finder', { clear = true }),
    callback = function()
        require("modules.fuzzy").load()
    end
})
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "lua" },
    once = true,
    group = vim.api.nvim_create_augroup('load_nvim_config_dev_tools', { clear = true }),
    callback = function()
        vim.pack.add({
            { src = "https://github.com/dstein64/vim-startuptime" },
            { src = "https://github.com/folke/lazydev.nvim" },
        })
        require("lazydev").setup({ library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } }, }, })
    end
})
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "html" },
    once = true,
    group = vim.api.nvim_create_augroup('load_live_server', { clear = true }),
    callback = function()
        vim.pack.add({
            { src = "https://github.com/barrett-ruth/live-server.nvim" },
        })
    end
})

vim.api.nvim_create_autocmd("FileType", {
    once = true,
    group = vim.api.nvim_create_augroup('user_defined_file_quit', { clear = true }),
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

vim.api.nvim_create_autocmd("FileType", {
    once = true,
    group = vim.api.nvim_create_augroup('load_typst_previewer', { clear = true }),
    callback = function()
        vim.pack.add({
            { src = "https://github.com/chomosuke/typst-preview.nvim" },
        })
        require("typst-preview").setup({
            dependencies_bin = {
                ['tinymist'] = vim.fn.stdpath("data") .. '/mason/bin/tinymist'
            }
        })
    end
})

vim.api.nvim_create_autocmd("FileType", {
    once = true,
    group = vim.api.nvim_create_augroup('load_markdown_settings', { clear = true }),
    callback = function()
        vim.pack.add({
            { src = "https://github.com/preservim/vim-markdown" },
        })
    end
})

vim.api.nvim_create_autocmd("DiagnosticChanged", {
    group = vim.api.nvim_create_augroup('set_diagnostic_result', { clear = true }),
    callback = function()
        vim.diagnostic.setqflist({ open = false })
    end,
})

vim.api.nvim_create_autocmd("InsertEnter", {
    once = true,
    group = vim.api.nvim_create_augroup('load_completion', { clear = true }),
    callback = function()
        require("modules.edit").load_completion()
    end
})

vim.api.nvim_create_autocmd("BufEnter", {
    once = true,
    group = vim.api.nvim_create_augroup('load_edit', { clear = true }),
    callback = function()
        require("modules.edit").load_basic()
        require("modules.edit").load_pair()
    end
})

vim.api.nvim_create_autocmd('LspAttach', {
    once = true,
    group = vim.api.nvim_create_augroup('load_lsp_attach', { clear = true }),
    callback = function()
        require("modules.lsp").load_diagnose()
        require("modules.lsp").load_formatter()
        require("modules.lsp").load_outline()
        require("modules.lsp").load_messages()
    end
})
