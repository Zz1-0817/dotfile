local line_begin = require("luasnip.extras.conditions.expand").line_begin
local f = require("luasnip").function_node
local c = require("luasnip").choice_node
local t = require("luasnip").text_node
local s = require("luasnip").snippet
local i = require("luasnip").insert_node
local sn = require("luasnip").snippet_node
local rep = require("luasnip.extras").rep
local fmta = require("luasnip.extras.fmt").fmta
local make_condition = require("luasnip.extras.conditions").make_condition

local env_types = {
    thm = {
        "definition", "lemma", "theorem", "proposition",
        "corollary", "example", "remark", "proof"
    },
    label = {
        "definition", "lemma", "theorem", "proposition",
        "corollary", "example", "remark", "equation"
    },
    enum = {
        "description", "itemize", "enumerate"
    }
}

local in_math = make_condition(utils.external.latex.in_math)

local notin_math = make_condition(function()
    return not utils.external.latex.in_math()
end)

local function in_type(envs)
    local function in_env(name)
        local is_inside = vim.fn['vimtex#env#is_inside'](name)
        return (is_inside[1] > 0 and is_inside[2] > 0)
    end
    return function()
        for _, env in ipairs(envs) do
            if in_env(env) then
                return true
            end
        end
        return false
    end
end

local in_enum = make_condition(in_type(env_types.enum))
local label_valid = make_condition(in_type(env_types.label))
local notin_thm = make_condition(function()
    return not in_type(env_types.thm)()
end)

local M = {
    s({ trig = "jj", dscr = "inline math", snippetType = "autosnippet" }, fmta([[
        \( <><> \)
    ]], { f(function(_, snip)
        return snip.env.LS_SELECT_RAW
    end), i(0) }), { condition = notin_math }),
    s({ trig = "kk", dscr = "display math", snippetType = "autosnippet" }, fmta([[
        \[
          <>
        \]
        ]], { i(0) }),
        { condition = notin_math }
    ),
    s({ trig = "tt", dscr = "text in math", snippetType = "autosnippet" },
        fmta([[
        \text{<>}
        ]], { i(0) }),
        { condition = in_math }
    ),
    s({ trig = "mm", dscr = "item in enumerate", snippetType = "autosnippet" },
        fmta([[
        \item
        ]], {}),
        { condition = in_enum }
    ),
    s({ trig = "ll", dscr = "label", snippetType = "autosnippet" },
        fmta([[
        \label{<>}
        ]], { i(0) }),
        { condition = label_valid }
    ),
    s({ trig = "ff", dscr = "fractional", snippetType = "autosnippet" },
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
        { condition = in_math }
    ),
    s({ trig = "ss", dscr = "root", snippetType = "autosnippet" },
        fmta([[
        \sqrt{<>}
        ]], { i(0) }),
        { condition = in_math }
    ),
    s({ trig = "ivs", wordTrig = false },
        { t("^{-1}") },
        { condition = in_math }
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
                i(0), rep(1) }
        )
    ),
}

local starred_envs = {
    {
        context = {
            trig = "alg",
            name = "align",
        },
        extraSuffix = "ed",
    },
    {
        context = {
            trig = "gat",
            name = "gather",
        },
        extraSuffix = "ed",
    },
    {
        context = {
            trig = "eqn",
            name = "equation",
        },
        extraSuffix = { "", "*" }
    },
}

for _, spec in ipairs(starred_envs) do
    local context = spec.context
    context.hidden = true
    local extraSuffix = spec.extraSuffix
    local suffixes = { "*", "" }
    if extraSuffix then
        if type(extraSuffix) == "string" then
            table.insert(suffixes, extraSuffix)
        elseif type(extraSuffix) == "table" then
            if vim.tbl_contains(extraSuffix, "") or vim.tbl_contains(extraSuffix, "*") then
                suffixes = extraSuffix
            else
                for _, v in ipairs(extraSuffix) do
                    table.insert(suffixes, v)
                end
            end
        else
            error("suffix should be a string or a table")
        end
    end
    local choices = {}
    for _, suffix in ipairs(suffixes) do
        table.insert(choices, sn(nil, fmta(
            [[
            \begin{<>}
              <>
            \end{<>}
            ]],
            { t(context.name .. suffix), i(1), t(context.name .. suffix) })
        ))
    end
    table.insert(M, s(context, c(1, choices), { condition = line_begin }))
end

local sections = {
    {
        context = {
            trig = "#",
            name = "section",
            dscr = "add a section"
        },
        command = [[\section]],
    },
    {
        context = {
            trig = "#*",
            name = "section*",
            dscr = "add a starred section"
        },
        command = [[\section*]],
    },
    {
        context = {
            trig = "##",
            name = "subsection",
            dscr = "add a section"
        },
        command = [[\subsection]],
    },
    {
        context = {
            trig = "##*",
            name = "subsection*",
            dscr = "add a section"
        },
        command = [[\subsection*]],
    },
    {
        context = {
            trig = ">",
            name = "paragraph",
            dscr = "add a paragraph"
        },
        command = [[\paragraph]],
    },
}

for _, spec in ipairs(sections) do
    local context = spec.context
    context.hidden = true
    table.insert(M,
        s(
            context,
            fmta(spec.command .. "{<><>}", { f(function(_, snip) return snip.env.LS_SELECT_RAW end), i(0) }),
            { condition = line_begin * notin_math }
        )
    )
end

local text_commands = {
    {
        context = {
            trig = "em",
            name = "emph",
            dscr = "emph text"
        },
        command = [[\emph]],
    },
    {
        context = {
            trig = "it",
            name = "textit",
            dscr = "italic text"
        },
        command = [[\textit]],
    },
    {
        context = {
            trig = "bf",
            name = "textbf",
            dscr = "bold text"
        },
        command = [[\textbf]],
    },
    {
        context = {
            trig = "sc",
            name = "textsc",
            dscr = "small caps",
        },
        command = [[\textsc]],
    }
}

for _, spec in ipairs(text_commands) do
    local context = spec.context
    context.hidden = true
    table.insert(M,
        s(
            context,
            fmta(spec.command .. "{<><>}", { f(function(_, snip) return snip.env.LS_SELECT_RAW end), i(0) }),
            { condition = notin_math }
        ))
end

local thms = {
    {
        context = {
            trig = "def",
            name = "definition",
            dscr = "defintion",
        },
    },
    {
        context = {
            trig = "eg",
            name = "example",
            dscr = "example",
        },
        named = true
    },
    {
        context = {
            trig = "thm",
            name = "theorem",
            dscr = "theorem",
        },
        named = true
    },
    {
        context = {
            trig = "lem",
            name = "lemma",
            dscr = "lemma",
        },
    },
    {
        context = {
            trig = "cor",
            name = "corollary",
            dscr = "corollary",
        },
        named = true
    },
    {
        context = {
            trig = "prp",
            name = "proposition",
            dscr = "proposition",
        },
    },
    {
        context = {
            trig = "rmk",
            name = "remark",
            dscr = "remark",
        },
    },
    {
        context = {
            trig = "pf",
            name = "proof",
            dscr = "proof",
        },
    },
}

for _, spec in ipairs(thms) do
    local context = spec.context
    context.hidden = true
    if spec.named then
        table.insert(M,
            s(context,
                fmta(
                    [[
            \begin{<>}<><><>
              <>
            \end{<>}
            ]],
                    { t(context.name), f(function(args) return args[1][1] == '' and '' or '[' end, { 1 }),
                        i(1), f(function(args) return args[1][1] == '' and '' or ']' end, { 1 }),
                        i(0), t(context.name) }
                ),
                { condition = notin_thm }
            )
        )
    else
        table.insert(M,
            s(context,
                fmta(
                    [[
            \begin{<>}
              <>
            \end{<>}
            ]],
                    { t(context.name), i(0), t(context.name) }
                ),
                { condition = notin_thm }
            )
        )
    end
end

local enums = {
    {
        context = {
            trig = "enm",
            name = "enumerate",
            dscr = "enumerate"
        }
    },
    {
        context = {
            trig = "dsc",
            name = "description",
            dscr = "description"
        }
    },
    {
        context = {
            trig = "itm",
            name = "itemize",
            dscr = "itemize"
        }
    }
}

for _, spec in ipairs(enums) do
    local context = spec.context
    context.hidden = true
    table.insert(M,
        s(
            context,
            fmta(
                [[
    \begin{<>}
      \item <>
    \end{<>}
    ]],
                { t(context.name), i(0), t(context.name) }),
            { condition = notin_math }
        )
    )
end

vim.list_extend(M, require("snippets.latex").load({ in_math = utils.external.latex.in_math }))

return M
