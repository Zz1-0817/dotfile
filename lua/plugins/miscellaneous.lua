return {
    {
        "dstein64/vim-startuptime",
        cmd = "StartupTime",
        config = function()
            vim.g.startuptime_tries = 10
        end,
    },
    {
        "NStefan002/screenkey.nvim",
        cmd = "Screenkey",
        -- lazy = false,
        version = "*", -- or branch = "dev", to use the latest commit
    },
}
