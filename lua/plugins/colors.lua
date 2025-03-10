return {
    { "norcalli/nvim-colorizer.lua", opts = {} },
    {
        "catppuccin/nvim",
        name     = "catppuccin",
        priority = 1000,
        config   = function()
            require("catppuccin").setup({
                integrations = {
                    dropbar = {
                        enabled = true,
                        color_mode = true, -- enable color for kind's texts, not just kind's icons
                    },
                }
            })
            vim.cmd.colorscheme("catppuccin")
        end
    },
}
