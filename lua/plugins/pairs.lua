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
                return not utils.external.latex.in_math()
            end

            local md_not_in_math = function()
                return not utils.external.markdown.in_math()
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
            require('nvim-autopairs').remove_rule("{")

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
                Rule("$", "$", { "markdown" })
                    :with_pair(md_not_in_math)
                    :with_move(function(opts) return opts.char == '$' end)
                    :with_del(cond.done()),
                quote("'", "'", { "-rust", "-nix", "-tex", "-latex", "-python" }):with_pair(cond.not_before_regex("%w")),
                quote("'", "'", "python"):with_pair(function(opts)
                    local str = require('nvim-autopairs.utils').text_sub_char(opts.line, opts.col - 1, 1)
                    if str:match("[frbuFRBU]") then
                        return true
                    end
                end),
                quote("'", "'", "rust"):with_pair(cond.not_before_regex("[%w<&]")):with_pair(cond.not_after_text(">")),
                bracket("(", ")" ),
                -- Rule("(", ")", { "markdown" }):with_pair(cond.not_before_text('`')),
                bracket("{", "}", { "-markdown" }),
                Rule("{", "}", { "markdown" }),
                bracket("[", "]", { "-tex", "-latex", "-markdown" }),
                bracket("[", "]", { "tex", "latex" })
                    :with_pair(cond.not_before_regex('`')),
                Rule("[", "]", { "markdown" }):with_pair(cond.not_before_text('`')),
                quote("`", "`", { "-tex", "-latex", "-markdown" }),
                quote("`", "`", { "markdown" }):with_pair(md_not_in_math)
            }
        end
    },
    {
        "windwp/nvim-ts-autotag",
        ft = {
            "astro", "glimmer", "handlebars", "html",
            "javascript", "jsx", "php",
            "rescript", "svelte", "tsx", "twig",
            "typescript", "vue", "xml",
        },
        opts = {
            per_filetype = {
                ['markdown'] = {
                    enable_close = false,
                    enable_rename = false,
                    enable_close_on_slash = false
                }
            }
        }
    },
    {
        "kylechui/nvim-surround",
        version = "*",
        event = "BufRead",
        opts = {},
    }
}
