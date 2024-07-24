local M = {}
local ptn = "[%w%p]+"

local function findPatternReverse(str, _init, pattern)
    local reversedStr = string.reverse(str)
    local init = string.len(str) - _init + 1
    local _, pos = string.find(reversedStr, pattern, init)
    if pos == nil then
        return _init
    end
    local originalPos = string.len(str) - pos
    return originalPos
end

local function moveSingleWord(forward)
    local current_win = vim.api.nvim_get_current_win()
    local current_buf = vim.api.nvim_win_get_buf(current_win)
    local current_row, current_col = unpack(vim.api.nvim_win_get_cursor(current_win))
    local current_line =
        vim.api.nvim_buf_get_lines(current_buf, vim.fn.line('.') - 1, vim.fn.line('.'), false)[1]
    local pos
    if forward then
        _, pos = string.find(current_line, ptn, current_col + 1)
        if pos == nil then
            pos = current_col
        end
    else
        pos = findPatternReverse(current_line, current_col, ptn)
    end
    vim.api.nvim_win_set_cursor(current_win, { current_row, pos })
end

function M.moveForwardWord()
    moveSingleWord(true)
end

function M.moveInverseWord()
    moveSingleWord(false)
end

return M
