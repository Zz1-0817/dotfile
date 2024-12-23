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
-- local ts_utils = require("nvim-treesitter.ts_utils")
-- local cursor_node = ts_utils.get_node_at_cursor()
-- if cursor_node ~= nil then
--     vim.print(cursor_node:type())
-- end

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
--
-- local jsregexp_ok, jsregexp = pcall(require, "luasnip-jsregexp")
-- if not jsregexp_ok then
--     jsregexp_ok, jsregexp = pcall(require, "jsregexp")
-- end
-- print(jsregexp_ok)

-- local tmp = {
--     "pi",
--     "nu",
--     "xi",
--     "mu",
--     "cap",
--     "cup",
--     "neq",
--     "leq",
--     "geq",
--     "sum",
--     "prod",
--     "int",
--     "dif",
--     "notin",
--     "to",
--     "mid",
--     "iff",
--     "quad",
--     "arcsin",
--     "sin",
--     "arccos",
--     "cos",
--     "arctan",
--     "tan",
--     "cot",
--     "csc",
--     "sec",
--     "log",
--     "ln",
--     "exp",
--     "ast",
--     "star",
--     "perp",
--     "sup",
--     "inf",
--     "det",
--     "max",
--     "min",
--     "argmax",
--     "argmin",
--     "deg",
--     "angle",
-- }
--
-- for k, v in pairs(tmp) do
--     local a = (type(v) == "table" and k or v)
--     print(a)
-- end


-- 函数：使用 curl 获取数据
local function fetch_url(url)
    local handle = io.popen("curl -s \"" .. url .. "\"")
    local result = handle:read("*a")
    handle:close()
    return result
end

-- 函数：解析 JSON 数据
local function parse_json(json_str)
    local json = {}
    local pos = 1
    local pattern = '"([%w_]+)"%s*:%s*"(.-)"'
    for key, value in string.gmatch(json_str, pattern) do
        json[key] = value
    end
    return json
end

-- 函数：获取日出和日落时间
local function get_sunrise_sunset(latitude, longitude, date)
    local url = string.format("https://api.sunrise-sunset.org/json?lat=%f&lng=%f&date=%s&formatted=0", latitude, longitude, date)
    local response = fetch_url(url)
    local data = parse_json(response)
    return data.sunrise, data.sunset
end

local latitude = 40.7128  -- 替换为你的纬度
local longitude = -74.0060  -- 替换为你的经度
local date = "2024-12-22"  -- 替换为你的日期

local sunrise, sunset = get_sunrise_sunset(latitude, longitude, date)
print("日出时间: " .. sunrise)
print("日落时间: " .. sunset)
