return {
    {
        "williamboman/mason.nvim",
        cmd = "Mason",
        build = ":MasonUpdate",
        config = function()
            local ensure_installed = {
                "ruff",
                "stylua",
                "black",
                "lua-language-server",
                "clangd",
                "shfmt",
                "pyright",
                "marksman",
                "markdownlint",
                "html-lsp",
                "css-lsp",
                "latexindent"
            }
            local mason_registry = require("mason-registry")
            require("mason").setup({
                PATH = "prepend",
                github = {
                    download_url_template =
                    "https://github.abskoop.workers.dev/github.com/%s/releases/download/%s/%s"
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
            "williamboman/mason-lspconfig.nvim"
        },
        opts = function()
            local specified_lsp = require("lsp")
            return {
                diagnostics = {
                    underline = true,
                    update_in_insert = false,
                    virtual_text = false,
                    signs = {
                        text = {
                            [vim.diagnostic.severity.ERROR] = utils.icons.diagnostics.Error,
                            [vim.diagnostic.severity.WARN] = utils.icons.diagnostics.Warn,
                            [vim.diagnostic.severity.HINT] = utils.icons.diagnostics.Hint,
                            [vim.diagnostic.severity.INFO] = utils.icons.diagnostics.Info,
                        }
                    },
                    linehl = {
                        [vim.diagnostic.severity.ERROR] = 'ErrorMsg',
                    },
                    numhl = {
                        [vim.diagnostic.severity.WARN] = 'WarningMsg',
                    },
                    severity_sort = true,
                    document_highlight = {
                        enabled = true,
                    },
                },
                servers = {
                    lua_ls = {
                        settings = {
                            Lua = {
                                workspace = {
                                    checkThirdParty = false,
                                },
                                codeLens = {
                                    enable = true,
                                },
                                completion = {
                                    callSnippet = "Replace",
                                },
                                doc = {
                                    privateName = { "^_" },
                                },
                                hint = {
                                    enable = true,
                                    setType = false,
                                    paramType = true,
                                    paramName = "Disable",
                                    semicolon = "Disable",
                                    arrayIndex = "Disable",
                                },
                            },
                        }
                    },
                    clangd = {},
                    pyright = {},
                    marksman = {},
                    html = { filetypes = { "html", "htmldjango" } },
                    cssls = {},
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
            vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

            local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
            local capabilities = vim.tbl_deep_extend(
                "force",
                {},
                vim.lsp.protocol.make_client_capabilities(),
                has_cmp and cmp_nvim_lsp.default_capabilities() or {},
                opts.capabilities or {}
            )

            local servers = opts.servers
            local lspconfig = require("lspconfig")

            local function setup(server)
                local server_opts = vim.tbl_deep_extend("force", {
                    capabilities = vim.deepcopy(capabilities),
                }, servers[server] or {})

                if opts.setup[server] then
                    if opts.setup[server](server_opts) then
                        return
                    end
                end

                lspconfig[server].setup(server_opts)
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
        event = "LspAttach", -- Or `LspAttach`
        priority = 1000,     -- needs to be loaded in first
        config = function()
            require('tiny-inline-diagnostic').setup()
        end
    }
}
