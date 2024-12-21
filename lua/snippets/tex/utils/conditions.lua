local M = {}

----Helper Functions------

local isInEnv = function(name)
    local is_inside = vim.fn['vimtex#env#is_inside'](name)
    return (is_inside[1] > 0 and is_inside[2] > 0)
end

local function checkEnvs(envList)
    for _, name in ipairs(envList) do
        if isInEnv(name) then
            return true
        end
    end
    return false
end

--------------------------

local env = {
    thm = {
        "definition", "lemma", "theorem", "proposition",
        "corollary", "example", "remark", "proof"
    },
    label = {
        "definition", "lemma", "theorem", "proposition",
        "corollary", "example", "remark", "equation"
    },
    item = {
        "description", "itemize", "enumerate"
    }
}

M.isInMathZone = function()
    return vim.fn['vimtex#syntax#in_mathzone']() == 1
end

M.isInTextZone = function()
    return vim.fn['vimtex#syntax#in_mathzone']() ~= 1
end

M.isInEnumerate = function()
    return not M.isInMathZone() and checkEnvs(env.item)
end

M.isInLabelEnv = function()
    return checkEnvs(env.label)
end

M.isNotInTheorem = function()
    return not M.isInMathZone() and not checkEnvs(env.thm)
end

return M
