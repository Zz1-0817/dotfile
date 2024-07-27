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

local generate_postfix_dynamicnode = function(_, parent, _, user_arg1, user_arg2)
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

M.postfix_snippet = function(context, command, opts)
    opts = opts or {}
    if not context.trig then
        error("context doesn't include a `trig` key which is mandatory", 2)
    end
    context.dscr = context.dscr or command
    context.name = context.name or context.dscr
    context.docstring = command.pre .. [[(POSTFIX_MATCH|VISUAL|<1>)]] .. command.post
    context.match_pattern = context.match_pattern or [[[%w%.%_%-%"%']*$]]
    context.snippetType = "autosnippet"
    local start, _ = string.find(command.pre, context.trig)
    if start == 2 then
        context.trigEngine = "pattern"
        context.trig = "\\?" .. context.trig
    end
    return postfix(context, { d(1, generate_postfix_dynamicnode, {}, { user_args = { command.pre, command.post } }) },
        opts)
end

M.simpleenv_snippet = function(context, opts)
    opts = opts or {}
    if not context.trig then
        error("context doesn't include a `trig` key which is mandatory", 2)
    end
    context.dscr = context.dscr or ""
    context.name = context.name or context.dscr
    context.docstring = context.dscr or ""
    return s(
        context,
        fmta(
            [[
    \begin{<>}
      <>
    \end{<>}
    ]],
            { t(context.name), i(0), t(context.name) }),
        opts
    )
end

M.symbol_snippet = function(context, command, opts)
    opts = opts or {}
    if not context.trig then
        error("context doesn't include a `trig` key which is mandatory", 2)
    end
    context.dscr = context.dscr or command
    context.name = context.name or command:gsub([[\]], "")
    context.docstring = context.docstring or command
    local start, _ = string.find(command, context.trig)
    if start == 2 then
        context.trigEngine = "pattern"
        context.trig = "\\?" .. context.trig
        context.hidden = true
    end
    return autosnippet(context, t(command), opts)
end

M.single_command_snippet = function(context, command, opts)
    opts = opts or {}
    if not context.trig then
        error("context doesn't include a `trig` key which is mandatory", 2)
    end
    context.dscr = context.dscr or command
    context.name = context.name or context.dscr
    context.docstring = context.docstring or command
    local start, _ = string.find(command, context.trig)
    if start == 2 then
        context.trigEngine = "pattern"
        context.trig = "\\?" .. context.trig
        context.hidden = true
    end
    return s(
        context,
        fmta(command .. "{<>}", { i(0) }),
        opts
    )
end

M.auto_backslash_snippet = function(context, opts)
    opts = opts or {}
    if not context.trig then
        error("context doesn't include a `trig` key which is mandatory", 2)
    end
    context.dscr = context.dscr or (context.trig .. "with automatic backslash")
    context.name = context.name or context.trig
    context.docstring = context.docstring or ([[\]] .. context.trig)
    local text = "\\" .. context.trig
    context.trigEngine = "pattern"
    context.trig = "\\?" .. context.trig
    return autosnippet(context, { t(text) }, opts)
end

M.enum_snippet = function(context, opts)
    opts = opts or {}
    if not context.trig then
        error("context doesn't include a `trig` key which is mandatory", 2)
    end
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

return M
