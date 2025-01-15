vim.opt.swapfile = false
vim.opt.splitright = true
vim.opt.list = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.encoding = "utf-8"
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.cursorline = true
vim.opt.cursorcolumn = false
vim.opt.mouse = 'a'
vim.opt.clipboard = ""
vim.opt.termguicolors = true
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.updatetime = 300
vim.opt.signcolumn = "yes"
vim.opt.pumheight = 15
vim.opt.pumblend = 15
vim.opt.laststatus = 3
vim.opt.splitkeep = "screen"
vim.opt.mousemoveevent = true
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

if vim.fn.has("nvim-0.10") == 1 then
    vim.opt.smoothscroll = true
end

vim.diagnostic.config({
    underline = true,
    update_in_insert = false,
    virtual_text = false,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = utils.icons.diagnostics.Error,
            [vim.diagnostic.severity.WARN] = utils.icons.diagnostics.Warn,
            [vim.diagnostic.severity.HINT] = utils.icons.diagnostics.Hint,
            [vim.diagnostic.severity.INFO] = utils.icons.diagnostics.Info,
        }
    },
    linehl = {
        [vim.diagnostic.severity.ERROR] = 'ErrorMsg',
    },
    numhl = {
        [vim.diagnostic.severity.WARN] = 'WarningMsg',
    },
    severity_sort = true,
    document_highlight = {
        enabled = true,
    },
})
