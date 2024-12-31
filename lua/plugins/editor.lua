return {
    {
        'stevearc/oil.nvim',
        ---@module 'oil'
        ---@type oil.SetupOpts
        opts = {},
        config = function(opts)
            -- https://github.com/stevearc/oil.nvim/blob/master/doc/recipes.md#hide-gitignored-files-and-show-git-tracked-hidden-files
            local function parse_output(proc)
                local result = proc:wait()
                local ret = {}
                if result.code == 0 then
                    for line in vim.gsplit(result.stdout, "\n", { plain = true, trimempty = true }) do
                        line = line:gsub("/$", "")
                        ret[line] = true
                    end
                end
                return ret
            end

            local function new_git_status()
                return setmetatable({}, {
                    __index = function(self, key)
                        local ignore_proc = vim.system(
                            { "git", "ls-files", "--ignored", "--exclude-standard", "--others", "--directory" },
                            {
                                cwd = key,
                                text = true,
                            }
                        )
                        local tracked_proc = vim.system({ "git", "ls-tree", "HEAD", "--name-only" }, {
                            cwd = key,
                            text = true,
                        })
                        local ret = {
                            ignored = parse_output(ignore_proc),
                            tracked = parse_output(tracked_proc),
                        }

                        rawset(self, key, ret)
                        return ret
                    end,
                })
            end
            local git_status = new_git_status()

            local refresh = require("oil.actions").refresh
            local orig_refresh = refresh.callback
            refresh.callback = function(...)
                git_status = new_git_status()
                orig_refresh(...)
            end
            require("oil").setup({
                keymaps = {
                    ["q"] = { "actions.close", mode = "n" },
                },
                view_options = {
                    is_hidden_file = function(name, bufnr)
                        local dir = require("oil").get_current_dir(bufnr)
                        local is_dotfile = vim.startswith(name, ".") and name ~= ".."
                        if not dir then
                            return is_dotfile
                        end
                        if is_dotfile then
                            return not git_status[dir].tracked[name]
                        else
                            return git_status[dir].ignored[name]
                        end
                    end,
                },
            })
        end,
        dependencies = { { "echasnovski/mini.icons", opts = {} } },
        keys = { { "-", "<CMD>Oil<CR>", mode = { "n" }, desc = "Open parent directory" } }
    },
    {
        "nvim-telescope/telescope.nvim",
        cmd = "Telescope",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "debugloop/telescope-undo.nvim",
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
                    },
                    preview = {
                        treesitter = false
                    }
                },
            })
            require("telescope").load_extension("undo")
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
        opts = {
            highlight = {
                groups = {
                    label = "Cursor"
                }
            }
        }
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
    -- {
    --     'stevearc/quicker.nvim',
    --     event = "FileType qf",
    --     opts = {}
    -- },
    {
        "kevinhwang91/nvim-bqf",
        ft = "qf",
        config = function()
            local config = require('bqf.config')
            config['preview']['border'] = 'shadow'
            config['preview']['how_scroll_bar'] = false
            require("bqf").setup(config)
        end
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
    {
        'echasnovski/mini.comment',
        event = { "bufreadpost", "bufwritepost", "bufnewfile" },
        version = false,
        opts = {}
    },
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
    },
}
