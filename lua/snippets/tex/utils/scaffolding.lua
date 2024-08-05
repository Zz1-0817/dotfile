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

M.has_jsregexp = false

local trigEngine
if M.has_jsregexp then
    trigEngine = "ecma"
else
    trigEngine = "pattern"
end

local generate_postfix_dynamicnode = function(_, parent, _, user_arg1, user_arg2)
    local capture = parent.snippet.env.POSTFIX_MATCH
    return sn(nil,
        fmta([[
        <><><>
        ]],
            { t(user_arg1), t(capture), t(user_arg2) })
    )
end

M.postfix_snippet = function(context, command, opts)
    opts = opts or {}
    if not context.trig then
        error("context doesn't include a `trig` key which is mandatory", 2)
    end
    context.dscr = context.dscr or command
    context.name = context.name or context.dscr
    context.docstring = command.pre .. [[(POSTFIX_MATCH|VISUAL|<1>)]] .. command.post
    context.match_pattern = context.match_pattern or [[\?[%w%.%_%-%"%']+$]]
    context.trigEngine = trigEngine
    local start, _ = string.find(command.pre, context.trig)
    if start == 2 then
        if trigEngine == "ecma" then
            context.trig = "(?<!\\\\)" .. "(" .. context.trig .. ")"
        elseif trigEngine == "pattern" then
            context.trig = "\\?" .. context.trig
        end
    end
    return postfix(context, { d(1, generate_postfix_dynamicnode, {}, { user_args = { command.pre, command.post } }) },
        opts)
end

M._postfix_snippet = function(context, command, opts)
    opts = opts or {}
    if not context.trig then
        error("context doesn't include a `trig` key which is mandatory", 2)
    end
    context.dscr = (context.dscr or command) .. "(normal)"
    context.name = context.name or context.dscr
    context.docstring = command.pre .. [[(POSTFIX_MATCH|VISUAL|<1>)]] .. command.post .. "(normal)"
    context.trigEngine = trigEngine
    local start, _ = string.find(command.pre, context.trig)
    if start == 2 then
        if trigEngine == "ecma" then
            context.trig = "(?<!\\\\)" .. "(" .. context.trig .. ")"
        elseif trigEngine == "pattern" then
            context.trig = "\\?" .. context.trig
        end
    end
    return s(context, fmta([[
    <><><><>
    ]], { t(command.pre), f(function(_, snip)
        return snip.env.LS_SELECT_RAW
    end), i(0), t(command.post) }, opts))
end


M.optionenv_snippet = function(context, opts)
    opts = opts or { stored = { ["user_text"] = i(1, "default_text") } }
    if not context.trig then
        error("context doesn't include a `trig` key which is mandatory", 2)
    end
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
                  <>
                \end{<>}
                ]],
                { t(context.name), i(1), r(2, "user_text"), t(context.name) }
            )),
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

M.starredenv_snippet = function(context, extra_suffix, opts)
    opts = opts or {}
    if not context.trig then
        error("context doesn't include a `trig` key which is mandatory", 2)
    end
    local choices = { t("*"), t("") }
    local env_name = context.name or context.trig
    context.name = env_name
    context.name = context.name .. "(|*"
    context.dscr = context.dscr or context.name or ""
    if extra_suffix then
        if type(extra_suffix) == "string" then
            table.insert(choices, t(extra_suffix))
            context.name = context.name .. "|" .. extra_suffix
        elseif type(extra_suffix) == "table" then
            for _, v in ipairs(extra_suffix) do
                table.insert(choices, t(v))
                context.name = context.name .. "|" .. v
            end
        else
            error("suffix should be a string or a table")
        end
        context.name = context.name .. ")"
    end
    return s(context,
        fmta([[
            \begin{<><>}
              <>
            \end{<><>}
    ]],
            { t(env_name), c(1, choices), i(2), t(env_name), rep(1) }),
        opts)
end

M.symbol_snippet = function(context, command, opts)
    opts = opts or {}
    if not context.trig then
        error("context doesn't include a `trig` key which is mandatory", 2)
    end
    context.dscr = context.dscr or command
    context.name = context.name or command
    context.docstring = context.docstring or command
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
    return s(
        context,
        fmta(command .. "{<><>}", { f(function(_, snip) return snip.env.LS_SELECT_RAW end), i(0) }),
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
    context.trigEngine = trigEngine
    local text = "\\" .. context.trig
    if trigEngine == "ecma" then
        context.trig = "(?<!\\\\)" .. "(" .. context.trig .. ")"
    elseif trigEngine == "pattern" then
        context.trig = "\\?" .. context.trig
    end
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

M.imap_snippet = function(context, alternates, opts)
    if not context.trig then
        error("context doesn't include a `trig` key which is mandatory", 2)
    end
    context.dscr = context.dscr or ""
    context.name = context.name or context.dscr
    if #alternates == 0 then
        return s(
            context,
            t("\\" .. context.name),
            opts
        )
    else
        local choices = { t("\\" .. context.name) }
        if type(alternates) == "string" then
            table.insert(choices, t("\\" .. alternates))
        elseif type(alternates) == "table" then
            for _, alternate in ipairs(alternates) do
                if type(alternate) ~= "string" then
                    error("element in alternates should be string if it is a table")
                end
                table.insert(choices, t("\\" .. alternate))
            end
        else
            error("alternates should be a string or a table of string")
        end
        return s(
            context,
            c(1, choices),
            opts
        )
    end
end

return M
