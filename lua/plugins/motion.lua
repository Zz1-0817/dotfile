return {
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        keys = {
            {
                "<C-j>",
                mode = { "n", "o", "x" },
                function() require("flash").jump() end,
                desc = "Flash"
            },
            {
                "<C-s>",
                mode = { "n", "o", "x" },
                function() require("flash").treesitter() end,
                desc = "Flash Treesitter"
            }
        },
        opts = {
            highlight = {
                groups = {
                    label = "Search"
                }
            }
        }
    }
}
