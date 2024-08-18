---@class utils utils core
---@field move utils.move
---@field startup utils.startup
---@field icons utils.icons
local M = {}

setmetatable(M, {
    __index = function(tbl, key)
        tbl[key] = require("utils." .. key)
        return tbl[key]
    end
})

function M.has(plugin)
    local tmp = require("lazy.core.config").spec.plugins[plugin]
    return tmp ~= nil
end

return M
