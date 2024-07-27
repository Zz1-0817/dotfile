local ls = require("luasnip")
local tex = require("snippets.tex.utils.conditions")

local line_begin = require("luasnip.extras.conditions.expand").line_begin
local single_command_snippet = require("snippets.tex.utils.scaffolding").single_command_snippet
local simpleenv_snippet = require("snippets.tex.utils.scaffolding").simpleenv_snippet
local postfix_snippet = require("snippets.tex.utils.scaffolding").postfix_snippet
local auto_backslash_snippet = require("snippets.tex.utils.scaffolding").auto_backslash_snippet
local symbol_snippet = require("snippets.tex.utils.scaffolding").symbol_snippet
local enum_snippet = require("snippets.tex.utils.scaffolding").enum_snippet
local autosnippet = ls.extend_decorator.apply(s, { snippetType = "autosnippet" })

local get_visual = function(_, parent)
    return sn(nil, i(1, parent.snippet.env.SELECT_RAW))
end

local case = function(_, snip)
    local rows = tonumber(snip.captures[1]) or 2 -- default option 2 for cases
    local cols = 2                               -- fix to 2 cols
    local nodes = {}
    local ins_indx = 1
    for j = 1, rows do
        table.insert(nodes, r(ins_indx, tostring(j) .. "x1", i(1)))
        ins_indx = ins_indx + 1
        for k = 2, cols do
            table.insert(nodes, t(" & "))
            table.insert(nodes, r(ins_indx, tostring(j) .. "x" .. tostring(k), i(1)))
            ins_indx = ins_indx + 1
        end
        table.insert(nodes, t({ "\\\\", "" }))
    end
    -- fix last node.
    table.remove(nodes, #nodes)
    return sn(nil, nodes)
end

local brackets = { -- recall that [b,p,v,B,V]matrix
    a = { "\\langle", "\\rangle" },
    b = { "\\lbrack", "\\rbrack" },
    p = { "(", ")" },
    v = { "\\vert", "\\vert" },
    B = { "\\lbrace", "\\rbrace" },
    V = { "\\Vert", "\\Vert" },
}

local M = {
    autosnippet(
        { trig = "jj", dscr = "inline math" },
        fmta([[
        \( <><> \)
    ]], { d(1, get_visual), i(0) }),
        { condition = tex.in_text }
    ),
    autosnippet(
        { trig = "kk", dscr = "display math" },
        fmta([[
        \[
          <>
        \]
        ]], { i(0) }),
        { condition = tex.in_text }
    ),
    autosnippet(
        { trig = "tt", dscr = "text in math" },
        fmta([[
        \text{<>}
        ]], { i(0) }),
        { condition = tex.in_math }
    ),
    autosnippet(
        { trig = "mm", dscr = "item in enumerate" },
        fmta([[
        \item
        ]], {}),
        { condition = tex.in_enum }
    ),
    autosnippet(
        { trig = "lr([abpvBV])", name = "left right", dscr = "left right delimiters", trigEngine = "pattern", hidden = true },
        fmta([[
    \left<> <> \right<>
    ]],
            { f(function(_, snip)
                local cap = snip.captures[1]
                if brackets[cap] == nil then
                    cap = "p"
                end
                return brackets[cap][1]
            end),
                d(1, get_visual),
                f(function(_, snip)
                    local cap = snip.captures[1]
                    if brackets[cap] == nil then
                        cap = "p"
                    end
                    return brackets[cap][2]
                end),
            }),
        { condition = tex.in_math, show_condition = tex.in_math }
    ),
    autosnippet(
        { trig = "fpar", name = "partial fraction", dscr = "partial fraction", },
        c(1, {
            sn(nil, { t("\\frac{\\partial "), i(1), t("}{\\partial "), i(2), t("}") }),
            sn(nil, { t("\\left.\\frac{\\partial "), i(1), t("}{\\partial "), i(2), t("}\\right\\vert") })
        }),
        { condition = tex.in_math, show_condition = tex.in_math }
    ),
    autosnippet(
        { trig = "fdif", name = "differential fraction", dscr = "differential fraction" },
        c(1, {
            sn(nil, { t("\\frac{\\dif "), i(1), t("}{\\dif "), i(2), t("}") }),
            sn(nil, { t("\\left.\\frac{\\dif "), i(1), t("}{\\dif "), i(2), t("}\\right\\vert") })
        }),
        { condition = tex.in_math, show_condition = tex.in_math }
    ),
    autosnippet({ trig = "lim", name = "lim(sup|inf)", dscr = "lim(sup|inf)" },
        fmta([[
    \lim<><><>
    ]],
            { c(1, { t(""), t("sup"), t("inf") }),
                c(2, { t(""), fmta([[_{<> \to <>}]], { i(1, "n"), i(2, "\\infty") }) }),
                i(0) }),
        { condition = tex.in_math, show_condition = tex.in_math }
    ),
    autosnippet({ trig = "inv", wordTrig = false }, { t("^{-1}") }, { condition = tex.in_math }),
    autosnippet({ trig = "alg", name = "align(|*|ed)", dscr = "align math" },
        fmta([[
    \begin{align<>}
    <>
    .\end{align<>}
    ]],
            { c(1, { t("*"), t(""), t("ed") }), i(2), rep(1) }), -- in order of least-most used
        { condition = line_begin, show_condition = line_begin }
    ),
    autosnippet({ trig = "gat", name = "gather(|*|ed)", dscr = "gather math" },
        fmta([[
    \begin{gather<>}
    <>
    .\end{gather<>}
    ]],
            { c(1, { t("*"), t(""), t("ed") }), i(2), rep(1) }),
        { condition = line_begin, show_condition = line_begin }
    ),
    autosnippet({ trig = "eqn", name = "equation(|*)", dscr = "equation math" },
        fmta([[
    \begin{equation<>}<>
    <>
    .\end{equation<>}
    ]],
            { c(1, { t("*"), t("") }), c(2, { t(""), fmta([[\tag{<>}<>]], { i(1), i(0) }) }), i(3), rep(1) }),
        { condition = line_begin, show_condition = line_begin }
    ),
    autosnippet({ trig = "(%d?)cases", name = "cases", dscr = "cases", trigEngine = "pattern", hidden = true },
        fmta([[
    \begin{cases}
    <>
    .\end{cases}
    ]],
            { d(1, case) }),
        { condition = tex.in_math, show_condition = tex.in_math }
    ),
    s({ trig = "env", name = "begin env", dscr = "begin/end environment" },
        fmta([[
    \begin{<>}
    <>
    \end{<>}
    ]],
            { i(1), i(0), rep(1) })
    ),
}

local section_specs = {
    ["#"] = {
        context = {
            name = "section",
            dscr = "add a section"
        },
        command = [[\section]],
    },
    ["#*"] = {
        context = {
            name = "section",
            dscr = "add a starred section"
        },
        command = [[\section*]],
    },
    ["##"] = {
        context = {
            name = "section",
            dscr = "add a section"
        },
        command = [[\subsection]],
    },
    ["##*"] = {
        context = {
            name = "section",
            dscr = "add a section"
        },
        command = [[\subsection*]],
    },
    [">"] = {
        context = {
            name = "paragraph",
            dscr = "add a paragraph"
        },
        command = [[\paragraph]],
    },
}
local section_snippets = {}
for k, v in pairs(section_specs) do
    table.insert(
        section_snippets,
        single_command_snippet(
            vim.tbl_deep_extend("keep", { trig = k, hidden = true }, v.context),
            v.command,
            { condition = line_begin }
        )
    )
end
vim.list_extend(M, section_snippets)

local text_command_specs = {
    em = {
        context = {
            name = "emph",
            dscr = "emph text"
        },
        command = [[\\emph]],
    },
    it = {
        context = {
            name = "textit",
            dscr = "italic text"
        },
        command = [[\\textit]],
    },
    bf = {
        context = {
            name = "textit",
            dscr = "bold text"
        },
        command = [[\\textit]],
    },
    sc = {
        context = {
            name = "textsc",
            dscr = "small caps",
        },
        command = [[\textsc]],
    }
}
local text_command_snippets = {}
for k, v in pairs(text_command_specs) do
    table.insert(
        text_command_snippets,
        single_command_snippet(
            vim.tbl_deep_extend("keep", { trig = k, hidden = true }, v.context),
            v.command,
            { condition = tex.in_text }
        )
    )
end
vim.list_extend(M, text_command_snippets)

local postfix_math_specs = {
    vec = {
        context = {
            name = "vector",
            dscr = "vector"
        },
        command = {
            pre = [[\vec{]],
            post = [[}]]
        }
    },
    bar = {
        context = {
            name = "bar",
            dscr = "bar (overline)",
        },
        command = {
            pre = [[\overline{]],
            post = [[}]]
        }
    },
    tld = {
        context = {
            name = "tilde",
            dscr = "tilde",
        },
        command = {
            pre = [[\tilde{]],
            post = [[}]]
        }
    },
    hat = {
        context = {
            name = "hat",
            dscr = "hat",
        },
        command = {
            pre = [[\hat{]],
            post = [[}]]
        }
    },
    mbb = {
        context = {
            name = "mathbb",
            dscr = "math blackboard bold"
        },
        command = {
            pre = [[\mathbb{]],
            post = [[}]]
        }
    },
    mcl = {
        context = {
            name = "mathcal",
            dscr = "math calligraphic"
        },
        command = {
            pre = [[\mathcal{]],
            post = [[}]]
        }
    },
    msc = {
        context = {
            name = "mathscr",
            dscr = "math script",
        },
        command = {
            pre = [[\mathscr{]],
            post = [[}]],
        },
    },
    mfk = {
        context = {
            name = "mathfrak",
            dscr = "mathfrak",
        },
        command = {
            pre = [[\mathfrak{]],
            post = [[}]],
        },
    },
    opn = {
        context = {
            name = "operatorname",
            dscr = "operatorname",
            match_pattern = [[[%a]*$]]
        },
        command = {
            pre = [[\operatorname{]],
            post = [[}]],
        },
    },
    evl = {
        context = {
            name = "evaluate",
            dscr = "evaluate for some expression"
        },
        command = {
            pre = [[\left. ]],
            post = [[ \right\vert]]
        }
    }
}
local postfix_math_snippets = {}
for k, v in pairs(postfix_math_specs) do
    table.insert(
        postfix_math_snippets,
        postfix_snippet(
            vim.tbl_deep_extend("keep", { trig = k, snippetType = "autosnippet" }, v.context),
            v.command,
            { condition = tex.in_math }
        )
    )
end
vim.list_extend(M, postfix_math_snippets)

local auto_backslash_specs = {
    "int",
    "dif",
    "notin",
    "to",
    "pm",
    "mp",
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
    table.insert(auto_backslash_snippets, auto_backslash_snippet({ trig = v }, { condition = tex.in_math }))
end
vim.list_extend(M, auto_backslash_snippets)

local symbol_specs = {
    vphi = { context = { name = "φ" }, command = [[\varphi]] },
    inn = { context = { name = "∈" }, command = [[\in]] },
    pm = { context = { name = "±" }, command = [[\pm]] },
    mp = { context = { name = "∓" }, command = [[\mp]] },
    NN = { context = { name = "ℕ" }, command = [[\mathbb{N}]] },
    ZZ = { context = { name = "ℤ" }, command = [[\mathbb{Z}]] },
    QQ = { context = { name = "ℚ" }, command = [[\mathbb{Q}]] },
    RR = { context = { name = "ℝ" }, command = [[\mathbb{R}]] },
    CC = { context = { name = "ℂ" }, command = [[\mathbb{C}]] },
    leq = { context = { name = "≤" }, command = [[\leq]] },
    geq = { context = { name = "≥" }, command = [[\geq]] },
    AA = { context = { name = "∀" }, command = [[\forall]] },
    EE = { context = { name = "∃" }, command = [[\exists]] },
    ["~-"] = { context = { name = "≃" }, command = [[\simeq]] },
    [":="] = { context = { name = "≔" }, command = [[\definedas]] },
    ["!+"] = { context = { name = "⊕" }, command = [[\oplus]] },
    ["!*"] = { context = { name = "⊗" }, command = [[\otimes]] },
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
        symbol_snippet(vim.tbl_deep_extend("keep", { trig = k }, v.context), v.command, { condition = tex.in_math })
    )
end
vim.list_extend(M, symbol_snippets)

local thm_specs = {
    def = {
        context = {
            name = "definition",
            dscr = "defintion",
        },
    },
    eg = {
        context = {
            name = "example",
            dscr = "example",
        },
    },
    thm = {
        context = {
            name = "theorem",
            dscr = "theorem",
        },
    },
    lem = {
        context = {
            name = "lemma",
            dscr = "lemma",
        },
    },
    cor = {
        context = {
            name = "corollary",
            dscr = "corollary",
        },
    },
    prp = {
        context = {
            name = "proposition",
            dscr = "proposition",
        },
    },
    rmk = {
        context = {
            name = "remark",
            dscr = "remark",
        },
    },
}
local thm_snippets = {}
for k, v in pairs(thm_specs) do
    table.insert(
        thm_snippets,
        simpleenv_snippet(
            vim.tbl_deep_extend("keep", { trig = k, hidden = true }, v.context),
            v.opts or { condition = tex.notin_thm }
        )
    )
end
vim.list_extend(M, thm_snippets)

local enum_specs = {
    enm = {
        context = {
            name = "enumerate",
            dscr = "enumerate"
        }
    },
    dsc = {
        context = {
            name = "description",
            dscr = "description"
        }
    },
    itm = {
        context = {
            name = "itemize",
            dscr = "itemize"
        }
    }
}
local enum_snippets = {}
for k, v in pairs(enum_specs) do
    table.insert(
        enum_snippets,
        enum_snippet(
            vim.tbl_deep_extend("keep", { trig = k, hidden = true }, v.context,
                v.opts or { condition = tex.in_text }
            )
        )
    )
end
vim.list_extend(M, enum_snippets)

return M
