---@class utils.markup
local M = {
    in_math = function()
        local ft = vim.o.filetype
        if ft == "tex" then
            if string.find(vim.o["runtimepath"], "vimtex") then
                return vim.fn['vimtex#syntax#in_mathzone']() == 1
            else
                vim.notify("Vimtex is not installed yet.", vim.log.levels.INFO)
                return false
            end
        elseif ft == "markdown" then
            local parser = vim.treesitter.get_parser()
            if not parser then
                vim.notify("Markdown treesitter parser can't be found!", vim.log.levels.INFO)
                return false
            end

            local mkinl = parser:children()["markdown_inline"]
            if not mkinl then
                vim.notify("Treesitter 'markdown_inline' can't be found!", vim.log.levels.INFO)
                return false
            end

            local row, col = unpack(vim.api.nvim_win_get_cursor(0))
            row = row - 1

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
        return false
    end
}
return M
