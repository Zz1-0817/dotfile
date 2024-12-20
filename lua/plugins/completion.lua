local has_words_before = function()
    unpack = unpack or table.unpack
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and
        vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end
return {
    {
        "L3MON4D3/LuaSnip",
        version = "2.*",
        -- build = "make install_jsregexp",
        build =
            vim.g.os == "Windows" and
            "make install_jsregexp CC=gcc.exe SHELL=sh .SHELLFLAGS=-c NEOVIM_BIN_PATH=C:/Users/Zz1/scoop/apps/neovim-nightly/current/bin"
            or "make install_jsregexp",
        keys = {},
        opts = {
            store_selection_keys = "<Tab>",
            enable_autosnippets = true
        },
        config = function(_, opts)
            local ls = require("luasnip")
            ls.setup(opts)
            local snippets_path = vim.fn.stdpath('config') .. [[\lua\snippets]]
            require("luasnip.loaders.from_lua").load({ paths = { snippets_path } })
            --https://github.com/L3MON4D3/LuaSnip/issues/656
            vim.api.nvim_create_autocmd("ModeChanged", {
                group = vim.api.nvim_create_augroup("UnlinkLuaSnipSnippetOnModeChange", {
                    clear = true,
                }),
                pattern = { "s:n", "i:*" },
                desc = "Forget the current snippet when leaving the insert mode",
                callback = function(evt)
                    while true do
                        if ls.session and ls.session.current_nodes[evt.buf] and not ls.session.jump_active then
                            ls.unlink_current()
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
            "micangl/cmp-vimtex",
            "saadparwaiz1/cmp_luasnip",
            "L3MON4D3/LuaSnip",
        },
        opts = function()
            local cmp = require("cmp")
            local ls = require("luasnip")
            local compare = require("cmp.config.compare")
            return {
                performance = {
                    debounce = 100,
                    throttle = 50,
                },
                completion = {
                    completeopt = "menu, menuone, noinsert",
                },
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },
                formatting = {
                    format = function(entry, vim_item)
                        vim_item.kind = string.format('%s %s', utils.icons.kinds[vim_item.kind], vim_item.kind)
                        vim_item.menu = ({
                            vimtex = "[Vimtex]",
                            buffer = "[Buffer]",
                            luasnip = "[LuaSnip]",
                            nvim_lsp = "[LSP]",
                            nvim_lua = "[Lua]",
                            latex_symbols = "[LaTeX]",
                        })[entry.source.name]
                        return vim_item
                    end,
                    fields = { 'kind', 'abbr', 'menu' },
                },
                sorting = {
                    comparators = {
                        compare.sort_text,
                        compare.offset,
                        compare.exact,
                        compare.score,
                        compare.recently_used,
                        compare.kind,
                        compare.length,
                        compare.order,
                    }
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ['<C-e>'] = cmp.mapping(function(fallback)
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
                        elseif ls.locally_jumpable(1) then
                            ls.jump(1)
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
                    { name = "path" },
                    {
                        name = "lazydev",
                        group_index = 0,
                    }
                },
                experimental = {
                    ghost_text = {
                        hl_group = "CmpGhostText",
                    }
                }
            }
        end,
        config = function(_, opts)
            vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
            local cmp = require("cmp")
            cmp.setup(opts)
            cmp.setup.filetype({ "tex", "bib", "sty", "cls" }, {
                sources = {
                    {
                        name = "vimtex",
                        entry_filter = function()
                            local ls = require("luasnip")
                            return not ls.choice_active()
                        end
                    },
                    { name = "luasnip",  keyword_length = 2 },
                    { name = "nvim_lsp", keyword_length = 2 },
                    {
                        name = "buffer",
                        option = {
                            keyword_pattern = [[[a-zA-Z0-9]\+]]
                        },
                        keyword_length = 4
                    },
                }
            })
            cmp.setup.filetype("markdown", {
                sources = {
                    { name = "luasnip" },
                    { name = "nvim_lsp" },
                    { name = "buffer" },
                    { name = "obsidian.nvim" }
                }
            })
        end
    }
}
