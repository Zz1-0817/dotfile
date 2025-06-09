local servers = {
    ["lua-language-server"] = "lua_ls",
    ["clangd"] = "clangd",
    ["shfmt"] = "shfmt",
    ["pyright"] = "pyright",
    ["ruff"] = "ruff",
    ["marksman"] = "marksman",
    ["markdownlint"] = "markdownlint",
    ["html-lsp"] = "html",
    ["css-lsp"] = "cssls",
    ["typescript-language-server"] = "ts_ls",
    ["vue-language-server"] = "vue_ls",
    ["rust-analyzer"] = "rust_analyzer",
    ["tinymist"] = "tinymist"
}


return {
    {
        "williamboman/mason.nvim",
        cmd = "Mason",
        config = function()
            require("mason").setup()
            local mason_registry = require("mason-registry")
            local function install_packages()
                for server, _ in pairs(servers) do
                    local package = mason_registry.get_package(server)
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
        "neovim/nvim-lspconfig",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp"
        },
        config = function()
            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/"
            vim.lsp.config('*', {
                capabilities = capabilities
            })
            for _, config_name in pairs(servers) do
                local cfg = vim.lsp.config[config_name]
                if cfg ~= nil then
                    local cmd = vim.deepcopy(cfg["cmd"])
                    cmd[1] = mason_bin .. cmd[1]
                    vim.lsp.config(config_name, {
                        cmd = cmd
                    })
                    vim.lsp.enable(config_name)
                end
            end
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
            backends = { "lsp", "treesitter", "markdown", "asciidoc", "man" },
            close_automatic_events = { "unfocus", "switch_buffer", "unsupported" },
            on_attach = function(bufnr)
                vim.keymap.set("n", "<leader>o", "<CMD>AerialToggle<CR>", { buffer = bufnr })
            end,
        },
    }
}
