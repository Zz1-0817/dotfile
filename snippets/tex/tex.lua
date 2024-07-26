local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require("luasnip.util.events")
local ai = require("luasnip.nodes.absolute_indexer")
local extras = require("luasnip.extras")
local l = extras.lambda
local rep = extras.rep
local p = extras.partial
local m = extras.match
local n = extras.nonempty
local dl = extras.dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local conds = require("luasnip.extras.expand_conditions")
local postfix = require("luasnip.extras.postfix").postfix
local types = require("luasnip.util.types")
local parse = require("luasnip.util.parser").parse_snippet
local ms = ls.multi_snippet
local k = require("luasnip.nodes.key_indexer").new_key
local line_begin = require("luasnip.extras.conditions.expand").line_begin

local function copy_text(args, _, _)
    return args[1][1]
end

local function selected_text(_, snip)
    local res, env = {}, snip.env
    for _, e in ipairs(env.LS_SELECT_RAW) do
        table.insert(res, e)
    end
    return res
end

local function indent_selected_text(_, snip)
    local res, env = {}, snip.env
    for _, e in ipairs(env.LS_SELECT_RAW) do
        table.insert(res, "\t" .. e)
    end
    if #res == 0 then
        return { "\t" }
    end
    return res
end

local in_math = function()
    return vim.fn['vimtex#syntax#in_mathzone']() == 1
end

local in_text = function()
    return vim.fn['vimtex#syntax#in_mathzone']() ~= 1
end

local in_env = function(name)
    local is_inside = vim.fn['vimtex#env#is_inside'](name)
    return (is_inside[1] > 0 and is_inside[2] > 0)
end

local amsthm_show_condition = function()
    if in_math() then
        return false
    end
    local thm_env = {
        "definition", "lemma", "theorem", "proposition",
        "corollary", "example", "remark", "proof" }
    for _, name in ipairs(thm_env) do
        if in_env(name) then
            return false
        end
    end
    return true
end

local in_itemenv = function ()
    if in_math() then
        return false
    end
    local item_env = { "description", "itemize", "enumerate" }
    for _, name in ipairs(item_env) do
        if in_env(name) then
            return true
        end
    end
    return false
end

local dynamic_postfix = function(_, parent, _, user_arg1, user_arg2)
    local capture = parent.snippet.env.POSTFIX_MATCH
    if #capture > 0 then
        return sn(nil, fmta([[
        <><><>
        ]],
            { t(user_arg1), t(capture), t(user_arg2) }))
    else
        local visual_placeholder = parent.snippet.env.SELECT_RAW
        return sn(nil, fmta([[
        <><><>
        ]],
            { t(user_arg1), i(1, visual_placeholder), t(user_arg2) }))
    end
end

return {
    postfix({
            trig = "vec",
            snippetType = "autosnippet",
            match_pattern = "\\?[%w%.%_%-]*$",
            condition = in_math,
            show_condition = in_math
        },
        { d(1, dynamic_postfix, {}, { user_args = { "\\vec{", "}" } }) }
    ),
    postfix({
            trig = "fk",
            snippetType = "autosnippet",
            match_pattern = "[%a]*$",
            condition = in_math,
            show_condition = in_math
        },
        { d(1, dynamic_postfix, {}, { user_args = { "\\mathfrak{", "}" } }) }
    ),
    postfix({
            trig = "scr",
            snippetType = "autosnippet",
            match_pattern = "[%a]*$",
            condition = in_math,
            show_condition = in_math
        },
        { d(1, dynamic_postfix, {}, { user_args = { "\\mathscr{", "}" } }) }
    ),
    postfix({
            trig = "bb",
            snippetType = "autosnippet",
            match_pattern = "[%a]*$",
            condition = in_math,
            show_condition = in_math
        },
        { d(1, dynamic_postfix, {}, { user_args = { "\\mathbb{", "}" } }) }
    ),
    postfix({
            trig = "cal",
            snippetType = "autosnippet",
            match_pattern = "[%a]*$",
            condition = in_math,
            show_condition = in_math
        },
        { d(1, dynamic_postfix, {}, { user_args = { "\\mathcal{", "}" } }) }
    ),
    postfix({
            trig = "bar",
            snippetType = "autosnippet",
            match_pattern = "\\?[%w%.%_%-]*$",
            condition = in_math,
            show_condition = in_math
        },
        { d(1, dynamic_postfix, {}, { user_args = { "\\overline{", "}" } }) }
    ),
    postfix({
            trig = "td",
            snippetType = "autosnippet",
            match_pattern = "\\?[%w%.%_%-]*$",
            condition = in_math,
            show_condition = in_math
        },
        { d(1, dynamic_postfix, {}, { user_args = { "\\widetilde{", "}" } }) }
    ),
    s({
        trig = "enm",
        snippetType = "autosnippet",
        condition = in_text
    }, fmta([[
    \begin{enumerate}
      \item <>
    \end{enumerate}
    ]], {i(0)})),
    s({
        trig = "itm",
        snippetType = "autosnippet",
        condition = in_text
    }, fmta([[
    \begin{itemize}
      \item <>
    \end{itemize}
    ]], {i(0)})),
    s({
        trig = "mm",
        snippetType = "autosnippet",
        condition = in_itemenv
    }, t("\\item")),
    s({
        trig = "jj",
        snippetType = "autosnippet",
        condition = in_text
    }, fmta([[
    \( <><> \)<>
    ]], { f(selected_text, {}), i(1), i(0) })),
    s({
        trig = "kk",
        snippetType = "autosnippet",
        show_condition = in_text,
        condition = in_text
    }, fmta([[
    \[
    <><>
    \]<>
    ]], { f(indent_selected_text, {}), i(1), i(0) })),
    s({
        trig = "sec",
        condition = conds.line_begin,
        snippetType = "autosnippet"
    }, fmta([[
    \section{<>}<>
    ]], { i(1), i(0) })),
    s({
        trig = "ssec",
        condition = conds.line_begin,
        snippetType = "autosnippet"
    }, fmta([[
    \subsection{<>}<>
    ]], { i(1), i(0) })),
    s({
        trig = "prg",
        condition = conds.line_begin,
        snippetType = "autosnippet"
    }, fmta([[
    \paragraph{<>}<>
    ]], { i(1), i(0) })),
    s({
        trig = "\\?to",
        condition = in_math,
        trigEngine = "pattern",
        snippetType = "autosnippet"
    }, t("\\to")),
    s({
        trig = "\\?!>",
        condition = in_math,
        trigEngine = "pattern",
        snippetType = "autosnippet"
    }, t("\\mapsto")),
    s({
        trig = "\\?iff",
        condition = in_math,
        trigEngine = "pattern",
        snippetType = "autosnippet"
    }, t("\\iff")),
    s({
        trig = "\\?cap",
        condition = in_math,
        trigEngine = "pattern",
        snippetType = "autosnippet"
    }, t("\\cap")),
    s({
        trig = "\\?bcap",
        condition = in_math,
        trigEngine = "pattern",
        snippetType = "autosnippet"
    }, t("\\bigcap")),
    s({
        trig = "\\?bcup",
        condition = in_math,
        trigEngine = "pattern",
        snippetType = "autosnippet"
    }, t("\\bigcup")),
    s({
        trig = "\\?cup",
        condition = in_math,
        trigEngine = "pattern",
        snippetType = "autosnippet"
    }, t("\\cup")),
    s({
        trig = "\\?=>",
        condition = in_math,
        trigEngine = "pattern",
        snippetType = "autosnippet"
    }, t("\\implies")),
    s({
        trig = "\\?in",
        condition = in_math,
        trigEngine = "pattern",
        snippetType = "autosnippet"
    }, t("\\in")),
    s({
        trig = "\\?notin",
        condition = in_math,
        trigEngine = "pattern",
        snippetType = "autosnippet"
    }, t("\\notin")),
    s({
        trig = "\\?AA",
        condition = in_math,
        trigEngine = "pattern",
        snippetType = "autosnippet"
    }, t("\\forall")),
    s({
        trig = "\\?vphi",
        condition = in_math,
        trigEngine = "pattern",
        snippetType = "autosnippet"
    }, t("\\varphi")),
    s({
        trig = "\\?xx",
        condition = in_math,
        trigEngine = "pattern",
        snippetType = "autosnippet"
    }, t("\\times")),
    s({
        trig = "\\?EE",
        condition = in_math,
        trigEngine = "pattern",
        snippetType = "autosnippet"
    }, t("\\exists")),
    s({
        trig = "em",
        docstring = "emph",
        show_condition = in_text,
    }, {
        t("\\emph{"), f(selected_text, {}), i(0), t("}")
    }),
    s({
        trig = "env",
        docstring = "environment"
    }, {
        t("\\begin{"), i(1), t("}"), i(2),
        t({ "", "" }), f(indent_selected_text, {}), i(0),
        t({ "", "\\end{" }), f(copy_text, { 1 }), t("}")
    }),
    s({
        trig = "md",
        docstring = "textmd",
        show_condition = in_math
    }, {
        t("\\textmd{"), f(selected_text, {}), i(0), t("}")
    }),
    s({
        trig = "bra",
        docstring = "surrounding brace or left brace",
        show_condition = in_math
    }, c(1, {
        sn(nil, { t("\\left\\lbrace "), i(1), t(" \\right\\rbrace") }),
        sn(nil, { t("\\left\\lbrace "), i(1), t(" \\right.") }),
    })),
    s({
        trig = "vt",
        docstring = "surrounding vert or right vert",
        show_condition = in_math
    }, c(1, {
        sn(nil, { t("\\left\\vert "), i(1), t(" \\right\\vert") }),
        sn(nil, { t("\\left. "), i(1), t(" \\right\\vert") }),
    })),
    s({
        trig = "nm",
        docstring = "norm",
        show_condition = in_math
    }, {
        t("\\left\\Vert "), f(selected_text, {}), i(1), t(" \\right\\Vert")
    }),
    s({
        trig = "ang",
        docstring = "surrounding angle",
        show_condition = in_math
    }, {
        t("\\left\\langle "), f(selected_text, {}), i(1), t(" \\right\\rangle")
    }),
    s({
        trig = "fpar",
        docstring = "partial fraction",
        show_condition = in_math
    }, c(1, {
        sn(nil, { t("\\frac{\\partial "), i(1), t("}{\\partial "), i(2), t("}") }),
        sn(nil, { t("\\left.\\frac{\\partial "), i(1), t("}{\\partial "), i(2), t("}\\right\\vert") })
    })),
    s({
        trig = "fdif",
        docstring = "differential fraction",
        show_condition = in_math
    }, c(1, {
        sn(nil, { t("\\frac{\\dif "), i(1), t("}{\\dif "), i(2), t("}") }),
        sn(nil, { t("\\left.\\frac{\\dif "), i(1), t("}{\\dif "), i(2), t("}\\right\\vert") })
    })),
    s({
        trig = "def",
        docstring = "definition environment",
        show_condition = amsthm_show_condition
    }, {
        t("\\begin{definition}"),
        t({ "", "" }), f(indent_selected_text, {}),
        i(0), t({ "", "\\end{definition}" })
    }),
    s({
        trig = "rmk",
        docstring = "remark environment",
        show_condition = amsthm_show_condition
    }, {
        t("\\begin{remark}"), t({ "", "" }),
        f(indent_selected_text, {}), i(0),
        t({ "", "\\end{remark}" })
    }),
    s({
        trig = "lem",
        docstring = "lemma environment",
        show_condition = amsthm_show_condition
    }, {
        t("\\begin{lemma}"), i(1),
        t({ "", "" }), f(indent_selected_text, {}),
        i(0), t({ "", "\\end{lemma}" })
    }),
    s({
        trig = "thm",
        docstring = "theorem environment",
        show_condition = amsthm_show_condition
    }, {
        t("\\begin{theorem}"), i(1),
        t({ "", "" }), f(indent_selected_text, {}),
        i(0), t({ "", "\\end{theorem}" })
    }),
    s({
        trig = "prop",
        docstring = "proposition environment",
        show_condition = amsthm_show_condition
    }, {
        t("\\begin{proposition}"), i(1),
        t({ "", "" }), f(indent_selected_text, {}),
        i(0), t({ "", "\\end{proposition}" })
    }),
    s({
        trig = "cor",
        docstring = "corollary environment",
        show_condition = amsthm_show_condition
    }, {
        t("\\begin{corollary}"), i(1),
        t({ "", "" }), f(indent_selected_text, {}),
        i(0), t({ "", "\\end{corollary}" })
    }),
    s({
        trig = "eg",
        docstring = "example environment",
        show_condition = amsthm_show_condition
    }, {
        t("\\begin{example}"),
        t({ "", "" }), f(indent_selected_text, {}),
        i(0), t({ "", "\\end{example}" })
    }),
    s({
        trig = "pf",
        docstring = "proof environment",
        show_condition = amsthm_show_condition
    }, {
        t("\\begin{proof}"),
        t({ "", "" }), f(indent_selected_text, {}),
        i(0), t({ "", "\\end{proof}" })
    }),
    s({
        trig = "alg",
        docstring = "align environment",
        show_condition = in_text
    }, {
        t("\\begin{align*}"),
        t({ "", "" }), f(indent_selected_text, {}),
        i(0), t({ "", "\\end{align*}" })
    })
}
