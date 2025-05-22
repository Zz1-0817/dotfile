local d = require("luasnip").dynamic_node
local i = require("luasnip").insert_node
local t = require("luasnip").text_node
local s = require("luasnip").snippet
local r = require("luasnip").restore_node
local f = require("luasnip").function_node
local sn = require("luasnip").snippet_node
local fmta = require("luasnip.extras.fmt").fmta
local make_condition = require("luasnip.extras.conditions").make_condition
local postfix = require("luasnip.extras.postfix").postfix
local commands = require("snippets.latex.commands")

local getPostfixDynamicNode = function(_, parent, _, user_arg1, user_arg2)
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

local brackets = { -- recall that [b,p,v,B,V]matrix
    a = { "\\langle", "\\rangle" },
    b = { "[", "]" },
    p = { "(", ")" },
    v = { "\\lvert", "\\rvert" },
    B = { "\\lbrace", "\\rbrace" },
    V = { "\\lVert", "\\rVert" },
}

local default = {
    autobackslash = true,
    imap = true,
    symbol = true,
    postfixmath = true,
    bracket = true,
    cases = true,
    in_math = nil
}

local M = {
    load = function(config)
        config = vim.tbl_extend("force", default, config or {})
        local latex_specs = {}
        local in_math = nil


        local text_snippet_condition = make_condition(function(_, _, captures)
            if (#captures[2] > 0) or (#captures[1] == 0) then
                return true
            end
            return false
        end)

        local text_snippet_format = function(context, opts, command)
            context.trigEngine = "pattern"
            context.trig = "([%w\\]*)(_?)" .. context.trig

            opts.condition = in_math and in_math * text_snippet_condition or text_snippet_condition
            return f(function(_, snippet)
                if #snippet.captures[2] > 0 then
                    return snippet.captures[1] .. snippet.captures[2] .. "{" .. command .. "}"
                else
                    return command
                end
            end)
        end

        if config.in_math then
            in_math = make_condition(config.in_math)
        end

        if config.autobackslash then
            for _, spec in ipairs(commands.autobackslash) do
                local context = vim.deepcopy(spec.context)
                local opts = { condition = in_math }
                context.snippetType = "autosnippet"
                table.insert(
                    latex_specs,
                    s(context, text_snippet_format(context, opts, spec.command), opts)
                )
            end
        end

        if config.imap then
            for _, spec in ipairs(commands.imap) do
                local context = vim.deepcopy(spec.context)
                local opts = { condition = in_math }
                context.snippetType = "autosnippet"
                if context.trigEngine == "plain" then
                    context.wordTrig = false
                    table.insert(
                        latex_specs,
                        s(context, t(spec.command), opts)
                    )
                else
                    table.insert(
                        latex_specs,
                        s(context, text_snippet_format(context, opts, spec.command), opts)
                    )
                end
            end
        end

        if config.symbol then
            for _, spec in ipairs(commands.symbol) do
                local context = vim.deepcopy(spec.context)
                local opts = { condition = in_math }
                context.snippetType = "autosnippet"
                if context.trigEngine == "plain" then
                    context.wordTrig = false
                    table.insert(
                        latex_specs,
                        s(context, t(spec.command), opts)
                    )
                else
                    table.insert(
                        latex_specs,
                        s(context, text_snippet_format(context, opts, spec.command), opts)
                    )
                end
            end
        end

        if config.postfixmath then
            for _, spec in ipairs(commands.postfixmath) do
                local context = vim.deepcopy(spec.context)
                context.snippetType = "autosnippet"
                local opts = { condition = in_math }
                context.match_pattern = context.match_pattern or [[[%w%.%_%-%"%']*$]]
                table.insert(
                    latex_specs,
                    postfix(context,
                        { d(1, getPostfixDynamicNode, {}, { user_args = { spec.command .. '{', '}' } }) }, opts)
                )
            end
        end

        if config.bracket then
            local context = {
                trig = "lr([abpvBV])",
                name = "left right",
                dscr = "left right delimiters",
                trigEngine = "pattern",
                snippetType = "autosnippet",
            }
            local opts = { condition = in_math }
            table.insert(
                latex_specs,
                s(context, fmta([[\left<> <><> \right<>]],
                    { f(function(_, snip)
                        local cap = snip.captures[1]
                        if brackets[cap] == nil then
                            cap = "p"
                        end
                        return brackets[cap][1]
                    end),
                        f(function(_, snip)
                            return snip.env.LS_SELECT_RAW
                        end), i(0), f(function(_, snip)
                        local cap = snip.captures[1]
                        if brackets[cap] == nil then
                            cap = "p"
                        end
                        return brackets[cap][2]
                    end), }), opts)
            )
        end

        if config.cases then
            local context = {
                trig = "(%d?)cases",
                name = "cases",
                dscr = "cases",
                trigEngine = "pattern",
                snippetType = "autosnippet"
            }
            local opts = { condition = in_math }
            table.insert(
                latex_specs,
                s(context, fmta([[
                \begin{cases}
                <>
                \end{cases}
                ]],
                    { d(1, function(_, snip)
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
                    end) }), opts)
            )
        end
        return latex_specs
    end
}

return M
