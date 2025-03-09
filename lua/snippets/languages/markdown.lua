local c = require("luasnip").choice_node
local s = require("luasnip").snippet
local f = require("luasnip").function_node
local i = require("luasnip").insert_node
local fmta = require("luasnip.extras.fmt").fmta
local notin_math = function()
    return not utils.external.markdown.in_math()
end
local M = {
    s({ trig = "jj", dscr = "inline math", snippetType = "autosnippet" },
        fmta([[
        $<><>$
    ]], { f(function(_, snip)
        return snip.env.LS_SELECT_RAW
    end), i(0) }),
        { condition = notin_math }),
    s({ trig = "kk", dscr = "display math", snippetType = "autosnippet" },
        fmta([[
        $$
          <>
        $$
        ]], { i(0) }),
        { condition = notin_math }
    ),
    s({ trig = "tt", dscr = "text in math" },
        fmta([[
        \text{<>}
        ]], { i(0) }),
        { condition = utils.external.markdown.in_math }
    ),
    s({ trig = "ff", dscr = "fractional" },
        c(1, {
            fmta([[
            \frac{<>}{<>}
            ]], { i(1), i(2) }),
            fmta([[
            \frac{\partial <>}{\partial <>}
            ]], { i(1), i(2) })
        }),
        { condition = utils.external.markdown.in_math }
    )
}

vim.list_extend(M, require("snippets.latex").load({ in_math = utils.external.markdown.in_math }))
-- vim.list_extend(M, require("snippets.latex").load())

return M
