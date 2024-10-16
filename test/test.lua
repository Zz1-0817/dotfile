-- Get window cursor position by neovim api
-- local row, col = unpack(vim.api.nvim_win_get_cursor(0))
-- vim.print(row, col)
--
-- Get cursor position by builtin function
-- local col = vim.fn.col('.')
-- local row = vim.fn.line('.')
-- local line = vim.fn.getline(row)
-- if string.find(line, "$$", 0, true) then
--     vim.print("1")
-- end
-- vim.print(vim.fn.getline(row))
--
-- Get the char under the cursor
-- local current_char = vim.fn.getline('.'):sub(col, col)
-- print(current_char)

-- Get the line number
-- local line_cnt = vim.api.nvim_buf_line_count(0)
-- vim.print(line_cnt)

-- Get TSnode by plugin treesitter method
local ts_utils = require("nvim-treesitter.ts_utils")
local cursor_node = ts_utils.get_node_at_cursor()
if cursor_node ~= nil then
    vim.print(cursor_node:type())
end

-- Get TSnode by builtin neovim method
-- local cursor_node = vim.treesitter.get_node()
-- if cursor_node ~= nil then
    -- vim.print(cursor_node:type())
    -- vim.print(cursor_node:named())
    -- vim.print(cursor_node:id())
    -- vim.print(cursor_node:sexpr())
    -- vim.print(cursor_node:range())

    -- Parent
    -- local parent_node = cursor_node:parent()
    -- if parent_node ~= nil then
    --     vim.print(parent_node:type())
    -- end

    -- Children
    -- local child_cnt = cursor_node:child_count()
    -- for i = 1, child_cnt do
    --     local child_node = cursor_node:child(1)
    --     if child_node ~= nil then
    --         vim.print(child_node:type())
    --     end
    -- end
-- end
