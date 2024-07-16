return {
    {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        lazy = false,
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            {
                's1n7ax/nvim-window-picker',
                name = 'window-picker',
                version = '2.*',
                opts = {
                    filter_rules = {
                        bo = {
                            filetype = { "fidget", "NvimTree" },
                            buftype = { "terminal" }
                        }
                    },
                    picker_config = { statusline_winbar_picker = { use_winbar = "smart" } },
                    hint = 'floating-big-letter',
                },
                config = function(_, opts)
                    require("window-picker").setup(opts)
                end,
            },
        },
        keys = { { "<C-b>", "<CMD>NvimTreeToggle<CR>", desc = "Toggle nvim-tree" } },
        config = function()
            require("nvim-tree").setup({
                sort = {
                    sorter = "modification_time"
                },
                filters = {
                    custom = {
                        "*.aux", "*.bcf", "*.fdb_latexmk",
                        "*.fls", "*.idx", "*.ilg", "*.log",
                        "*.out", "*.xml", "*.ind", "*.synctex",
                        "*.blg", "*.bbl"
                    }
                },
                actions = {
                    open_file = {
                        window_picker = {
                            enable = true,
                            picker = require("window-picker").pick_window
                        },
                        quit_on_open = true,
                    },
                }
            })
            -- Make :bd and :q behave as usual when tree is visible
            vim.api.nvim_create_autocmd({ 'BufEnter', 'QuitPre' }, {
                nested = false,
                callback = function(e)
                    local tree = require('nvim-tree.api').tree

                    if not tree.is_visible() then
                        return
                    end

                    local winCount = 0
                    for _, winId in ipairs(vim.api.nvim_list_wins()) do
                        if vim.api.nvim_win_get_config(winId).focusable then
                            winCount = winCount + 1
                        end
                    end

                    if e.event == 'QuitPre' and winCount == 2 then
                        vim.api.nvim_cmd({ cmd = 'qall' }, {})
                    end

                    if e.event == 'BufEnter' and winCount == 1 then
                        vim.defer_fn(function()
                            tree.toggle({ find_file = true, focus = true })
                            tree.toggle({ find_file = true, focus = false })
                        end, 10)
                    end
                end
            })
        end
    },
    {
        "nvim-telescope/telescope.nvim",
        cmd = "Telescope",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "debugloop/telescope-undo.nvim",
        },
        keys = {
            { "<leader>ff", "<cmd>Telescope find_files<cr>",   desc = "Find files(root dir)" },
            { "<leader>fg", "<cmd>Telescope live_grep<cr>",    desc = "Grep(root dir)" },
            { "<leader>fb", "<cmd>Telescope buffers<cr>",      desc = "Find buffer" },
            { "<leader>fh", "<cmd>Telescope help_tags<cr>",    desc = "Help tags" },
            { "<leader>fr", "<cmd>Telescope oldfiles<cr>",     desc = "Recent" },
            { "<leader>u",  "<cmd>Telescope undo<cr>",         desc = "Undo history", },
            { "<leader>gc", "<cmd>Telescope git_commits<CR>",  desc = "Git commits" },
            { "<leader>gb", "<cmd>Telescope git_branches<CR>", desc = "Git branch" },
            { "<leader>gs", "<cmd>Telescope git_status<CR>",   desc = "Git status" },
        },
        config = function()
            local actions = require("telescope.actions")
            local config = require("telescope.config")
            local action_layout = require("telescope.actions.layout")
            local vimgrep_arguments = { unpack(config.values.vimgrep_arguments) }
            require("telescope").setup({
                defaults = {
                    vimgrep_arguments = vimgrep_arguments,
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
                    }
                },
                extensions = {
                    undo = {},
                },
            })
            require("telescope").load_extension("undo")
        end
    },
    {
        "akinsho/toggleterm.nvim",
        event = "VeryLazy",
        config = function()
            require("toggleterm").setup {
                size = function(term)
                    if term.direction == "horizontal" then
                        return 10
                    elseif term.direction == "vertical" then
                        return vim.o.columns * 0.4
                    end
                end,
                open_mapping = [[<c-\>]],
                direction = "horizontal",
            }
        end
    },
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        ---@type Flash.Config
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
        config = function()
            require("flash").setup()
            vim.api.nvim_set_hl(0, "FlashLabel", { fg = "#000000", bg = "#FFFF00" })
            vim.api.nvim_set_hl(0, "FlashCursor", { underline = true })
        end
    },
    {
        "windwp/nvim-autopairs",
        event = { "bufreadpost", "bufwritepost", "bufnewfile" },
        config = require("plugins.specified.autopairs").config
    },
    {
        "kylechui/nvim-surround",
        version = "*",
        event = "BufRead",
        opts = {},
    },
    {
        'numToStr/Comment.nvim',
        optional = true,
        lazy = false,
        opts = {},
    },
    {
        "kevinhwang91/nvim-bqf",
        event = "VeryLazy",
    },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        init = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
        end,
        opts = {
            defaults = {
                ["<localLeader>l"] = { name = "+vimtex" },
            },
        }
    },
    {
        "folke/todo-comments.nvim",
        event = { "bufreadpost", "bufwritepost", "bufnewfile" },
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {}
    },
    {
        "hedyhli/outline.nvim",
        lazy = true,
        cmd = { "Outline", "OutlineOpen" },
        keys = {
            { "<leader>o", "<cmd>Outline<CR>", desc = "Toggle outline" },
        },
        opts = {},
    },
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
    { 'echasnovski/mini.comment', version = false, opts = {} },
    {
        "ThePrimeagen/harpoon",
        dependencies = { "nvim-lua/plenary.nvim" },
        branch = "harpoon2",
        opts = {
            menu = {
                width = vim.api.nvim_win_get_width(0) - 4,
            },
            settings = {
                save_on_toggle = true,
            },
        },
        keys = function()
            local keys = {
                {
                    "<leader>H",
                    function()
                        require("harpoon"):list():add()
                    end,
                    desc = "Harpoon File",
                },
                {
                    "<leader>h",
                    function()
                        local harpoon = require("harpoon")
                        harpoon.ui:toggle_quick_menu(harpoon:list())
                    end,
                    desc = "Harpoon Quick Menu",
                },
            }

            for i = 1, 5 do
                table.insert(keys, {
                    "<leader>" .. i,
                    function()
                        require("harpoon"):list():select(i)
                    end,
                    desc = "Harpoon to File " .. i,
                })
            end
            return keys
        end,
    }
}
