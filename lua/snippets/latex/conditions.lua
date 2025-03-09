local make_condition = require("luasnip.extras.conditions").make_condition
M = {}

M.valid_prefix_backslash = make_condition(function(_, _, captures)
    if (#captures[2] > 0) or (#captures[1] == 0) then
        return true
    end
    return false
end)

M.not_prefix_backslash = make_condition(function (_, _, captures)
    if (#captures[1] > 0) then
        return false
    end
    return true
end)

return M
