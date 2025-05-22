return {
    {
        "williamboman/mason.nvim",
        cmd = "Mason",
        config = function()
            local ensure_installed = {
                "lua-language-server",
                "clangd",
                "shfmt",
                "pyright",
                "ruff",         -- formatter
                "marksman",
                "markdownlint", -- formatter
                "html-lsp",
                "css-lsp",
                "typescript-language-server",
                -- "gopls",
                "rust-analyzer",
                "tinymist"
            }
            require("mason").setup()
            local mason_registry = require("mason-registry")
            local function install_packages()
                for _, pkg in ipairs(ensure_installed) do
                    local package = mason_registry.get_package(pkg)
                    if not package:is_installed() then
                        package:install()
                    end
                end
            end
            if mason_registry then
                mason_registry.refresh(install_packages)
            else
                install_packages()
            end
        end
    },
    {
        "williamboman/mason-lspconfig.nvim",
        event = { "BufReadPost", "BufWritePost", "BufNewFile" },
        dependencies = {
            "williamboman/mason.nvim",
            "neovim/nvim-lspconfig",
            "hrsh7th/cmp-nvim-lsp",
        },
        opts = {},
        config = function(_, opts)
            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            vim.lsp.config('*', {
                capabilities = capabilities
            })
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
            })
            require("mason-lspconfig").setup(opts)
        end
    },
    {
        'stevearc/conform.nvim',
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        keys = {
            {
                "<leader>f",
                function()
                    require("conform").format({ async = true })
                end,
                desc = "Format buffer",
            },
        },
        opts = {
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
        },
    },
    {
        "rachartier/tiny-inline-diagnostic.nvim",
        event = "VeryLazy", -- event "LspAttach" works wierd.
        priority = 1000,
        opts = { preset = "minimal" },
    },
    {
        'stevearc/aerial.nvim',
        opts = {
            backends = { "treesitter", "lsp", "markdown", "asciidoc", "man" },
            close_automatic_events = { "unfocus", "switch_buffer", "unsupported" },
            on_attach = function(bufnr)
                vim.keymap.set("n", "<leader>o", "<CMD>AerialToggle<CR>", { buffer = bufnr })
            end,
        },
    }
}
