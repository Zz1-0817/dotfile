-- vim.print(vim.fn.stdpath("config"))
-- vim.diagnostic.config({
--     signs = {
--         text = {
--             [vim.diagnostic.severity.ERROR] = 'a',
--             [vim.diagnostic.severity.WARN] = '',
--             [vim.diagnostic.severity.HINT] = utils.icons.diagnostics.Info,
--         },
--         linehl = {
--             [vim.diagnostic.severity.ERROR] = 'ErrorMsg',
--         },
--         numhl = {
--             [vim.diagnostic.severity.WARN] = 'WarningMsg',
--         },
--     },
-- })
-- local cliptext = vim.fn.getreg(':')
-- vim.print(cliptext)
-- local npairs = require("nvim-autopairs")
-- vim.print(npairs.get_rule('"'))
local tmp = nil
if not tmp then
    vim.print("1")
else
    vim.print("2")
end
