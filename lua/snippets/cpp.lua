local s = require("luasnip").snippet
local i = require("luasnip").insert_node
local fmt = require("luasnip.extras.fmt").fmt

local M = {
    s({ trig = "oi", dscr = "Competitive Programming Library" },
        fmt([[
        #include <bits/stdc++.h>

        using namespace std;

        {}
        ]], { i(0) })
    )
}

return M
