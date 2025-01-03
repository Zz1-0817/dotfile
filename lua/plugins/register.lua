return {
    {
        "gbprod/yanky.nvim",
        opts = {},
        keys = {
            {
                "y",
                "<Plug>(YankyYank)",
                mode = { "n", "x" },
                desc = "Yank Text"
            },
            {
                "p",
                "<Plug>(YankyPutAfter)",
                mode = { "n", "x" },
                desc = "Put Text After Cursor"
            },
            {
                "P",
                "<Plug>(YankyPutBefore)",
                mode = { "n", "x" },
                desc = "Put Text Before Cursor"
            },
            {
                "gp",
                "<Plug>(YankyGPutAfter)",
                mode = { "n", "x" },
                desc = "Put Text After Selection"
            },
            {
                "gP",
                "<Plug>(YankyGPutBefore)",
                mode = { "n", "x" },
                desc = "Put Text Before Selection"
            },
            {
                "<c-p>",
                "<Plug>(YankyPreviousEntry)",
                desc = "Select previous entry through yank history"
            },
            {
                "<c-n>",
                "<Plug>(YankyNextEntry)",
                desc = "Select next entry through yank history"
            },
        }
    }
}
