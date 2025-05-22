---@class utils.edit
local M = {}

-- `zz' in normal mode
function M.center()
    local win = vim.api.nvim_get_current_win()
    local row, column = unpack(vim.api.nvim_win_get_cursor(win))
    vim.cmd("normal! zz")
    vim.api.nvim_win_set_cursor(win, { row, column })
end

---Move cursor to the position before next pattern
---@param direction boolean true for forward search, vice versa.
function M.next_ptn(direction, ptn)
    if not ptn then
        ptn = "[%s%p]+"
    end
    local win = vim.api.nvim_get_current_win()
    local row, col = unpack(vim.api.nvim_win_get_cursor(win))
    local line = vim.fn.getline(row)
    local lines = vim.api.nvim_buf_line_count(0)
    local line_begin = 0
    local line_end = #line
    local i, j, s, pos

    if direction then
        if col == line_end then
            if row < lines then
                row = row + 1
                line = vim.fn.getline(row)
                col = 0
            end
        end
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
        if col == line_begin then
            if row > 1 then
                row = row  - 1
                line = vim.fn.getline(row)
                col = #line
            end
        end
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

function M.begin()
    local win = vim.api.nvim_get_current_win()
    local row = unpack(vim.api.nvim_win_get_cursor(win))
    local line = vim.fn.getline(row)
    local pos = string.find(line, "[^\t ]")
    if pos then
        vim.api.nvim_win_set_cursor(win, { row, pos - 1 })
    else
        vim.api.nvim_win_set_cursor(win, { row, 0 })
    end
end

return M
