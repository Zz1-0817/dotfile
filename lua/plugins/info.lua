return {
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        init = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
        end,
        opts = {
            defaults = {
                ["<localLeader>l"] = { name = "+vimtex" },
            },
        }
    },
    {
        'kevinhwang91/nvim-hlslens',
        event = { "BufReadPost", "BufWritePost", "BufNewFile" },
        opts = {}
    },
    { "romainl/vim-cool" },
    {
        "j-hui/fidget.nvim",
        event = { "BufReadPost", "BufWritePost", "BufNewFile" },
        opts = {
            notification = {
                override_vim_notify = true,
                window = {
                    max_width = 45,
                    align = "top"
                }
            }
        },
        config = function(_, opts)
            require("fidget").setup(opts)
        end
    },
}
