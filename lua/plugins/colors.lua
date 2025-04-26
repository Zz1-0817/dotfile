return {
    -- { "norcalli/nvim-colorizer.lua", opts = {} },
    {
        "catppuccin/nvim",
        name     = "catppuccin",
        cond     = false,
        priority = 1000,
        config   = function()
            require("catppuccin").setup({
                dim_inactive = { enabled = true },
                background = { light = "latte", dark = "frappe" },
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
    {
        "savq/melange-nvim",
        priority = 1000,
        -- cond = false,
        config = function()
            vim.cmd.colorscheme("melange")
        end
    }
}
