---@class utils.functions
local M = {}

-- `zz' in normal mode
function M.centerCurrentLine()
    local win = vim.api.nvim_get_current_win()
    local row, column = unpack(vim.api.nvim_win_get_cursor(win))
    vim.api.nvim_command("normal! zz")
    vim.api.nvim_win_set_cursor(win, { row, column })
end

-- `<M-f>' and `<M-b>' in emacs
local ptn = "[%s%p]+"

---@param forward boolean true for forward search, vice versa.
function M.moveSingleWord(forward)
    local win = vim.api.nvim_get_current_win()
    local row, col = unpack(vim.api.nvim_win_get_cursor(win))
    local line = vim.fn.getline(".")
    local line_begin = 0
    local line_end = #line
    local i, j, s, pos

    if forward then
        s = line
        i, j = string.find(s, ptn, col + 1)
        if not i then
            pos = line_end
        elseif i == col + 1 then
            i = string.find(s, ptn, j + 1)
            if not i then
                pos = line_end
            else
                pos = i - 1
            end
        else
            pos = i - 1
        end
    else
        s = string.reverse(line)
        i, j = string.find(s, ptn, #line - col + 2)
        if not i then
            pos = line_begin
        elseif i == #line - col + 2 then
            i = string.find(s, ptn, j + 1)
            if not i then
                pos = line_begin
            else
                pos = #line - i + 1
            end
        else
            pos = #line - i + 1
        end
    end

    vim.api.nvim_win_set_cursor(win, { row, pos })
end

return M
