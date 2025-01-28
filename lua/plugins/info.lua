return {
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            preset = "helix",
        }
    },
    { "romainl/vim-cool" },
    {
        "j-hui/fidget.nvim",
        event = { "BufReadPost", "BufWritePost", "BufNewFile" },
        opts = {},
    },
}
