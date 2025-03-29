---@class utils utils core
---@field icons utils.icons
---@field keybinds utils.keybinds
---@field config utils.config
---@field external utils.external
local M = {}

setmetatable(M, {
    __index = function(tbl, key)
        tbl[key] = require("utils." .. key)
        return tbl[key]
    end
})

return M
