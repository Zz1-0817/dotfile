local ls = require("luasnip")
local line_begin = require("luasnip.extras.conditions.expand").line_begin
local autosnippet = ls.extend_decorator.apply(s, { snippetType = "autosnippet" })
local conditions = require("snippets.tex.utils.conditions")
local helper = require("snippets.tex.utils.helper")
local scaffolding = require("snippets.tex.utils.scaffolding")

local M = {
    autosnippet(
        { trig = "jj", dscr = "inline math" },
        fmta([[
        \( <><> \)
    ]], { f(helper.getSelectedText, {}), i(0) }),
        { condition = conditions.isInTextZone }
    ),
    autosnippet(
        { trig = "kk", dscr = "display math" },
        fmta([[
        \[
          <>
        \]
        ]], { i(0) }),
        { condition = conditions.isInTextZone }
    ),
    autosnippet(
        { trig = "tt", dscr = "text in math" },
        fmta([[
        \text{<>}
        ]], { i(0) }),
        { condition = conditions.isInMathZone }
    ),
    autosnippet(
        { trig = "mm", dscr = "item in enumerate" },
        fmta([[
        \item
        ]], {}),
        { condition = conditions.isInEnumerate }
    ),
    autosnippet(
        { trig = "ll", dscr = "label" },
        fmta([[
        \label{<><>}
        ]], { f(helper.getLabelPrefix), i(0) })
    ),
    autosnippet(
        { trig = "ff", dscr = "fractional" },
        c(1, {
            fmta([[
            \frac{<>}{<>}
            ]], { i(1), i(2) }),
            fmta([[
            \frac{\dif <>}{\dif <>}
            ]], { i(1), i(2) }),
            fmta([[
            \frac{\partial <>}{\partial <>}
            ]], { i(1), i(2) })
        }),
        { condition = conditions.isInMathZone }
    ),
    autosnippet(
        { trig = "ss", dscr = "root" },
        fmta([[
        \sqrt{<>}
        ]], { i(0) }),
        { condition = conditions.isInMathZone }
    ),
    autosnippet(
        {
            trig = "lr([abpvBV])",
            name = "left right",
            dscr = "left right delimiters",
            trigEngine = "pattern",
            hidden = true
        },
        helper.leftRightBracket,
        { condition = conditions.isInMathZone, show_condition = conditions.isInMathZone }
    ),
    autosnippet(
        { trig = "fpar", name = "partial fraction", dscr = "partial fraction", },
        c(1, {
            sn(nil, { t("\\frac{\\partial "), i(1), t("}{\\partial "), i(2), t("}") }),
            sn(nil, { t("\\left.\\frac{\\partial "), i(1), t("}{\\partial "), i(2), t("}\\right\\vert") })
        }),
        { condition = conditions.isInMathZone, show_condition = conditions.isInMathZone }
    ),
    autosnippet({ trig = "ivs", wordTrig = false }, { t("^{-1}") }, { condition = conditions.isInMathZone }),
    autosnippet({ trig = "(%d?)cases", name = "cases", dscr = "cases", trigEngine = "pattern", hidden = true },
        fmta([[
    \begin{cases}
    <>
    \end{cases}
    ]],
            { d(1, helper.cases) }),
        { condition = conditions.isInMathZone, show_condition = conditions.isInMathZone }
    ),
    s({ trig = "env", hidden = true, name = "begin env", dscr = "begin/end environment" },
        fmta(
            [[
            \begin{<>}<><><>
              <>
            \end{<>}
            ]],
            {
                i(1), f(function(args) return (args[1][1] == '' or args[1][1]:sub(1, 1) == '{') and '' or '[' end, { 2 }),
                i(2), f(function(args) return (args[1][1] == '' or args[1][1]:sub(1, 1) == '{') and '' or ']' end, { 2 }),
                i(3), rep(1) }
        )
    ),
}

-------- Snippets created by scaffolding --------

local starredEnvSpecs = {
    alg = {
        context = {
            name = "align",
        },
        extraSuffix = "ed",
    },
    gat = {
        context = {
            name = "gather",
        },
        extraSuffix = "ed",
    },
    eqn = {
        context = {
            name = "equation",
        },
        extraSuffix = { "", "*" }
    },
}

local sectionSpecs = {
    ["#"] = {
        context = {
            name = "section",
            dscr = "add a section"
        },
        command = [[\section]],
    },
    ["#*"] = {
        context = {
            name = "section*",
            dscr = "add a starred section"
        },
        command = [[\section*]],
    },
    ["##"] = {
        context = {
            name = "subsection",
            dscr = "add a section"
        },
        command = [[\subsection]],
    },
    ["##*"] = {
        context = {
            name = "subsection*",
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

local textCommandSpecs = {
    em = {
        context = {
            name = "emph",
            dscr = "emph text"
        },
        command = [[\emph]],
    },
    it = {
        context = {
            name = "textit",
            dscr = "italic text"
        },
        command = [[\textit]],
    },
    bf = {
        context = {
            name = "textbf",
            dscr = "bold text"
        },
        command = [[\textbf]],
    },
    sc = {
        context = {
            name = "textsc",
            dscr = "small caps",
        },
        command = [[\textsc]],
    }
}

local postfixMathSpecs = {
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
    dt = {
        context = {
            name = "dot",
            dscr = "dot",
        },
        command = {
            pre = [[\dot{]],
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
            pre = [[\widetilde{]],
            post = [[}]]
        }
    },
    hat = {
        context = {
            name = "hat",
            dscr = "hat",
        },
        command = {
            pre = [[\widehat{]],
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
    mbf = {
        context = {
            name = "mathbf",
            dscr = "math bold"
        },
        command = {
            pre = [[\mathbf{]],
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
    },
    mod = {
        context = {
            name = "modulo",
            dscr = "modulo"
        },
        command = {
            pre = [[\mod{]],
            post = [[}]]
        }
    },
    pmod = {
        context = {
            name = "modulo with bracket",
            dscr = "modulo with bracket"
        },
        command = {
            pre = [[\pmod{]],
            post = [[}]]
        }
    }
}

local autobackslashSpecs = {
    "pi",
    "chi",
    "phi",
    "Phi",
    "Psi",
    "psi",
    "nu",
    "xi",
    "Xi",
    "mu",
    "cap",
    "cup",
    "neq",
    "lim",
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
    -- "sup",
    "inf",
    "det",
    "max",
    "min",
    "argmax",
    "argmin",
    "deg",
    "angle",
}

local symbolSpecs = {
    vep = { context = { name = "ε" }, command = [[\varepsilon]] },
    vph = { context = { name = "φ" }, command = [[\varphi]] },
    inn = { context = { name = "∈", trigEngine = "ecma" }, command = [[\in]] },
    oo = { context = { name = "○" }, command = [[\circ]] },
    OO = { context = { name = "⊕" }, command = [[\oplus]] },
    xx = { context = { name = "×" }, command = [[\times]] },
    XX = { context = { name = "⊗" }, command = [[\otimes]] },
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
    -- [":="] = { context = { name = "≔" }, command = [[\coloneq]] },
    ["=>"] = { context = { name = "⇒" }, command = [[\implies]] },
    ["<="] = { context = { name = "⇐" }, command = [[\impliedby]] },
    ["!>"] = { context = { name = "→" }, command = [[\mapsto]] },
    ["<-"] = { context = { name = "←", priority = 250 }, command = [[\gets]] },
    ["-->"] = { context = { name = "⟶", priority = 500 }, command = [[\longrightarrow]] },
    ["<->"] = { context = { name = "↔", priority = 500 }, command = [[\leftrightarrow]] },
}

local imapSpecs = {
    a = { context = { name = "alpha", } },
    b = { context = { name = "beta", } },
    c = { context = { name = "chi", } },
    d = { context = { name = "delta", } },
    e = { context = { name = "epsilon", } },
    g = { context = { name = "gamma", } },
    h = { context = { name = "eta", } },
    i = { context = { name = "iota", } },
    k = { context = { name = "kappa", } },
    l = { context = { name = "lambda", } },
    n = { context = { name = "nabla", } },
    p = { context = { name = "partial", } },
    q = { context = { name = "theta", } },
    r = { context = { name = "rho", }, },
    s = { context = { name = "sigma", } },
    t = { context = { name = "tau", }, },
    u = { context = { name = "upsilon", } },
    w = { context = { name = "omega", } },
    z = { context = { name = "zeta", } },
    D = { context = { name = "Delta", } },
    G = { context = { name = "Gamma", } },
    L = { context = { name = "Lambda", } },
    W = { context = { name = "Omega", } },
    ['\\'] = { context = { name = "setminus" } },
    ['0'] = { context = { name = "varnothing" } },
    ['8'] = { context = { name = "infty" } },
    ['.'] = { context = { name = "cdot" } },
    ['['] = { context = { name = "subseteq" } },
    [']'] = { context = { name = "supseteq" } },
    ['='] = { context = { name = "equiv" } },
}

local thmSpecs = {
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
        named = true
    },
    thm = {
        context = {
            name = "theorem",
            dscr = "theorem",
        },
        named = true
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
        named = true
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
    pf = {
        context = {
            name = "proof",
            dscr = "proof",
        },
    },
}

local enumSpecs = {
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

local expandSnippet = function(specs, scaffold, extraContext, extraOpts)
    local tbl = {}
    for trig, spec in pairs(specs) do
        local context = { trig = trig }
        local opts = extraOpts or {}
        local arguments = {}
        for k, v in pairs(spec) do
            if k == 'context' then
                context = vim.tbl_deep_extend("keep", context, v, extraContext)
            elseif k == "opts" then
                opts = vim.tbl_deep_extend("force", opts, v)
            else
                table.insert(arguments, v)
            end
        end
        table.insert(tbl, scaffold(context, opts, unpack(arguments)))
    end
    vim.list_extend(M, tbl)
end

expandSnippet(starredEnvSpecs, scaffolding.createStarredEnvSnippet, { hidden = true }, { condition = line_begin })
expandSnippet(sectionSpecs, scaffolding.createCommandSnippet, { hidden = true }, { condition = line_begin })
expandSnippet(textCommandSpecs, scaffolding.createCommandSnippet, { hidden = true },
    { condition = conditions.isInTextZone })
expandSnippet(postfixMathSpecs, scaffolding.createPostfixSnippet, { snippetType = "autosnippet" },
    { condition = conditions.isInMathZone })
expandSnippet(helper.decorateAutobackslashSpecs(autobackslashSpecs), scaffolding.createAutoBackslashSnippet, {},
    { condition = conditions.isInMathZone })
expandSnippet(symbolSpecs, scaffolding.createSymbolSnippet, {}, { condition = conditions.isInMathZone })
expandSnippet(helper.prefixImapSpecs(imapSpecs), scaffolding.createImapSnippet,
    { snippetType = "autosnippet", wordTrig = false },
    { condition = conditions.isInMathZone })
expandSnippet(thmSpecs, scaffolding.createOptionEnvSnippet, { hidden = true }, { condition = conditions.isNotInTheorem })
expandSnippet(enumSpecs, scaffolding.createEnumSnippet, { hidden = true }, { condition = conditions.isInTextZone })

--------------------------------------------------

return M
