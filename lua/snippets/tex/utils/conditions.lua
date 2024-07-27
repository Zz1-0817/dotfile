local M = {}

local in_env = function(name)
    local is_inside = vim.fn['vimtex#env#is_inside'](name)
    return (is_inside[1] > 0 and is_inside[2] > 0)
end

local thm_env = {
    "definition", "lemma", "theorem", "proposition",
    "corollary", "example", "remark", "proof" }

local item_env = { "description", "itemize", "enumerate" }

M.in_math = function()
    return vim.fn['vimtex#syntax#in_mathzone']() == 1
end

M.in_text = function()
    return vim.fn['vimtex#syntax#in_mathzone']() ~= 1
end

M.in_enum = function ()
    if M.in_math() then
        return false
    end
    for _, name in ipairs(item_env) do
        if in_env(name) then
            return true
        end
    end
    return false
end

M.notin_thm = function()
    if M.in_math() then
        return false
    end
    for _, name in ipairs(thm_env) do
        if in_env(name) then
            return false
        end
    end
    return true
end

return M
