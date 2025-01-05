local ls = require("luasnip")
local line_begin = require("luasnip.extras.conditions.expand").line_begin
local autosnippet = ls.extend_decorator.apply(s, { snippetType = "autosnippet" })
local conditions = require("snippets.tex.utils.conditions")
local helper = require("snippets.tex.utils.helper")
local scaffolding = require("snippets.tex.utils.scaffolding")

--- FIX:
--- 1. snippet `inverse' should be triggerred by `emca', decide to disable `emca.
--- 2. `sup' conflict with `supp': type \sup in manual
--- 3. `inn` BUG, can not be fixed right now, since symbols like '+-' will induce unpredictable BUGs.
--- TODO:
--- 1. determine whether expand autobackslash snippet after `_`: environment are complicated, do not expand

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
        fmta([[
        \frac{<>}{<>}
        ]], { i(1), i(0) }),
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
    autosnippet(
        { trig = "fdif", name = "differential fraction", dscr = "differential fraction" },
        c(1, {
            sn(nil, { t("\\frac{\\dif "), i(1), t("}{\\dif "), i(2), t("}") }),
            sn(nil, { t("\\left.\\frac{\\dif "), i(1), t("}{\\dif "), i(2), t("}\\right\\vert") })
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
        fmta([[
    \begin{<>}<>
      <>
    \end{<>}
    ]],
            { i(1), i(2), i(0), rep(1) })
    ),
}

-------- Snippets created by scaffolding --------

local starredEnvSpecs = {
    alg = {
        context = {
            name = "align",
        },
        extra_suffix = "ed",
    },
    gat = {
        context = {
            name = "gather",
        },
        extra_suffix = "ed",
    },
    eqn = {
        context = {
            name = "equation",
        },
        extra_suffix = { "", "*" }
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
    "nu",
    "xi",
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
    chi = { context = { name = "χ" }, command = [[\chi]] },
    vep = { context = { name = "ε" }, command = [[\varepsilon]] },
    vph = { context = { name = "φ" }, command = [[\varphi]] },
    phi = { context = { name = "ϕ" }, command = [[\phi]] },
    Phi = { context = { name = "ϕ" }, command = [[\Phi]] },
    psi = { context = { name = "Ψ" }, command = [[\psi]] },
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
    q = { context = { name = "theta", } },
    r = { context = { name = "rho", }, },
    s = { context = { name = "sigma", } },
    t = { context = { name = "tau", }, },
    u = { context = { name = "upsilon", } },
    w = { context = { name = "omega", } },
    x = { context = { name = "xi", } },
    z = { context = { name = "zeta", } },
    D = { context = { name = "Delta", } },
    G = { context = { name = "Gamma", } },
    L = { context = { name = "Lambda", } },
    W = { context = { name = "Omega", } },
    X = { context = { name = "Xi", } },
    ['\\'] = { context = { name = "setminus" } },
    ['0'] = { context = { name = "varnothing" } },
    ['6'] = { context = { name = "partial", } },
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

helper.extendScaffoldingSnippet(M, starredEnvSpecs, scaffolding.createStarredEnvSnippet, line_begin, "extra_suffix",
    { hidden = true })
helper.extendScaffoldingSnippet(M, sectionSpecs, scaffolding.createCommandSnippet, line_begin, "command",
    { hidden = true })
helper.extendScaffoldingSnippet(M, textCommandSpecs, scaffolding.createCommandSnippet, conditions.isInTextZone,
    "command", { hidden = true })
helper.extendScaffoldingSnippet(M, postfixMathSpecs, scaffolding.createPostfixSnippet, conditions.isInMathZone,
    "command", { snippetType = "autosnippet" })
helper.extendScaffoldingSnippet(M, autobackslashSpecs, scaffolding.createAutoBackslashSnippet, conditions.isInMathZone)
helper.extendScaffoldingSnippet(M, symbolSpecs, scaffolding.createSymbolSnippet, conditions.isInMathZone, "command")
helper.extendScaffoldingSnippet(M, imapSpecs, scaffolding.createImapSnippet, conditions.isInMathZone, "",
    { snippetType = "autosnippet", wordTrig = false }, '`')
helper.extendScaffoldingSnippet(M, thmSpecs, scaffolding.createOptionEnvSnippet, conditions.isNotInTheorem, "",
    { hidden = true })
helper.extendScaffoldingSnippet(M, enumSpecs, scaffolding.createEnumSnippet, conditions.isInTextZone, "",
    { hidden = true })

--------------------------------------------------

return M
