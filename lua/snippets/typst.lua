local s = require("luasnip").snippet
local i = require("luasnip").insert_node
local t = require("luasnip").text_node
local fmta = require("luasnip.extras.fmt").fmta

local M = {}

local thms = {
    def = { title = "definition", named = true },
    lem = "lemma",
    prp = "proposition",
    thm = "theorem",
    cor = "corollary",
    eg = "example",
    rmk = "remark",
    pf = "proof"
}

for trig, thm in pairs(thms) do
    if type(thm) == "table" and thm.named then
        table.insert(M, s(
            { trig = trig, name = thm.title, dscr = thm.title },
            fmta([[
            #<>([<>])[
              <>
            ]
            ]], { t(thm.title), i(1), i(0) })
        ))
    elseif type(thm) == "string" then
        table.insert(M, s(
            { trig = trig, name = thm, dscr = thm },
            fmta([[
            #<>[
              <>
            ]
            ]], { t(thm), i(0) })
        ))
    end
end

return M
