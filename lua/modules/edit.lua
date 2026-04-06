return {
    load_basic = function()
        vim.pack.add({
            { src = "https://github.com/romainl/vim-cool" },
            { src = "https://github.com/lukas-reineke/indent-blankline.nvim" },
            { src = "https://github.com/echasnovski/mini.bufremove" },
            { src = "https://github.com/keaising/im-select.nvim" }
        })
        require("ibl").setup()
        require("mini.bufremove").setup()
        require("im_select").setup({
            set_default_events = { "InsertLeave" },
        })
        vim.keymap.set("n", "<leader>bd", function()
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
        end, { desc = "Delete buffer", noremap = true, silent = true })
    end,
    load_completion = function()
        vim.pack.add({
            { src = "https://github.com/hrsh7th/nvim-cmp" },
            { src = "https://github.com/hrsh7th/cmp-nvim-lsp" },
            { src = "https://github.com/hrsh7th/cmp-buffer" },
            { src = "https://github.com/hrsh7th/cmp-path" },
            { src = "https://github.com/hrsh7th/cmp-cmdline" },
            { src = "https://github.com/hrsh7th/cmp-omni" },
            { src = "https://github.com/saadparwaiz1/cmp_luasnip" },
            { src = "https://github.com/L3MON4D3/LuaSnip" },
        })
        local cmp = require("cmp")
        local luasnip = require("luasnip")
        luasnip.setup({
            store_selection_keys = "<Tab>",
            enable_autosnippets = true,
        })

        luasnip.add_snippets("tex", require("snippets.tex"))
        luasnip.add_snippets("markdown", require("snippets.markdown"))
        luasnip.add_snippets("typst", require("snippets.typst"))
        luasnip.add_snippets("cpp", require("snippets.cpp"))
        -- https://github.com/L3MON4D3/LuaSnip/issues/656
        vim.api.nvim_create_autocmd("ModeChanged", {
            group = vim.api.nvim_create_augroup("UnlinkLuaSnipSnippetOnModeChange", {
                clear = true,
            }),
            pattern = { "s:n", "i:*" },
            desc = "Forget the current snippet when leaving the insert mode",
            callback = function(evt)
                -- If we have n active nodes, n - 1 will still remain after a `unlink_current()` call.
                -- We unlink all of them by wrapping the calls in a loop.
                while true do
                    if luasnip.session and luasnip.session.current_nodes[evt.buf] and not luasnip.session.jump_active then
                        luasnip.unlink_current()
                    else
                        break
                    end
                end
            end,
        })
        local kind_icons = {
            Text = "",
            Method = "󰆧",
            Function = "󰊕",
            Constructor = "",
            Field = "󰇽",
            Variable = "󰂡",
            Class = "󰠱",
            Interface = "",
            Module = "",
            Property = "󰜢",
            Unit = "",
            Value = "󰎠",
            Enum = "",
            Keyword = "󰌋",
            Snippet = "",
            Color = "󰏘",
            File = "󰈙",
            Reference = "",
            Folder = "󰉋",
            EnumMember = "",
            Constant = "󰏿",
            Struct = "",
            Event = "",
            Operator = "󰆕",
            TypeParameter = "󰅲",
        }
        local has_words_before = function()
            unpack = unpack or table.unpack
            local line, col = unpack(vim.api.nvim_win_get_cursor(0))
            return col ~= 0 and
                vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
        end
        cmp.setup({
            snippet = {
                expand = function(args)
                    require("luasnip").lsp_expand(args.body)
                end,
            },
            formatting = {
                format = function(entry, vim_item)
                    vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind)
                    vim_item.menu = ({
                        omni = (vim.inspect(vim_item.menu):gsub('%"', "")),
                        vimtex = "[Vimtex]",
                        buffer = "[Buffer]",
                        lazydev = "[Lazydev]",
                        path = "[Path]",
                        luasnip = "[LuaSnip]",
                        nvim_lsp = "[LSP]",
                        nvim_lua = "[Lua]",
                        latex_symbols = "[LaTeX]",
                    })[entry.source.name]
                    return vim_item
                end,
                fields = { 'kind', 'abbr', 'menu' },
            },
            mapping = cmp.mapping.preset.insert({
                ["<C-u>"] = cmp.mapping(function(fallback)
                    if cmp.visible_docs() then
                        cmp.scroll_docs(-4)
                    else
                        fallback()
                    end
                end),
                ["<C-d>"] = cmp.mapping(function(fallback)
                    if cmp.visible_docs() then
                        cmp.scroll_docs(4)
                    else
                        fallback()
                    end
                end),
                ["<C-j>"] = cmp.mapping(function(fallback)
                    if luasnip.locally_jumpable(1) then
                        luasnip.jump(1)
                    else
                        fallback()
                    end
                end),
                ['<C-e>'] = cmp.mapping(function(fallback)
                    fallback()
                end),
                ['<C-y>'] = cmp.mapping(function(fallback)
                    fallback()
                end),
                ["<C-n>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
                    elseif luasnip.choice_active() then
                        luasnip.change_choice(1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),
                ["<C-p>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
                    elseif luasnip.choice_active() then
                        luasnip.change_choice(-1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),
                ["<C-q>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.abort()
                    else
                        fallback()
                    end
                end),
                ["<Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.confirm({ select = true })
                    elseif luasnip.expandable() then
                        luasnip.expand()
                    elseif has_words_before() then
                        cmp.complete()
                    else
                        fallback()
                    end
                end, { "i", "s" }),
            }),
            sources = {
                { name = "nvim_lsp" },
                { name = "luasnip" },
                { name = "buffer" },
                -- { name = "path" },
            },
        })
        cmp.setup.filetype({ "tex", "bib", "sty", "cls" }, {
            sources = {
                { name = "omni",    trigger_characters = { "{", "\\" } },
                { name = "luasnip", keyword_length = 2 },
            }
        })
        cmp.setup.filetype("markdown", {
            sources = {
                { name = "luasnip" },
                { name = "nvim_lsp" },
                {
                    name = "buffer",
                    option = {
                        keyword_pattern = [[[a-zA-Z0-9]\+]]
                    },
                    keyword_length = 4
                },
            }
        })
        cmp.setup.filetype("typst", {
            sources = {
                { name = "nvim_lsp" },
                { name = "luasnip" },
                { name = "buffer" },
            }
        })
        cmp.setup.filetype("lua", {
            sources = {
                { name = "lazydev" },
                { name = "luasnip" },
                { name = "nvim_lsp" },
                { name = "buffer" },
            }
        })
        cmp.setup.cmdline({ '/', '?' }, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
                { name = 'buffer' }
            }
        })
        cmp.setup.cmdline(':', {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
                { name = 'path' }
            }, {
                { name = 'cmdline' }
            }),
        })

        require("nvim-ts-autotag").setup({
            per_filetype = {
                ['markdown'] = {
                    enable_close = false,
                    enable_rename = false,
                    enable_close_on_slash = false
                }
            }
        })
    end,
    load_pair = function()
        vim.pack.add({
            { src = "https://github.com/windwp/nvim-autopairs" },
            { src = "https://github.com/windwp/nvim-ts-autotag" },
            { src = "https://github.com/kylechui/nvim-surround" }
        })
        local npairs = require("nvim-autopairs")
        local Rule = require("nvim-autopairs.rule")
        local cond = require("nvim-autopairs.conds")
        local basic_rule = require('nvim-autopairs.rules.basic')
        npairs.setup({
            fast_wrap = {},
            disable_filetype = { "TelescopePrompt" },
            map_c_h = true,
            map_c_w = true,
            enable_bracket_in_quote = false,
            ignored_next_char = [=[[%w%%%'%[%"%.%`]]=],
        })
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
                :with_pair(function(_)
                    return not utils.markup.in_math()
                end)
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
            bracket("(", ")"),
            -- Rule("(", ")", { "markdown" }):with_pair(cond.not_before_text('`')),
            bracket("{", "}", { "-markdown" }),
            Rule("{", "}", { "markdown" }),
            bracket("[", "]", { "-tex", "-latex", "-markdown" }),
            bracket("[", "]", { "tex", "latex" })
                :with_pair(cond.not_before_regex('`')),
            Rule("[", "]", { "markdown" }):with_pair(cond.not_before_text('`')),
            quote("`", "`", { "-tex", "-latex", "-markdown" }),
            quote("`", "`", { "markdown" }):with_pair(function()
                return not utils.markup.in_math()
            end)
        }
        require("nvim-ts-autotag").setup({
            per_filetype = {
                ['markdown'] = {
                    enable_close = false,
                    enable_rename = false,
                    enable_close_on_slash = false
                }
            }
        })
    end
}
