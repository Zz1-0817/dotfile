---@class utils.external
local M = {
    markdown = {
        in_math = function()
            local row, col = unpack(vim.api.nvim_win_get_cursor(0))
            row = row - 1
            local parser = vim.treesitter.get_parser()
            if not parser then
                return false
            end
            local mkinl = parser:children()["markdown_inline"]
            if not mkinl then
                return false
            end

            if mkinl:contains({ row, col, row, col }) then
                local node = mkinl:named_node_for_range({ row, col, row, col })
                if not node then
                    return false
                end
                local node_type = node:type()
                if node_type and string.find(node_type, "latex") then
                    return true
                end
            end
            return false
        end
    },
    latex = {
        in_math = function()
            return vim.fn['vimtex#syntax#in_mathzone']() == 1
        end
    }
}
return M
