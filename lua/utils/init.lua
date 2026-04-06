---@class utils utils core
---@field icons utils.icons
---@field edit utils.edit
---@field markup utils.markup
local M = {}

setmetatable(M, {
    __index = function(tbl, key)
        tbl[key] = require("utils." .. key)
        return tbl[key]
    end
})

return M
