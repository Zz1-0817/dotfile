return {
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
                offsets = {
                    {
                        filetype = "NvimTree",
                        text = "File Explorer",
                        text_align = "left",
                        separator = true
                    }
                },
                always_show_bufferline = false,
                hover = {
                    enabled = true,
                    delay = 200,
                    reveal = { 'close' }
                }
            },
        },
        config       = function(_, opts)
            require("bufferline").setup(opts)
        end
    },
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        dependencies = "nvim-tree/nvim-web-devicons",
        init = function()
            vim.g.lualine_laststatus = vim.o.laststatus
        end,
        config = function()
            local lualine_require = require("lualine_require")
            lualine_require.require = require
            require("plugins.specified.lualine")
        end
    },
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPost", "BufWritePost", "BufNewFile" },
        opts = {
            on_attach = function(buffer)
                local gs = package.loaded.gitsigns

                local function map(mode, l, r, desc)
                    vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
                end

                -- stylua: ignore start
                map("n", "]h", gs.next_hunk, "Next Hunk")
                map("n", "[h", gs.prev_hunk, "Prev Hunk")
            end
        }
    },
    {
        "ray-x/lsp_signature.nvim",
        event = { "BufReadPost", "BufWritePost", "BufNewFile" },
        opts = { hint_prefix = "" },
    },
    {
        "Bekaboo/dropbar.nvim",
        event = { "BufReadPost", "BufWritePost", "BufNewFile" },
        keys = { { "<leader>dp", function() require("dropbar.api").pick() end, desc = "Dropbar pick" } },
        opts = { general = { attach_events = { 'BufEnter' } } }
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
        opts = {
            ---@diagnostic disable-next-line missing-fields
            provider_selector = function(bufnr, filetype, buftype)
                return { 'treesitter', 'indent' }
            end
        },
    },
    {
        'kevinhwang91/nvim-hlslens',
        event = { "BufReadPost", "BufWritePost", "BufNewFile" },
        opts = {}
    },
    { "romainl/vim-cool" },
    {
        "j-hui/fidget.nvim",
        event = { "BufReadPost", "BufWritePost", "BufNewFile" },
        opts = {
            notification = {
                override_vim_notify = true,
                window = {
                    max_width = 45,
                }
            }
        },
        config = function(_, opts)
            require("fidget").setup(opts)
        end
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        event = { "BufReadPost", "BufWritePost", "BufNewFile" },
        main = "ibl",
        opts = {},
    },
}
