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
                "Package xeCJK Warning: Fandol",
                "Package fontspec Warning: Font",
                "Package tcolorbox Warning: Using nobreak failed",
                "Empty bibliography",
                "You have requested",
                "Overfull"
            }
        end,
        config = function()
            vim.fn['vimtex#imaps#add_map']({ lhs = "n", rhs = "\\nabla", wrapper = "vimtex#imaps#wrap_math" })
            vim.fn['vimtex#imaps#add_map']({ lhs = "p", rhs = "\\partial", wrapper = "vimtex#imaps#wrap_math" })
            vim.fn['vimtex#imaps#add_map']({ lhs = "x", rhs = "\\otimes", wrapper = "vimtex#imaps#wrap_math" })
            vim.fn['vimtex#imaps#add_map']({ lhs = "o", rhs = "\\oplus", wrapper = "vimtex#imaps#wrap_math" })
            vim.fn['vimtex#imaps#add_map']({
                lhs = "s",
                rhs = 'vimtex#imaps#style_math("mathscr")',
                expr = 1,
                leader = "#",
                wrapper = "vimtex#imaps#wrap_math"
            })
            vim.fn['vimtex#imaps#add_map']({
                lhs = "F",
                rhs = 'vimtex#imaps#style_math("mathfrak")',
                expr = 1,
                leader = "#",
                wrapper = "vimtex#imaps#wrap_math"
            })
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
    }
}
