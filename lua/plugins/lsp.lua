local get_capabilities = function()
    local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
    return has_cmp and
        cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities()) or
        vim.lsp.protocol.make_client_capabilities()
end

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
                "gopls",
                "rust-analyzer",
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
        },
        config = function()
            local mason_servers = {}

            require("mason-lspconfig").setup()
            require("mason-lspconfig").setup_handlers({
                function(server_name)
                    local opts = { capabilities = vim.deepcopy(get_capabilities()) }
                    opts = vim.tbl_deep_extend("force", opts, mason_servers[server_name] or {})
                    require("lspconfig")[server_name].setup(opts)
                end
            })
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
