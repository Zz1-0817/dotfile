return {
    { "norcalli/nvim-colorizer.lua", opts = {} },
    {
        "catppuccin/nvim",
        name     = "catppuccin",
        priority = 1000,
        opts     = {
            integrations = {
                dropbar = {
                    enabled = true,
                    color_mode = true, -- enable color for kind's texts, not just kind's icons
                },
            }
        },
        config   = function(_, opts)
            require("catppuccin").setup(opts)
            vim.cmd.colorscheme("catppuccin")
        end
    },
}
