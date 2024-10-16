local ls = require("luasnip")
local ts_utils = require("nvim-treesitter.ts_utils")
local scaffolding = require("snippets.tex.utils.scaffolding")

local line_begin = require("luasnip.extras.conditions.expand").line_begin


local brackets = { -- recall that [b,p,v,B,V]matrix
    a = { "\\langle", "\\rangle" },
    b = { "[", "]" },
    p = { "(", ")" },
    v = { "\\lvert", "\\rvert" },
    B = { "\\lbrace", "\\rbrace" },
    V = { "\\lVert", "\\rVert" },
}

local in_math = function ()
    local col = vim.fn.col('.')
    local row = vim.fn.line('.')
    local line_cnt = vim.api.nvim_buf_line_count(0)
    local ch = vim.fn.getline('.'):sub(col, col)
    if ch == '$' then
        return true
    end
    if row ~= 1 and row ~= line_cnt then
        local last_line = vim.fn.getline(row - 1)
        local next_line = vim.fn.getline(row + 1)
        if string.find(last_line, "$$", 0, true) and string.find(next_line, "$$", 0, true) then
            return true
        end
    end
    local type = ts_utils.get_node_at_cursor():type()
    if string.find(type, "latex") then
        return true
    end
    return false
end

local notin_math = function()
     return not in_math()
end

local autosnippet = ls.extend_decorator.apply(s, { snippetType = "autosnippet" })

local get_selected_text = function(_, snip)
    return snip.env.LS_SELECT_RAW
end

local M = {
    s({ trig = "date", desc = "Insert current date" },
        { t(vim.fn.strftime("%Y %b %d")) },
        { condition = line_begin }),
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
        { condition = in_math }
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
    \left<><><>\right<>
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
        { condition = in_math, show_condition = in_math }
    ),
}

local auto_backslash_specs = {
    "pi",
    "nu",
    "xi",
    "mu",
    "cap",
    "cup",
    "neq",
    "leq",
    "geq",
    "sum",
    "prod",
    "int",
    "dif",
    "notin",
    "to",
    "mid",
    "iff",
    "quad",
    "arcsin",
    "sin",
    "arccos",
    "cos",
    "arctan",
    "tan",
    "cot",
    "csc",
    "sec",
    "log",
    "ln",
    "exp",
    "ast",
    "star",
    "perp",
    "sup",
    "inf",
    "det",
    "max",
    "min",
    "argmax",
    "argmin",
    "deg",
    "angle",
}
local auto_backslash_snippets = {}
for _, v in pairs(auto_backslash_specs) do
    table.insert(
        auto_backslash_snippets,
        scaffolding.auto_backslash_snippet({ trig = v },
            { condition = in_math }
        )
    )
end
vim.list_extend(M, auto_backslash_snippets)

local symbol_specs = {
    ve = { context = { name = "ε" }, command = [[\varepsilon]] },
    vp = { context = { name = "φ" }, command = [[\varphi]] },
    ph = { context = { name = "φ" }, command = [[\phi]] },
    ps = { context = { name = "Ψ" }, command = [[\psi]] },
    inn = { context = { name = "∈" }, command = [[\in]] },
    xx = { context = { name = "×" }, command = [[\times]] },
    NN = { context = { name = "ℕ" }, command = [[\mathbb{N}]] },
    ZZ = { context = { name = "ℤ" }, command = [[\mathbb{Z}]] },
    QQ = { context = { name = "ℚ" }, command = [[\mathbb{Q}]] },
    RR = { context = { name = "ℝ" }, command = [[\mathbb{R}]] },
    CC = { context = { name = "ℂ" }, command = [[\mathbb{C}]] },
    AA = { context = { name = "∀" }, command = [[\forall]] },
    EE = { context = { name = "∃" }, command = [[\exists]] },
    bcap = { context = { name = "∩" }, command = [[\bigcap]] },
    bcup = { context = { name = "∪" }, command = [[\bigcup]] },
    ["+-"] = { context = { name = "±" }, command = [[\pm]] },
    ["-+"] = { context = { name = "∓" }, command = [[\mp]] },
    ["~-"] = { context = { name = "≃" }, command = [[\simeq]] },
    [":="] = { context = { name = "≔" }, command = [[\coloneq]] },
    ["o+"] = { context = { name = "⊕" }, command = [[\oplus]] },
    ["=>"] = { context = { name = "⇒" }, command = [[\implies]] },
    ["<="] = { context = { name = "⇐" }, command = [[\impliedby]] },
    ["!>"] = { context = { name = "→" }, command = [[\mapsto]] },
    ["<-"] = { context = { name = "←", priority = 250 }, command = [[\gets]] },
    ["-->"] = { context = { name = "⟶", priority = 500 }, command = [[\longrightarrow]] },
    ["<->"] = { context = { name = "↔", priority = 500 }, command = [[\leftrightarrow]] },
    ["2>"] = { context = { name = "⇉", priority = 400 }, command = [[\rightrightarrows]] },
}
local symbol_snippets = {}
for k, v in pairs(symbol_specs) do
    table.insert(
        symbol_snippets,
        scaffolding.symbol_snippet(
            vim.tbl_deep_extend("keep", { trig = v.trig or k }, v.context),
            v.command,
            { condition = in_math }
        )
    )
end
vim.list_extend(M, symbol_snippets)

local imap_specs = {
    a = { context = { name = "alpha", } },
    b = { context = { name = "beta", } },
    c = { context = { name = "chi", } },
    d = { context = { name = "delta", } },
    e = { context = { name = "epsilon", } },
    g = { context = { name = "gamma", }, alternates = "Gamma" },
    h = { context = { name = "eta", } },
    i = { context = { name = "iota", } },
    k = { context = { name = "kappa", } },
    l = { context = { name = "lambda", }, alternates = "Lambda" },
    n = { context = { name = "nabla", } },
    p = { context = { name = "partial", } },
    q = { context = { name = "theta", }, alternates = "Theta" },
    r = { context = { name = "rho", }, },
    s = { context = { name = "sigma", }, alternates = "Sigma" },
    t = { context = { name = "tau", }, },
    u = { context = { name = "upsilon", } },
    w = { context = { name = "omega", }, alternates = "Omega" },
    x = { context = { name = "xi", }, alternates = "Xi" },
    z = { context = { name = "zeta", } },
    ['8'] = { context = { name = "infty" } },
    ['.'] = { context = { name = "cdot" } },
    ['['] = { context = { name = "subseteq" } },
    [']'] = { context = { name = "supseteq" } },
}
local imap_snippets = {}
for k, v in pairs(imap_specs) do
    table.insert(
        imap_snippets,
        scaffolding.imap_snippet(
            vim.tbl_deep_extend("keep",
                { trig = '`' .. k, snippetType = "autosnippet", wordTrig = false }, v.context),
            v.alternates or {},
            { condition = in_math }
        )
    )
end
vim.list_extend(M, imap_snippets)

return M
