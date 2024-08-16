---@class utils utils core
---@field move utils.move
---@field startup utils.startup
local M = {}

setmetatable(M, {
    __index = function (tbl, key)
        tbl[key] = require("utils." .. key)
        return tbl[key]
    end
})

return M
