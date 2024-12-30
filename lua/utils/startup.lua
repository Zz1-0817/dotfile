---@class utils.startup
local M = {}

M.check_colorscheme = function()
    local hour = tonumber(os.date("%H"))
    if (hour >= 7 and hour < 16) then
        vim.opt.background = "light"
        return "nightfox"
    else
        vim.opt.background = "dark"
        -- return "tokyonight"
        return "catppuccin"
    end
end

return M
