return {
    {
        "windwp/nvim-autopairs",
        event = { "bufreadpost", "bufwritepost", "bufnewfile" },
        config = function()
            local npairs = require("nvim-autopairs")
            local Rule = require("nvim-autopairs.rule")
            local cond = require("nvim-autopairs.conds")
            local brackets = {
                { '(', ')' },
                { '[', ']' },
                { '{', '}' },
            }
            npairs.setup({
                disable_filetype = { "TelescopePrompt" },
                enable_moveright = false,
                map_c_h = true,
                map_c_w = true,
                map_cr = true,
            })
            npairs.add_rules {
                Rule(' ', ' ')
                    :with_pair(function(opts)
                        local pair = opts.line:sub(opts.col - 1, opts.col)
                        return vim.tbl_contains({
                            brackets[1][1] .. brackets[1][2],
                            brackets[2][1] .. brackets[2][2],
                            brackets[3][1] .. brackets[3][2],
                        }, pair)
                    end)
                    :with_move(cond.none())
                    :with_cr(cond.none())
                    :with_del(function(opts)
                        local col = vim.api.nvim_win_get_cursor(0)[2]
                        local context = opts.line:sub(col - 1, col + 2)
                        return vim.tbl_contains({
                            brackets[1][1] .. '  ' .. brackets[1][2],
                            brackets[2][1] .. '  ' .. brackets[2][2],
                            brackets[3][1] .. '  ' .. brackets[3][2]
                        }, context)
                    end)
            }


            npairs.add_rules {
                Rule('<', '>')
                    :with_pair(cond.none())
                    :with_move(function(opts) return opts.char == '>' end)
                    :with_cr(cond.none())
                    :with_del(cond.none())
                    :use_key('>')
            }

            npairs.add_rules({
                    Rule("$", "$", { "tex", "latex" })
                        :with_pair(function(opts)
                            print(vim.inspect(opts))
                            if opts.line == "aa $$" then
                                -- don't add pair on that line
                                return false
                            end
                        end)
                        :with_move(function(opts) return opts.char == '$' end) -- no work, since disable rightmove
                        :with_del(cond.not_after_regex("xx"))
                        :with_cr(cond.none())
                },
                Rule("a", "a", "-vim")
            )

            npairs.get_rule("'")[1].not_filetypes = { "tex", "latex" }
            npairs.get_rule('"')[1].not_filetypes = { "tex", "latex" }
            npairs.get_rule('[').not_filetypes = { "tex", "latex" }
            npairs.get_rule('`').not_filetypes = { "tex", "latex", "markdown" }
        end
    },
    {
        "kylechui/nvim-surround",
        version = "*",
        event = "BufRead",
        opts = {},
    }
}
