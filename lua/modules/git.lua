return {
    init = function()
        vim.pack.add({
            { src = "https://github.com/tpope/vim-fugitive" },
            { src = "https://github.com/lewis6991/gitsigns.nvim" },
        })
        local gitsigns = require('gitsigns')
        gitsigns.setup({
            on_attach = function (bufnr)
                vim.keymap.set("n", "]h", function ()
                    if vim.wo.diff then
                        vim.cmd.normal({ ']c', bang = true })
                    else
                        gitsigns.nav_hunk('next')
                    end
                end, { noremap = true, silent = true, buffer = bufnr })
                vim.keymap.set("n", "[h", function ()
                    if vim.wo.diff then
                        vim.cmd.normal({ '[c', bang = true })
                    else
                        gitsigns.nav_hunk('prev')
                    end
                end, { noremap = true, silent = true, buffer = bufnr })
            end
        })
    end
}
