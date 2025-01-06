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

local jsregexp_ok, jsregexp = pcall(require, "luasnip-jsregexp")
if not jsregexp_ok then
    jsregexp_ok, jsregexp = pcall(require, "jsregexp")
end

------ Helper Functions ------

local generatePostfixDynamicNode = function(_, parent, _, user_arg1, user_arg2)
    local capture = parent.snippet.env.POSTFIX_MATCH
    if #capture > 0 then
        return sn(nil, fmta([[
        <><><><>
        ]],
            { t(user_arg1), t(capture), t(user_arg2), i(0) }))
    else
        local visual_placeholder = parent.snippet.env.SELECT_RAW
        return sn(nil, fmta([[
        <><><><>
        ]],
            { t(user_arg1), i(1, visual_placeholder), t(user_arg2), i(0) }))
    end
end

------------------------------

M.createPostfixSnippet = function(context, opts, command)
    opts = opts or {}
    assert(context.trig, "context must include a 'trig' key")
    context.dscr = context.dscr or command
    context.name = context.name or context.dscr
    context.docstring = command.pre .. [[(POSTFIX_MATCH|VISUAL|<1>)]] .. command.post
    context.match_pattern = context.match_pattern or [[[%w%.%_%-%"%']*$]]
    return postfix(context, { d(1, generatePostfixDynamicNode, {}, { user_args = { command.pre, command.post } }) },
        opts)
end

M.createOptionEnvSnippet = function(context, opts, withOption)
    opts = opts or {}
    assert(context.trig, "context must include a 'trig' key")
    context.dscr = context.dscr or ""
    context.name = context.name or context.dscr
    context.docstring = context.dscr or ""
    if withOption then
        return s(
            context,
            fmta(
                [[
            \begin{<>}<><><>
              <>
            \end{<>}
            ]],
                {
                    t(context.name), f(function(args) return args[1][1] == '' and '' or '[' end, { 1 }),
                    i(1), f(function(args) return args[1][1] == '' and '' or ']' end, { 1 }),
                    i(2), t(context.name) }
            ),
            opts
        )
    end
    return s(
        context,
        fmta(
            [[
        \begin{<>}
          <>
        \end{<>}
        ]],
            { t(context.name), i(0), t(context.name) }
        ),
        opts
    )
end

M.createStarredEnvSnippet = function(context, opts, extraSuffix)
    opts = opts or {}
    assert(context.trig, "context must include a 'trig' key")
    local envName = context.name or context.trig
    local suffixes = { "*", "" }
    context.dscr = context.dscr or context.name or ""
    if extraSuffix then
        if type(extraSuffix) == "string" then
            if extraSuffix == "" or extraSuffix == "*" then
                return s(fmta([[
                \begin{<>}
                  <>
                \end{<>}
                ]],
                    { t(envName), i(1), t(envName) }), opts
                )
            end
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
        context.name = context.name .. ')'
    end
    local choices = {}
    for _, suffix in ipairs(suffixes) do
        table.insert(choices, sn(nil, fmta(
            [[
            \begin{<>}
              <>
            \end{<>}
            ]],
            { t(envName .. suffix), i(1), t(envName .. suffix) })
        ))
    end
    return s(context, c(1, choices), opts)
end

M.createSymbolSnippet = function(context, opts, command)
    opts = opts or {}
    assert(context.trig, "context must include a 'trig' key")
    context.dscr = context.dscr or command
    context.name = context.name or command
    context.docstring = context.docstring or command
    if context.trigEngine and context.trigEngine == "ecma" and jsregexp_ok then
        context.trig = "(?<!\\\\)" .. "(" .. context.trig .. ")"
    end
    return autosnippet(context, t(command), opts)
end

M.createCommandSnippet = function(context, opts, command)
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
    local text = "\\" .. context.trig
    if jsregexp_ok then
        context.trigEngine = "ecma"
        context.trig = "(?<!\\\\)" .. "(" .. context.trig .. ")"
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
