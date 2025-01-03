return {
    {
        "tpope/vim-fugitive",
        config = function() end
    },
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPost", "BufWritePost", "BufNewFile" },
        opts = {
            on_attach = function(buffer)
                local gs = package.loaded.gitsigns

                vim.keymap.set('n', ']h', gs.next_hunk, { buffer = buffer, desc = "Next Hunk" })
                vim.keymap.set('n', '[h', gs.prev_hunk, { buffer = buffer, desc = "Prev Hunk" })

            end
        }
    }
}
