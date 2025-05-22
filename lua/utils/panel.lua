local Panel = {
    panels = {},
    initial_panel = "terminal",
    last_panel = nil,
    layout = {
        height = math.floor(0.35 * vim.o.lines),
        split = "below"
    },
}
Panel.__index = Panel

---Generate panel template
---@return table panel
function Panel:generate_panel()
    local obj = {}
    setmetatable(obj, self)
    return obj
end

function Panel:toggle()
end

local terminal = Panel:generate_panel()
---Create a terminal
function terminal:create()
    vim.api.nvim_open_win(0, true, terminal.layout)
    vim.cmd.terminal()
    local buf = vim.api.nvim_get_current_buf()
    vim.bo.buflisted = false
    terminal.panels[buf] = {
        panel_type = "terminal",
        job_id = vim.b.terminal_job_id
    }
    self.opening_win = vim.api.nvim_get_current_win()
    self.last_buf = buf
    vim.cmd.startinsert()
end

---Delete a terminal
function terminal:collapse()
end

function terminal:toggle()
    if self.opening_win then
        vim.api.nvim_win_hide(self.opening_win)
        self.opening_win = nil
    elseif self.last_buf then
        self.opening_win = vim.api.nvim_open_win(self.last_buf, true, self.layout)
    else
        self:create()
    end
end

local quickfix = Panel:generate_panel()

function quickfix.create()
    local height = Panel.layout.height or math.floor(0.35 * vim.o.lines)
    vim.diagnostic.setqflist({ open = false })
    vim.cmd("copen " .. height)
end

---@class utils.panel
local M = {
    terminal = terminal,
    quickfix = quickfix
}

return M
