return {
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        opts = {
            disable_filetype = { "TelescopePrompt" },
            map_c_h = true,
            map_c_w = true,
            enable_bracket_in_quote = false,
            ignored_next_char = [=[[%w%%%'%[%"%.%`]]=],
        },
        config = function(_, options)
            local npairs = require("nvim-autopairs")
            local Rule = require("nvim-autopairs.rule")
            local cond = require("nvim-autopairs.conds")
            local basic_rule = require('nvim-autopairs.rules.basic')

            npairs.setup(options)
            require('nvim-autopairs').remove_rule("`")
            require('nvim-autopairs').remove_rule("'")
            require('nvim-autopairs').remove_rule("(")
            require('nvim-autopairs').remove_rule("[")
            require('nvim-autopairs').remove_rule("{")

            local quote = basic_rule.quote_creator(npairs.config)
            local bracket = basic_rule.bracket_creator(npairs.config)
            local spacing = {
                pairs = { "()", "[]", "{}", "$$" },
                dels = { "(  )", "[  ]", "{  }", "$  $" }
            }
            npairs.add_rules {
                Rule(' ', ' ')
                    :with_pair(function(opts)
                        local pair = opts.line:sub(opts.col - 1, opts.col)
                        return vim.tbl_contains(spacing.pairs, pair)
                    end)
                    :with_move(cond.none())
                    :with_cr(cond.none())
                    :with_del(function(opts)
                        local col = vim.api.nvim_win_get_cursor(0)[2]
                        local context = opts.line:sub(col - 1, col + 2)
                        return vim.tbl_contains(spacing.dels, context)
                    end),
                Rule("$", "$", { "tex", "latex", "markdown", "typst" })
                    :with_pair(function()
                        return not utils.markup.in_math()
                    end)
                    :with_move(function(opts) return opts.char == '$' end)
                    :with_del(cond.done()),
                -- Rule("$", "$", { "typst" })
                --     :with_move(function(opts) return opts.char == '$' end)
                --     :with_del(cond.done()),
                quote("'", "'", { "-rust", "-nix", "-tex", "-latex", "-python" }):with_pair(cond.not_before_regex("%w")),
                quote("'", "'", "python"):with_pair(function(opts)
                    local str = require('nvim-autopairs.utils').text_sub_char(opts.line, opts.col - 1, 1)
                    if str:match("[frbuFRBU]") then
                        return true
                    end
                end),
                quote("'", "'", "rust"):with_pair(cond.not_before_regex("[%w<&]")):with_pair(cond.not_after_text(">")),
                bracket("(", ")"),
                -- Rule("(", ")", { "markdown" }):with_pair(cond.not_before_text('`')),
                bracket("{", "}", { "-markdown" }),
                Rule("{", "}", { "markdown" }),
                bracket("[", "]", { "-tex", "-latex", "-markdown" }),
                bracket("[", "]", { "tex", "latex" })
                    :with_pair(cond.not_before_regex('`')),
                Rule("[", "]", { "markdown" }):with_pair(cond.not_before_text('`')),
                quote("`", "`", { "-tex", "-latex", "-markdown" }),
                quote("`", "`", { "markdown" }):with_pair(function ()
                    return not utils.markup.in_math()
                end)
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
