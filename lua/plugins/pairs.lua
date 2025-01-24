return {
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        opts = {
            disable_filetype = { "TelescopePrompt" },
            map_c_h = true,
            map_c_w = true,
            enable_bracket_in_quote = false,
        },
        config = function(_, options)
            local tex_not_in_math = function()
                if vim.fn['vimtex#syntax#in_mathzone']() == 1 then
                    return false
                end
            end

            local npairs = require("nvim-autopairs")
            local Rule = require("nvim-autopairs.rule")
            local cond = require("nvim-autopairs.conds")
            local basic_rule = require('nvim-autopairs.rules.basic')

            local brackets = {
                { '(', ')' },
                { '[', ']' },
                { '{', '}' },
            }

            npairs.setup(options)

            local quote = basic_rule.quote_creator(npairs.config)
            local bracket = basic_rule.bracket_creator(npairs.config)

            require('nvim-autopairs').remove_rule("`")
            require('nvim-autopairs').remove_rule("'")
            require('nvim-autopairs').remove_rule("(")
            require('nvim-autopairs').remove_rule("[")

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
                    end),
                Rule("$", "$", { "tex", "latex" })
                    :with_pair(tex_not_in_math)
                    :with_move(function(opts) return opts.char == '$' end)
                    :with_del(cond.done()),
                quote("'", "'", { "-rust", "-nix", "-tex", "-latex" })
                    :with_pair(function(opts)
                        -- python literals string
                        local str = require('nvim-autopairs.utils').text_sub_char(opts.line, opts.col - 1, 1)
                        if vim.bo.filetype == 'python' and str:match("[frbuFRBU]") then
                            return true
                        end
                    end),
                quote("'", "'", "rust"):with_pair(cond.not_before_regex("[%w<&]")):with_pair(cond.not_after_text(">")),
                bracket("(", ")", { "-tex", "-latex" }),
                bracket("(", ")", { "tex", "latex" })
                    :with_pair(tex_not_in_math),
                bracket("[", "]", { "-tex", "-latex" }),
                bracket("[", "]", { "tex", "latex" })
                    :with_pair(tex_not_in_math),
                quote("`", "`", { "-tex", "-latex" })
            }
        end
    },
    {
        "windwp/nvim-ts-autotag",
        ft = {
            "astro", "glimmer", "handlebars", "html",
            "javascript", "jsx", "markdown", "php",
            "rescript", "svelte", "tsx", "twig",
            "typescript", "vue", "xml",
        },
        opts = {}
    },
    {
        "kylechui/nvim-surround",
        version = "*",
        event = "BufRead",
        opts = {},
    }
}
