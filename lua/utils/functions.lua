---@class utils.functions
local M = {}

-- `zz' in normal mode
M.centerCurrentLine = function()
    local win = vim.api.nvim_get_current_win()
    local row, column = unpack(vim.api.nvim_win_get_cursor(win))
    vim.api.nvim_command("normal! zz")
    vim.api.nvim_win_set_cursor(win, { row, column })
end

-- `<M-f>' and `<M-b>' in emacs
local ptn = "[\u{4e00}-\u{9fa5}%w%p]+"

---@param str string original string
---@param _init integer initial position
---@param pattern string pattern to match
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

---@param is_forward boolean true for forward search, vice versa.
M.moveSingleWord = function(is_forward)
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_win_get_buf(win)
    local row, col = unpack(vim.api.nvim_win_get_cursor(win))
    local line =
        vim.api.nvim_buf_get_lines(buf, vim.fn.line('.') - 1, vim.fn.line('.'), false)[1]
    local pos
    if is_forward then
        _, pos = string.find(line, ptn, col + 1)
        if pos == nil then
            pos = col
        end
    else
        pos = findPatternReverse(line, col, ptn)
    end
    vim.api.nvim_win_set_cursor(win, { row, pos })
end

return M
