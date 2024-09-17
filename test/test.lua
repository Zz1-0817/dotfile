local ts_utils = require("nvim-treesitter.ts_utils")

-- Plugin Treesitter Method
local cursor_node = ts_utils.get_node_at_cursor()
if cursor_node ~= nil then
    vim.print(cursor_node:type())
end

-- Builtin Neovim Method
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
