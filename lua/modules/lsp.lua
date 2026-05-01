local servers = {
    ["lua-language-server"] = "lua_ls",
    ["clangd"] = "clangd",
    ["shfmt"] = "shfmt",
    ["pyright"] = "pyright",
    ["ruff"] = "ruff",
    ["marksman"] = "marksman",
    ["markdownlint"] = "markdownlint",
    ["rust-analyzer"] = "rust_analyzer",
    ["tinymist"] = "tinymist"
}

return {
    init = function()
        vim.pack.add({
            { src = "https://github.com/neovim/nvim-lspconfig" },
            { src = "https://github.com/hrsh7th/nvim-cmp" },
            { src = "https://github.com/hrsh7th/cmp-nvim-lsp" } --cmp-nvim-lsp relies on nvim-cmp
        })
        local capabilities = require("cmp_nvim_lsp").default_capabilities()
        local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/"
        vim.lsp.config('*', {
            capabilities = capabilities
        })
        for _, config_name in pairs(servers) do
            local cfg = vim.lsp.config[config_name]
            if type(cfg) == "table" then
                if type(cfg["cmd"]) == "table" then
                    local cmd = vim.deepcopy(cfg["cmd"])
                    cmd[1] = mason_bin .. cmd[1]
                    vim.lsp.config(config_name, {
                        cmd = cmd
                    })
                    vim.lsp.enable(config_name)
                end
            end
        end
        vim.lsp.config("tinymist", {
            on_attach = function(client, bufnr)
                vim.keymap.set("n", "<leader>tp", function()
                    client:exec_cmd({
                        title = "pin",
                        command = "tinymist.pinMain",
                        arguments = { vim.api.nvim_buf_get_name(0) },
                    }, { bufnr = bufnr })
                end, { desc = "[T]inymist [P]in", noremap = true })

                vim.keymap.set("n", "<leader>tu", function()
                    client:exec_cmd({
                        title = "unpin",
                        command = "tinymist.pinMain",
                        arguments = { vim.v.null },
                    }, { bufnr = bufnr })
                end, { desc = "[T]inymist [U]npin", noremap = true })
            end,
            settings = {
                formatterMode = "typstfmt"
            }
        })
    end,
    load_manager = function()
        vim.pack.add({ { src = "https://github.com/williamboman/mason.nvim" } })
        require("mason").setup()
        local mason_registry = require("mason-registry")
        if mason_registry then
            mason_registry.refresh(function()
                for server, _ in pairs(servers) do
                    local package = mason_registry.get_package(server)
                    if not package:is_installed() then
                        package:install()
                    end
                end
            end
            )
        end
    end,
    load_formatter = function()
        vim.pack.add({ { src = "https://github.com/stevearc/conform.nvim" } })
        require("conform").setup({
            formatters_by_ft = {
                python = function(bufnr)
                    if require("conform").get_formatter_info("ruff_format", bufnr).available then
                        return { "ruff_format" }
                    else
                        return { "isort", "black" }
                    end
                end,
                markdown = { "markdownlint" },
            },
            default_format_opts = {
                lsp_format = "fallback",
            },
        })
    end,
    load_diagnose = function()
        vim.pack.add({ { src = "https://github.com/rachartier/tiny-inline-diagnostic.nvim" } })
        require("tiny-inline-diagnostic").setup({ preset = "minimal" })
    end,
    load_outline = function()
        vim.pack.add({ { src = "https://github.com/stevearc/aerial.nvim" } })
        require("aerial").setup({
            backends = { "lsp", "treesitter", "markdown", "asciidoc", "man" },
            close_automatic_events = { "unfocus", "switch_buffer", "unsupported" },
            filter_kind = false,
        })
    end,
    load_messages = function()
        vim.pack.add({ { src = "https://github.com/j-hui/fidget.nvim" } })
        require("fidget").setup({})
    end
}
