return {
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        -- event = { "bufreadpost", "bufwritepost", "bufnewfile" },
        build = ":TSUpdate",
        -- branch = 'main',
        -- cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
        },
        main = 'nvim-treesitter.configs',
        opts = {
            ensure_installed = { "c", "css", "lua", "vim", "query", "bash", "c", "diff",
                "html", "javascript", "jsdoc", "json", "jsonc", "lua", "luadoc",
                "luap", "python", "query", "regex", "rust", "toml", "tsx",
                "typescript", "typst", "vim", "vimdoc", "xml", "yaml",
            },
            ignore_install = {},
            highlight = {
                enable = true,
                disable = { "latex", "markdown", "markdown_inline" }
            },
            incremental_selection = { enable = false },
            textobjects = {
                move = {
                    enable = true,
                    goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@call.outer" },
                    goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@call.outer" },
                    goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@call.outer" },
                    goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@call.outer" },
                },
                select = {
                    enable = true,
                    disable = { "latex" },
                    keymaps = {
                        ["af"] = "@function.outer",
                        ["if"] = "@function.inner",
                        ["ac"] = "@class.outer",
                        ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
                    }
                }
            },
        },
    },
}
