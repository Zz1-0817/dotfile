return {
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        build = "cd app && yarn install",
        ft = { "markdown" },
        init = function()
            vim.g.mkdp_browser = [[C:\Program Files\Google\Chrome\Application\chrome.exe]]
            vim.g.mkdp_auto_close = 0
        end
    },
    {
        "lervag/vimtex",
        init = function()
            vim.g.vimtex_compiler_progname = 'nvr'
            vim.g.vimtex_view_general_viewer = 'SumatraPDF'
            vim.g.vimtex_view_general_options = '-reuse-instance -forward-search @tex @line @pdf'
            vim.g.vimtex_compiler_latexmk = {
                build_dir = '',
                callback = 1,
                continuous = 1,
                executable = 'latexmk',
                hooks = {},
                options = {
                    '-verbose',
                    '-file-line-error',
                    '-synctex=-1',
                    '-interaction=nonstopmode'
                }
            }
            vim.g.vimtex_quickfix_ignore_filters = {
                "Missing character: There",
                "Package xeCJK Warning: Undefined",
                "Package xeCJK Warning: Unknown",
                "Package xeCJK Warning: Fandol",
                "Package fontspec Warning: Font",
                "Package tcolorbox Warning: Using nobreak failed",
                "Empty bibliography",
                "You have requested",
                "Overfull"
            }
            vim.g.vimtex_imaps_enabled = false
            vim.g.vimtex_mappings_disable = {
                i = { "]]" }
            }
        end,
        config = function()
        end
    },
    {
        "epwalsh/obsidian.nvim",
        version = "*", -- recommended, use latest release instead of latest commit
        lazy = true,
        ft = "markdown",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        opts = {
            workspaces = {
                {
                    name = "personal",
                    path = "~/vaults/personal",
                },
                {
                    name = "work",
                    path = "~/vaults/work",
                },
            },
        },
    },
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                { path = "luvit-meta/library", words = { "vim%.uv" } },
            },
        },
    },
    { "Bilal2453/luvit-meta", lazy = true }
}
