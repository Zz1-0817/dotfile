local M = {}

local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
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
local autosnippet = ls.extend_decorator.apply(s, { snippetType = "autosnippet" })

local jsregexpOk = false
local trigEngine = jsregexpOk and "ecma" or "pattern"

------ Helper Functions ------

local generatePostfixDynamicNode = function(_, parent, _, user_arg1, user_arg2)
    local capture = parent.snippet.env.POSTFIX_MATCH
    if #capture > 0 then
        return sn(nil, fmta([[
        <><><><>
        ]],
        {t(user_arg1), t(capture), t(user_arg2), i(0)}))
    else
        local visual_placeholder = parent.snippet.env.SELECT_RAW
        return sn(nil, fmta([[
        <><><><>
        ]],
        {t(user_arg1), i(1, visual_placeholder), t(user_arg2), i(0)}))
    end
end
------------------------------

M.createPostfixSnippet = function(context, command, opts)
    opts = opts or {}
    assert(context.trig, "context must include a 'trig' key")
    context.dscr = context.dscr or command
    context.name = context.name or context.dscr
    context.docstring = command.pre .. [[(POSTFIX_MATCH|VISUAL|<1>)]] .. command.post
    context.match_pattern = context.match_pattern or [[[%w%.%_%-%"%']*$]]
    context.trigEngine = trigEngine
    local start, _ = string.find(command.pre, context.trig)
    if start == 2 then
        if trigEngine == "ecma" then
            context.trig = "(?<!\\\\)" .. "(" .. context.trig .. ")"
        elseif trigEngine == "pattern" then
            context.trig = "\\?" .. context.trig
        end
    end
    return postfix(context, { d(1, generatePostfixDynamicNode, {}, { user_args = { command.pre, command.post } }) },
        opts)
end

M.createOptionEnvSnippet = function(context, opts)
    opts = opts or { stored = { ["user_text"] = i(1, "default_text") } }
    assert(context.trig, "context must include a 'trig' key")
    context.dscr = context.dscr or ""
    context.name = context.name or context.dscr
    context.docstring = context.dscr or ""
    return s(
        context,
        c(1, {
            sn(nil, fmta(
                [[
                \begin{<>}
                  <>
                \end{<>}
                ]],
                { t(context.name), r(1, "user_text"), t(context.name) })),
            sn(nil, fmta(
                [[
                \begin{<>}[<>]
                  <><>
                \end{<>}
                ]],
                { t(context.name), i(1), r(2, "user_text"), i(3), t(context.name) }
            ))
        }),
        opts
    )
end

M.createStarredEnvSnippet = function(context, extraSuffix, opts)
    opts = opts or {}
    assert(context.trig, "context must include a 'trig' key")
    local envName = context.name or context.trig
    local choices = { t(envName .. "*"), t(envName .. "") }
    context.name = envName .. "(|*"
    context.dscr = context.dscr or context.name or ""
    if extraSuffix then
        if type(extraSuffix) == "string" then
            table.insert(choices, t(envName .. extraSuffix))
            context.name = context.name .. "|" .. extraSuffix
        elseif type(extraSuffix) == "table" then
            for _, v in ipairs(extraSuffix) do
                table.insert(choices, t(envName .. v))
                context.name = context.name .. '|' .. v .. ')'
            end
        else
            error("suffix should be a string or a table")
        end
        context.name = context.name .. ')'
    end
    return s(context,
        fmta([[
            \begin{<>}
              <>
            \end{<>}
    ]],
            { c(1, choices), i(2), rep(1) }),
        opts)
end

M.createSymbolSnippet = function(context, command, opts)
    opts = opts or {}
    assert(context.trig, "context must include a 'trig' key")
    context.dscr = context.dscr or command
    context.name = context.name or command
    context.docstring = context.docstring or command
    return autosnippet(context, t(command), opts)
end

M.createCommandSnippet = function(context, command, opts)
    opts = opts or {}
    assert(context.trig, "context must include a 'trig' key")
    context.dscr = context.dscr or command
    context.name = context.name or context.dscr
    context.docstring = context.docstring or command
    return s(
        context,
        fmta(command .. "{<><>}", { f(function(_, snip) return snip.env.LS_SELECT_RAW end), i(0) }),
        opts
    )
end

M.createAutoBackslashSnippet = function(context, opts)
    opts = opts or {}
    assert(context.trig, "context must include a 'trig' key")
    context.dscr = context.dscr or (context.trig .. "with automatic backslash")
    context.name = context.name or context.trig
    context.docstring = context.docstring or ([[\]] .. context.trig)
    context.trigEngine = trigEngine
    local text = "\\" .. context.trig
    if trigEngine == "ecma" then
        context.trig = "(?<!\\\\)" .. "(" .. context.trig .. ")"
    elseif trigEngine == "pattern" then
        context.trig = "\\?" .. context.trig
    end
    return autosnippet(context, { t(text) }, opts)
end

M.createEnumSnippet = function(context, opts)
    opts = opts or {}
    assert(context.trig, "context must include a 'trig' key")
    context.dscr = context.dscr or ""
    context.name = context.name or context.dscr
    context.docstring = context.dscr or ""
    return s(
        context,
        fmta(
            [[
    \begin{<>}
      \item <>
    \end{<>}
    ]],
            { t(context.name), i(0), t(context.name) }),
        opts
    )
end

M.createImapSnippet = function(context, opts)
    opts = opts or {}
    assert(context.trig, "context must include a 'trig' key")
    context.dscr = context.dscr or ""
    context.name = context.name or context.dscr
    context.docstring = context.dscr or ""
    return s(context, t("\\" .. context.name), opts)
end

return M
