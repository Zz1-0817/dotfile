return {
    {
        "nvim-telescope/telescope.nvim",
        cmd = "Telescope",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "debugloop/telescope-undo.nvim",
            -- "nvim-telescope/telescope-project.nvim"
        },
        keys = {
            { "<leader>ff", "<cmd>Telescope find_files<cr>",   desc = "Find files(root dir)" },
            { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "File browser" },
            { "<leader>fg", "<cmd>Telescope live_grep<cr>",    desc = "Grep(root dir)" },
            { "<leader>fh", "<cmd>Telescope help_tags<cr>",    desc = "Help tags" },
            { "<leader>fr", "<cmd>Telescope oldfiles<cr>",     desc = "Recent" },
            -- { "<leader>fp", "<cmd>Telescope project<cr>",      desc = "Project" },
            { "<leader>u",  "<cmd>Telescope undo<cr>",         desc = "Undo history", },
            { "<leader>gc", "<cmd>Telescope git_commits<CR>",  desc = "Git commits" },
            { "<leader>gb", "<cmd>Telescope git_branches<CR>", desc = "Git branch" },
            { "<leader>gs", "<cmd>Telescope git_status<CR>",   desc = "Git status" },
        },
        config = function()
            local actions = require("telescope.actions")
            local config = require("telescope.config")
            -- local action_layout = require("telescope.actions.layout")
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
                            ["<C-Down>"] = actions.cycle_history_next,
                            ["<C-Up>"] = actions.cycle_history_prev,
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
            require("telescope").load_extension("undo")
            -- require("telescope").load_extension('project')
        end
    }
}
