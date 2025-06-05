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
            if string.find(vim.o["runtimepath"], "vim-markdown", 0, true) then
                local syn_ids = vim.fn.synstack(vim.fn.line("."), vim.fn.col("."))
                local syn_names = vim.tbl_map(function(id)
                    return vim.fn.synIDattr(id, "name")
                end, syn_ids)
                return table.concat(syn_names, ""):find("Math")
            end
        end
        return false
    end
}
return M
