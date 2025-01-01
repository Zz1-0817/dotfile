return {
    {
        "Bekaboo/dropbar.nvim",
        event = "VeryLazy",
        keys = {
            {
                "<leader>wp",
                function()
                    require("dropbar.api").pick()
                end,
                desc = "Winbar pick",
            },
        },
        opts = function()
            -- https://github.com/Bekaboo/dropbar.nvim/discussions/132
            local menu_utils = require "dropbar.utils.menu"

            local function close()
                local menu = menu_utils.get_current()
                while menu and menu.prev_menu do
                    menu = menu.prev_menu
                end
                if menu then
                    menu:close()
                end
            end

            return {
                bar = {
                    attach_events = { "BufWinEnter", "BufWritePost" },
                    update_events = {
                        win = { "CursorMoved", "CursorMovedI", "WinResized" },
                    },
                    pick = {
                        pivots = "asdfghjklqwertyuiopzxcvbnm",
                    },
                    sources = function()
                        local sources = require "dropbar.sources"
                        local utils = require "dropbar.utils.source"
                        return {
                            {
                                get_symbols = function(buf, win, cursor)
                                    if vim.api.nvim_get_current_win() ~= win then
                                        return {}
                                    end

                                    if vim.bo[buf].ft == "markdown" then
                                        return sources.markdown.get_symbols(buf, win, cursor)
                                    end
                                    return utils.fallback({ sources.lsp, sources.treesitter }).get_symbols(buf, win,
                                        cursor)
                                end,
                            },
                        }
                    end,
                },
                menu = {
                    keymaps = {
                        ["h"] = "<C-w>c",
                        ["l"] = function()
                            local menu = menu_utils.get_current()
                            if not menu then
                                return
                            end
                            local row = vim.api.nvim_win_get_cursor(menu.win)[1]
                            local component = menu.entries[row]:first_clickable()
                            if component then
                                menu:click_on(component, nil, 1, "l")
                            end
                        end,
                        ["o"] = function()
                            local menu = menu_utils.get_current()
                            if not menu then
                                return
                            end
                            local cursor = vim.api.nvim_win_get_cursor(menu.win)
                            local entry = menu.entries[cursor[1]]
                            local component = entry:first_clickable(entry.padding.left + entry.components[1]:bytewidth())
                            if component then
                                menu:click_on(component, nil, 1, "l")
                            end
                        end,
                        ["q"] = close,
                        ["<esc>"] = close,
                    },
                },
            }
        end,
        config = function(_, opts)
            local bar_utils = require "dropbar.utils.bar"

            require("dropbar").setup(opts)

            -- Better way to do this? Follow up in https://github.com/Bekaboo/dropbar.nvim/issues/76
            vim.api.nvim_create_autocmd("WinEnter", {
                desc = "Refresh window dropbars",
                callback = function()
                    -- Exclude the dropbar itself.
                    if vim.fn.getwininfo(vim.api.nvim_get_current_win())[1].winbar == 1 then
                        bar_utils.exec "update"
                    end
                end,
            })
        end,
    }
}
