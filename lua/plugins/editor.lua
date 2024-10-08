return {
    {
        "nvim-tree/nvim-tree.lua",
        --version = "*",
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
                            filetype = { "fidget", "NvimTree", "screenkey" },
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
            local function change_root_to_global_cwd()
                local api = require("nvim-tree.api")
                local global_cwd = vim.fn.getcwd()
                api.tree.change_root(global_cwd)
            end

            local function on_attach(bufnr)
                local api = require "nvim-tree.api"

                local function opts(desc)
                    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
                end

                api.config.mappings.default_on_attach(bufnr)

                vim.keymap.set('n', '<C-c>', change_root_to_global_cwd, opts('Change Root To Global CWD'))
            end

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
                },
                on_attach = on_attach
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
            "nvim-telescope/telescope-file-browser.nvim",
            "nvim-telescope/telescope-project.nvim"
        },
        keys = {
            { "<leader>ff", "<cmd>Telescope find_files<cr>",   desc = "Find files(root dir)" },
            { "<leader>fb", "<cmd>Telescope file_browser<CR>", desc = "File browser" },
            { "<leader>fg", "<cmd>Telescope live_grep<cr>",    desc = "Grep(root dir)" },
            { "<leader>fh", "<cmd>Telescope help_tags<cr>",    desc = "Help tags" },
            { "<leader>fr", "<cmd>Telescope oldfiles<cr>",     desc = "Recent" },
            { "<leader>fp", "<cmd>Telescope project<cr>",      desc = "Project" },
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
                    }
                },
            })
            require("telescope").load_extension("undo")
            require("telescope").load_extension("file_browser")
            require("telescope").load_extension('project')
        end
    },
    {
        "akinsho/toggleterm.nvim",
        event = "VeryLazy",
        init = function()
            local powershell_options = {
                shell = vim.fn.executable "pwsh" == 1 and "pwsh" or "powershell",
                shellcmdflag =
                "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;",
                shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait",
                shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode",
                shellquote = "",
                shellxquote = "",
            }

            for option, value in pairs(powershell_options) do
                vim.opt[option] = value
            end
        end,
        opts = {
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
    },
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
        config = function()
            require("flash").setup()
            vim.api.nvim_set_hl(0, "FlashLabel", { fg = "#000000", bg = "#FFFF00" })
            vim.api.nvim_set_hl(0, "FlashCursor", { underline = true })
        end
    },
    {
        "windwp/nvim-autopairs",
        event = { "bufreadpost", "bufwritepost", "bufnewfile" },
        config = function()
            require("plugins.specified.autopairs")
        end
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
        'stevearc/quicker.nvim',
        event = "FileType qf",
        opts = {}
    },
    -- {
    --     "kevinhwang91/nvim-bqf",
    --     event = "VeryLazy",
    -- },
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
    },
    {
        "gbprod/yanky.nvim",
        opts = {},
        keys = {
            { "y",  "<Plug>(YankyYank)",                      mode = { "n", "x" },                           desc = "Yank Text" },
            { "p",  "<Plug>(YankyPutAfter)",                  mode = { "n", "x" },                           desc = "Put Text After Cursor" },
            { "P",  "<Plug>(YankyPutBefore)",                 mode = { "n", "x" },                           desc = "Put Text Before Cursor" },
            { "gp", "<Plug>(YankyGPutAfter)",                 mode = { "n", "x" },                           desc = "Put Text After Selection" },
            { "gP", "<Plug>(YankyGPutBefore)",                mode = { "n", "x" },                           desc = "Put Text Before Selection" },
            { "[y", "<Plug>(YankyCycleForward)",              desc = "Cycle Forward Through Yank History" },
            { "]y", "<Plug>(YankyCycleBackward)",             desc = "Cycle Backward Through Yank History" },
            { "]p", "<Plug>(YankyPutIndentAfterLinewise)",    desc = "Put Indented After Cursor (Linewise)" },
            { "[p", "<Plug>(YankyPutIndentBeforeLinewise)",   desc = "Put Indented Before Cursor (Linewise)" },
            { "]P", "<Plug>(YankyPutIndentAfterLinewise)",    desc = "Put Indented After Cursor (Linewise)" },
            { "[P", "<Plug>(YankyPutIndentBeforeLinewise)",   desc = "Put Indented Before Cursor (Linewise)" },
            { ">p", "<Plug>(YankyPutIndentAfterShiftRight)",  desc = "Put and Indent Right" },
            { "<p", "<Plug>(YankyPutIndentAfterShiftLeft)",   desc = "Put and Indent Left" },
            { ">P", "<Plug>(YankyPutIndentBeforeShiftRight)", desc = "Put Before and Indent Right" },
            { "<P", "<Plug>(YankyPutIndentBeforeShiftLeft)",  desc = "Put Before and Indent Left" },
            { "=p", "<Plug>(YankyPutAfterFilter)",            desc = "Put After Applying a Filter" },
            { "=P", "<Plug>(YankyPutBeforeFilter)",           desc = "Put Before Applying a Filter" },
        }
    }
}
