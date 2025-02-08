---@class utils utils core
---@field icons utils.icons
---@field functions utils.functions
---@field config utils.config
local M = {}

setmetatable(M, {
    __index = function(tbl, key)
        tbl[key] = require("utils." .. key)
        return tbl[key]
    end
})

return M
