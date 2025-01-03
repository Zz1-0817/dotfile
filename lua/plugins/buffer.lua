return {
    {
        'echasnovski/mini.bufremove',
        keys = {
            {
                "<leader>bd",
                function()
                    local bd = require("mini.bufremove").delete
                    if vim.bo.modified then
                        local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()),
                            "&Yes\n&No\n&Cancel")
                        if choice == 1 then
                            vim.cmd.write()
                            bd(0)
                        elseif choice == 2 then
                            bd(0, true)
                        end
                    else
                        bd(0)
                    end
                end,
                desc = "Delete Buffer",
            }, },
        version = false,
        opts = {}
    },
    {
        "akinsho/bufferline.nvim",
        dependencies = "nvim-tree/nvim-web-devicons",
        event        = "VeryLazy",
        version      = "*",
        keys         = {
            { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>",            desc = "Toggle pin" },
            { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete non-pinned buffers" },
            { "<leader>bo", "<Cmd>BufferLineCloseOthers<CR>",          desc = "Delete other buffers" },
            { "<leader>br", "<Cmd>BufferLineCloseRight<CR>",           desc = "Delete buffers to the right" },
            { "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>",            desc = "Delete buffers to the left" },
            { "<leader>bk", "<Cmd>BufferLinePick<CR>",                 desc = "Pick buffer" },
            { "[b",         mode = 'n',                                "<CMD>BufferLineCyclePrev<CR>",      desc = "Next buffer" },
            { "]b",         mode = 'n',                                "<CMD>BufferLineCycleNext<CR>",      desc = "Prev buffer" }
        },
        opts         = {
            options = {
                mode = "buffers",
                themable = true,
                numbers = "none",
                indicator = { style = 'underline', },
                diagnostics = "nvim_lsp",
                diagnostics_indicator = function(count, level, diagnostics_dict, context)
                    if not context.buffer:current() then
                        return ''
                    end
                    local icon = "msg:"
                    return icon .. count
                end,
                always_show_bufferline = false,
                hover = {
                    enabled = true,
                    delay = 200,
                    reveal = { 'close' }
                }
            },
        },
    }
}
