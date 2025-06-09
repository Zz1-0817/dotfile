return {
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        dependencies = "nvim-tree/nvim-web-devicons",
        init = function()
            vim.g.lualine_laststatus = vim.o.laststatus
        end,
        config = function()
            local lualine = require('lualine')

            local colors = {
                bg       = '#202328',
                fg       = '#bbc2cf',
                yellow   = '#ECBE7B',
                cyan     = '#008080',
                darkblue = '#081633',
                green    = '#98be65',
                orange   = '#FF8800',
                violet   = '#a9a1e1',
                magenta  = '#c678dd',
                blue     = '#51afef',
                red      = '#ec5f67',
                purple   = '#a020f0',
                gray     = '#A9A9A9',
                portland_orange = "#FF5A36",
                lsp_blue = "#4A90E2"
            }

            local conditions = {
                buffer_not_empty = function()
                    return vim.fn.empty(vim.fn.expand('%:t')) ~= 1
                end,
                hide_in_width = function()
                    return vim.fn.winwidth(0) > 80
                end,
                check_git_workspace = function()
                    local filepath = vim.fn.expand('%:p:h')
                    local gitdir = vim.fn.finddir('.git', filepath .. ';')
                    return gitdir and #gitdir > 0 and #gitdir < #filepath
                end,
            }

            local separator_color = function()
                local mode_color = {
                    n = colors.blue,
                    i = colors.green,
                    v = colors.red,
                    V = colors.red,
                    [''] = colors.red,
                    c = colors.magenta,
                    no = colors.blue,
                    s = colors.orange,
                    S = colors.orange,
                    [''] = colors.orange,
                    ic = colors.yellow,
                    R = colors.violet,
                    Rv = colors.violet,
                    cv = colors.blue,
                    ce = colors.blue,
                    r = colors.cyan,
                    rm = colors.cyan,
                    ['r?'] = colors.cyan,
                    ['!'] = colors.blue,
                    t = colors.blue,
                }
                return { fg = mode_color[vim.fn.mode()] }
            end

            local config = {
                options = {
                    component_separators = '',
                    section_separators = '',
                    theme = "auto",
                },
                sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_y = {},
                    lualine_z = {},
                    lualine_c = {
                        {
                            function()
                                return utils.icons.statusline.separator
                            end,
                            padding = { left = 0, right = 1 },
                            color = separator_color
                        },
                        {
                            'filesize',
                            cond = conditions.buffer_not_empty,
                        },
                        { 'location' },
                        { 'progress' },
                        {
                            'diagnostics',
                            sources = { 'nvim_diagnostic' },
                            symbols = {
                                error = utils.icons.diagnostics.Error,
                                warn = utils.icons.diagnostics.Warn,
                                info = utils.icons.diagnostics.Info
                            },
                            diagnostics_color = {
                                color_error = { fg = colors.red },
                                color_warn = { fg = colors.yellow },
                                color_info = { fg = colors.cyan },
                            },
                        },
                        {
                            function()
                                return '%='
                            end,
                        },
                        {
                            'filename',
                            cond = conditions.buffer_not_empty,
                            color = { fg = colors.magenta, gui = 'bold' },
                        },

                    },
                    lualine_x = {
                        {
                            'o:encoding',       -- option component same as &encoding in viml
                            fmt = string.upper, -- I'm not sure why it's upper case either ;)
                            cond = conditions.hide_in_width,
                        },
                        {
                            'fileformat',
                            fmt = string.upper,
                            icons_enabled = false, -- I think icons are cool but Eviline doesn't have them. sigh
                        },
                        {
                            "lsp_status",
                            icon = utils.icons.statusline.server,
                            color = { fg = colors.lsp_blue, gui = "bold" }
                        },
                        {
                            'branch',
                            icon = utils.icons.git.branch,
                            color = { fg = colors.portland_orange, gui = 'bold' },
                        },
                        {
                            'diff',
                            symbols = {
                                added = utils.icons.git.added,
                                modified = utils.icons.git.modified,
                                removed = utils.icons.git.removed
                            },
                            diff_color = {
                                added = { fg = colors.green },
                                modified = { fg = colors.orange },
                                removed = { fg = colors.red },
                            },
                            cond = conditions.hide_in_width,
                        },
                        {
                            'filetype'
                        },
                        {
                            function()
                                return utils.icons.statusline.separator
                            end,
                            color = separator_color,
                            padding = { right = 0 }
                        }
                    },
                },
            }

            lualine.setup(config)
        end
    }
}
