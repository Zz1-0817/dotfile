return {
    {
        'stevearc/oil.nvim',
        config = function()
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
