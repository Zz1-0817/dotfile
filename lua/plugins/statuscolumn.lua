return {
    {
        "luukvbaal/statuscol.nvim",
        init = function()
            vim.o.fillchars = [[eob: ,fold: ,foldopen:󰅀,foldsep: ,foldclose:]]
            vim.o.foldcolumn = "1"
            vim.o.foldlevel = 64
            vim.o.foldlevelstart = 64
            vim.o.foldenable = true
        end,
        config = function()
            local builtin = require("statuscol.builtin")
            require("statuscol").setup({
                relculright = true,
                segments = {
                    { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
                    { text = { builtin.lnumfunc }, click = "v:lua.ScLa" },
                    {
                        sign = { namespace = { "gitsigns" } },
                        click = "v:lua.ScSa"
                    },
                    {
                        sign = { namespace = { "diagnostic/signs" } },
                        click = "v:lua.ScSa"
                    },
                },
            })
        end,
    },
    {
        "kevinhwang91/nvim-ufo",
        event = { "BufReadPost", "BufWritePost", "BufNewFile" },
        dependencies = {
            "kevinhwang91/promise-async",
        },
        keys = {
            { "zR", function() require('ufo').openAllFolds() end,         desc = "Ufo Open All Folds" },
            { "zM", function() require('ufo').closeAllFolds() end,        desc = "Ufo Close All Folds" },
            { "zr", function() require('ufo').openFoldsExceptKinds() end, desc = "Ufo Folds Except Kinds" },
            { "zm", function() require('ufo').closeFoldsWith() end,       desc = "Ufo Close Folds With" },
        },
        opts = function()
            local ftMap = {
                tex = '',
            }
            return {
                provider_selector = function(bufnr, filetype, buftype)
                    return ftMap[filetype] or { 'treesitter', 'indent' }
                end,
                fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
                    local newVirtText = {}
                    local suffix = (' 󰁂 %d '):format(endLnum - lnum)
                    local sufWidth = vim.fn.strdisplaywidth(suffix)
                    local targetWidth = width - sufWidth
                    local curWidth = 0
                    for _, chunk in ipairs(virtText) do
                        local chunkText = chunk[1]
                        local chunkWidth = vim.fn.strdisplaywidth(chunkText)
                        if targetWidth > curWidth + chunkWidth then
                            table.insert(newVirtText, chunk)
                        else
                            chunkText = truncate(chunkText, targetWidth - curWidth)
                            local hlGroup = chunk[2]
                            table.insert(newVirtText, { chunkText, hlGroup })
                            chunkWidth = vim.fn.strdisplaywidth(chunkText)
                            if curWidth + chunkWidth < targetWidth then
                                suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
                            end
                            break
                        end
                        curWidth = curWidth + chunkWidth
                    end
                    table.insert(newVirtText, { suffix, 'MoreMsg' })
                    return newVirtText
                end
            }
        end,
    }
}
