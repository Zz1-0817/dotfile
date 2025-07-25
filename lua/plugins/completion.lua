return {
    {
        "L3MON4D3/LuaSnip",
        lazy = true,
        -- build = jit.os == "Windows" and
        --     "make install_jsregexp CC=gcc.exe SHELL=sh .SHELLFLAGS=-c"
        --     or "make install_jsregexp",
        config = function()
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
        end
    },
    {
        "hrsh7th/nvim-cmp",
        version = false,
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-omni",
            -- "micangl/cmp-vimtex",
            "saadparwaiz1/cmp_luasnip",
        },
        opts = function()
            local cmp = require("cmp")
            local ls = require("luasnip")
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
            return {
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
                        if ls.locally_jumpable(1) then
                            ls.jump(1)
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
                        elseif ls.choice_active() then
                            ls.change_choice(1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<C-p>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
                        elseif ls.choice_active() then
                            ls.change_choice(-1)
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
                        elseif ls.expandable() then
                            ls.expand()
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
                -- experimental = {
                --     ghost_text = { hl_group = "CmpGhostText", }
                -- }
            }
        end,
        config = function(_, opts)
            -- vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
            local cmp = require("cmp")
            cmp.setup(opts)
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
        end
    }
}
