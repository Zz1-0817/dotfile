return {
    {
        "williamboman/mason.nvim",
        cmd = "Mason",
        build = ":MasonUpdate",
        config = function()
            local ensure_installed = {
                "black", -- formatter
                "lua-language-server",
                "clangd",
                "shfmt",
                "pyright",
                "ruff",         -- formatter
                "markdownlint", -- formatter
                "html-lsp",
                "css-lsp",
                "typescript-language-server",
            }
            local mason_registry = require("mason-registry")
            require("mason").setup({
                pip = {
                    install_args = { "--proxy", "http://127.0.0.1:10809" }
                }
            })
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
        "neovim/nvim-lspconfig",
        event = { "BufReadPost", "BufWritePost", "BufNewFile" },
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        },
        opts = function()
            local specified_lsp = require("lsp")
            return {
                servers = {
                    lua_ls = {},
                    clangd = {},
                    pyright = {},
                    html = { filetypes = { "html", "htmldjango" } },
                    cssls = {},
                    ts_ls = {},
                    rime_ls = specified_lsp.rime_ls
                },
                setup = {
                    rime_ls = function()
                        local configs = require('lspconfig.configs')
                        if not configs.rime_ls then
                            configs.rime_ls = {
                                default_config = {
                                    name = "rime_ls",
                                    cmd = { 'rime_ls' },
                                    filetypes = { 'markdown' },
                                    single_file_support = true,
                                },
                                settings = {},
                                docs = {
                                    description = [[
https://www.github.com/wlh320/rime-ls

A language server for librime
]],
                                }
                            }
                        end
                    end
                }
            }
        end,
        config = function(_, opts)
            local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
            local capabilities = has_cmp and
                cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities()) or
                vim.lsp.protocol.make_client_capabilities()

            local servers = opts.servers
            local lspconfig = require("lspconfig")

            local function setup(server)
                local server_opts = vim.tbl_deep_extend("force", {
                    capabilities = vim.deepcopy(capabilities),
                }, servers[server] or {})

                if opts.setup[server] then
                    opts.setup[server](server_opts)
                else
                    lspconfig[server].setup(server_opts)
                end
            end

            for server, server_opts in pairs(servers) do
                if server_opts.enabled ~= false then
                    setup(server)
                end
            end
        end
    },
    {
        'stevearc/conform.nvim',
        event = "LspAttach",
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
        event = "VeryLazy",
        priority = 1000,
        opts = { preset = "minimal" },
    },
    {
        "hedyhli/outline.nvim",
        lazy = true,
        cmd = { "Outline", "OutlineOpen" },
        keys = {
            { "<leader>o", "<cmd>Outline<CR>", desc = "Toggle outline" },
        },
        opts = {},
    },
}
