local line_begin = require("luasnip.extras.conditions.expand").line_begin

local M = {
    s({ trig = "date", desc = "Insert current date" },
    {t(vim.fn.strftime("%Y %b %d"))},
    {condition = line_begin})
}

return M
