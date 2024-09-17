local ls = require("luasnip")
local ts_utils = require("nvim-treesitter.ts_utils")

local line_begin = require("luasnip.extras.conditions.expand").line_begin

local brackets = { -- recall that [b,p,v,B,V]matrix
    a = { "\\langle", "\\rangle" },
    b = { "[", "]" },
    p = { "(", ")" },
    v = { "\\lvert", "\\rvert" },
    B = { "\\lbrace", "\\rbrace" },
    V = { "\\lVert", "\\rVert" },
}

local notin_math = function ()
    local type = ts_utils.get_node_at_cursor():type()
    if string.find(type, "latex") then
        return false
    end
    return true
end

local autosnippet = ls.extend_decorator.apply(s, { snippetType = "autosnippet" })

local get_selected_text = function(_, snip)
    return snip.env.LS_SELECT_RAW
end

local M = {
    s({ trig = "date", desc = "Insert current date" },
    {t(vim.fn.strftime("%Y %b %d"))},
    {condition = line_begin}),
    autosnippet(
        { trig = "jj", dscr = "inline math" },
        fmta([[
        $<><>$
    ]], { f(get_selected_text, {}), i(0) }),
        { condition = notin_math }
    ),
    autosnippet(
        { trig = "kk", dscr = "display math" },
        fmta([[
        $$
          <>
        $$
        ]], { i(0) }),
        { condition = notin_math }
    ),
    autosnippet(
        { trig = "tt", dscr = "text in math" },
        fmta([[
        \text{<>}
        ]], { i(0) }),
        { condition = notin_math }
    ),
    autosnippet(
        {
            trig = "lr([abpvBV])",
            name = "left right",
            dscr = "left right delimiters",
            trigEngine = "pattern",
            hidden = true
        },
        fmta([[
    \left<> <><> \right<>
    ]],
            { f(function(_, snip)
                local cap = snip.captures[1]
                if brackets[cap] == nil then
                    cap = "p"
                end
                return brackets[cap][1]
            end),
                f(get_selected_text, {}),
                i(0),
                f(function(_, snip)
                    local cap = snip.captures[1]
                    if brackets[cap] == nil then
                        cap = "p"
                    end
                    return brackets[cap][2]
                end),
            }),
        { condition = notin_math, show_condition = notin_math }
    ),
}

return M
