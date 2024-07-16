local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
-- local d = ls.dynamic_node
-- local r = ls.restore_node
-- local l = require("luasnip.extras").lambda
-- local rep = require("luasnip.extras").rep
-- local p = require("luasnip.extras").partial
-- local m = require("luasnip.extras").match
-- local n = require("luasnip.extras").nonempty
-- local dl = require("luasnip.extras").dynamic_lambda
-- local fmt = require("luasnip.extras.fmt").fmt
-- local fmta = require("luasnip.extras.fmt").fmta
-- local types = require("luasnip.util.types")
-- local conds = require("luasnip.extras.conditions")
-- local conds_expand = require("luasnip.extras.conditions.expand")

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

local in_mathzone = function()
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
    if in_mathzone() then
        return false
    end
    local amsthm_list = {
        "definition", "lemma", "theorem", "proposition",
        "corollary", "example", "remark", "proof" }
    for _, name in ipairs(amsthm_list) do
        if in_env(name) then
            return false
        end
    end
    return true
end

ls.add_snippets("tex", {
    s({
        trig = "inl",
        docstring = "inline math mode",
        show_condition = in_text
    }, {
        t("\\( "),
        f(selected_text, {}), i(1),
        t(" \\)")
    }),
    s({
        trig = "dis",
        docstring = "display math mode",
        show_condition = in_text
    }, {
        t({ "\\[", "" }),
        f(indent_selected_text, {}), i(0),
        t({ "", "\\]" })
    }),
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
        show_condition = in_mathzone
    }, {
        t("\\textmd{"), f(selected_text, {}), i(0), t("}")
    }),
    s({
        trig = "ol",
        docstring = "overline",
        show_condition = in_mathzone
    }, {
        t("\\overline{"), f(selected_text, {}), i(0), t("}")
    }),
    s({
        trig = "wt",
        docstring = "widetilde",
        show_condition = in_mathzone
    }, {
        t("\\widetilde{"), f(selected_text, {}), i(0), t("}")
    }),
    s({
        trig = "bra",
        docstring = "surrounding brace or left brace",
        show_condition = in_mathzone
    }, c(1, {
        sn(nil, { t("\\left\\lbrace "), i(1), t(" \\right\\rbrace") }),
        sn(nil, { t("\\left\\lbrace "), i(1), t(" \\right.") }),
    })),
    s({
        trig = "vert",
        docstring = "surrounding vert or right vert",
        show_condition = in_mathzone
    }, c(1, {
        sn(nil, { t("\\left\\vert "), i(1), t(" \\right\\vert") }),
        sn(nil, { t("\\left. "), i(1), t(" \\right\\vert") }),
    })),
    s({
        trig = "norm",
        docstring = "norm",
        show_condition = in_mathzone
    }, {
        t("\\left\\Vert "), f(selected_text, {}), i(1), t(" \\right\\Vert")
    }),
    s({
        trig = "ang",
        docstring = "surrounding angle",
        show_condition = in_mathzone
    }, {
        t("\\left\\langle "), f(selected_text, {}), i(1), t(" \\right\\rangle")
    }),
    s({
        trig = "fpar",
        docstring = "partial fraction",
        show_condition = in_mathzone
    }, c(1, {
        sn(nil, { t("\\frac{\\partial "), i(1), t("}{\\partial "), i(2), t("}") }),
        sn(nil, { t("\\left.\\frac{\\partial "), i(1), t("}{\\partial "), i(2), t("}\\right\\vert") })
    })),
    s({
        trig = "fdif",
        docstring = "differential fraction",
        show_condition = in_mathzone
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
        show_condition = amsthm_show_condition
    }, {
        t("\\begin{align*}"),
        t({ "", "" }), f(indent_selected_text, {}),
        i(0), t({ "", "\\end{align*}" })
    }),
})
