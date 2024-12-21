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

local conditions = require("snippets.tex.utils.conditions")

local M = {}

local brackets = { -- recall that [b,p,v,B,V]matrix
    a = { "\\langle", "\\rangle" },
    b = { "[", "]" },
    p = { "(", ")" },
    v = { "\\lvert", "\\rvert" },
    B = { "\\lbrace", "\\rbrace" },
    V = { "\\lVert", "\\rVert" },
}

M.getSelectedText = function(_, snip)
    return snip.env.LS_SELECT_RAW
end

M.cases = function(_, snip)
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
end

M.leftRightBracket = fmta([[
    \left<> <><> \right<>
    ]], { f(function(_, snip)
    local cap = snip.captures[1]
    if brackets[cap] == nil then
        cap = "p"
    end
    return brackets[cap][1]
end),
    f(M.getSelectedText, {}),
    i(0),
    f(function(_, snip)
        local cap = snip.captures[1]
        if brackets[cap] == nil then
            cap = "p"
        end
        return brackets[cap][2]
    end),
})

M.getLabelPrefix = function(_, snip)
    if conditions.isInLabelEnv() then
        local env_dict = vim.fn["vimtex#env#get_inner"]()
        if env_dict then
            return env_dict["name"]
        end
    end
    return ""
end

M.extendScaffoldingSnippet = function(snippetTable, specs, scaffold, condition, requireArgument, contextExtra, preTrig)
    preTrig = preTrig or ""
    requireArgument = requireArgument or ""
    contextExtra = contextExtra or {}
    local extendingItems = {}
    for k, v in pairs(specs) do
        local context = { trig = v }
        local opts = {}
        if type(v) == "table" then
            context = vim.tbl_deep_extend(
                "keep",
                vim.tbl_deep_extend("keep", { trig = preTrig .. k }, contextExtra),
                v.context
            )
            opts = vim.tbl_deep_extend("keep", v.opts or {}, { condition = condition })
        end
        if requireArgument == "command" then
            table.insert(
                extendingItems,
                scaffold(context, v.command, opts)
            )
        elseif requireArgument == "extra_suffix" then
            table.insert(
                extendingItems,
                scaffold(context, v.extra_suffix or nil, opts)
            )
        else
            table.insert(
                extendingItems,
                scaffold(context, opts)
            )
        end
    end
    vim.list_extend(snippetTable, extendingItems)
end
return M
