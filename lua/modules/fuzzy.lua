return {
    load = function()
        vim.pack.add({
            { src = "https://github.com/nvim-lua/plenary.nvim" },
            { src = "https://github.com/nvim-telescope/telescope.nvim" },
        })
        local actions = require("telescope.actions")
        local config = require("telescope.config")
        local vimgrep_arguments = { unpack(config.values.vimgrep_arguments) }
        require("telescope").setup({
            defaults = {
                vimgrep_arguments = vimgrep_arguments,
                layout_strategy = 'bottom_pane',
                sorting_strategy = "ascending",
                mappings = {
                    i = {
                        ["<C-f>"] = actions.preview_scrolling_down,
                        ["<C-b>"] = actions.preview_scrolling_up,
                    },
                    n = {
                        ["q"] = actions.close,
                    }
                },
                preview = {
                    treesitter = false
                }
            },
        })
    end,
    init = function()
        vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>",
            { desc = "File(Telescope)", noremap = true, silent = true })
        vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<CR>",
            { desc = "Buffer(Telescope) ", noremap = true, silent = true })
        vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>",
            { desc = "Grep(Telescope)", noremap = true, silent = true })
        vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>",
            { desc = "Help tags(Telescope)", noremap = true, silent = true })
        vim.keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>",
            { desc = "Recent(Telescope)", noremap = true, silent = true })
    end
}
