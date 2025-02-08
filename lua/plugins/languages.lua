return {
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        build = "cd app && yarn install",
        ft = { "markdown" },
        init = function()
            vim.g.mkdp_auto_close = 0
            vim.api.nvim_create_autocmd({ "FileType" }, {
                pattern = { "markdown" },
                callback = function(event)
                    vim.keymap.set("n", "<leader>ll", "<CMD>MarkdownPreviewToggle<CR>",
                        { buffer = event.buf, silent = true })
                end
            })
        end
    },
    {
        "lervag/vimtex",
        init = function()
            if jit.os ~= 'Windows' then
                vim.g.vimtex_view_method = 'zathura'
            end

            vim.g.vimtex_quickfix_ignore_filters = {
                "Missing character: There",
                "Package xeCJK Warning: Undefined",
                "Package xeCJK Warning: Unknown",
                "Package xeCJK Warning: Fandol",
                "Package fontspec Warning: Font",
                "LaTeX Font Warning: Font shape",
                "Package tcolorbox Warning: Using nobreak failed",
                "Empty bibliography",
                "You have requested",
                "Overfull"
            }
            vim.g.vimtex_imaps_enabled = false
            vim.g.vimtex_fold_enabled = true
            vim.g.vimtex_fold_bib_enabled = true
            vim.g.vimtex_mappings_disable = {
                i = { "]]" }
            }
        end,
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
            },
        },
    },
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },
}
