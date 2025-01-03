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
    { "romainl/vim-cool" },
    {
        "j-hui/fidget.nvim",
        opts = {},
    },
}
