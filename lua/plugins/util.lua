return {
    {
        "dstein64/vim-startuptime",
        cmd = "StartupTime",
        config = function()
            vim.g.startuptime_tries = 10
        end,
    },
    { "nvim-lua/plenary.nvim", lazy = true },
    { "mkropat/vim-ezguifont" }
}
