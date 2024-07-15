local colorscheme = utils.startup.check_colorscheme()
return {
    {
        "folke/tokyonight.nvim",
        name = "tokyonight",
        priority = 1000,
        cond = function(plugin)
            return plugin.name == colorscheme
        end,
        opts = {
            style = "storm",
            light_style = "day",
            terminal_colors = true,
            styles = {
                comments = { italic = true },
                keywords = { italic = true },
                functions = {},
                variables = {},
                sidebars = "dark",
                floats = "dark",
            },
            sidebars = { "qf", "help" },
            day_brightness = 0.3,
            hide_inactive_statusline = false,
            dim_inactive = true,
            lualine_bold = true,
        },
        config = function(_, opts)
            require("tokyonight").setup(opts)
            vim.cmd("colorscheme tokyonight")
        end
    },
    {
        "catppuccin/nvim",
        name     = "catppuccin",
        priority = 1000,
        cond     = function(plugin)
            return plugin.name == colorscheme
        end,
        opts     = {
            background = {
                light = "latte",
                dark = "mocha",
            },
        },
        config   = function(_, opts)
            require("catppuccin").setup(opts)
            vim.cmd [[colorscheme catppuccin]]
        end
    },
    {
        "EdenEast/nightfox.nvim",
        name     = "nightfox",
        priority = 1000,
        cond     = function(plugin)
            return plugin.name == colorscheme
        end,
        opts     = {},
        config   = function(_, opts)
            require("nightfox").setup(opts)
            vim.cmd [[colorscheme dayfox]]
        end
    }
}
