local keyset = vim.keymap.set
local opts = { noremap = true, silent = true }

keyset('i', "<C-f>", "<right>", opts)
keyset('i', "<C-b>", "<left>", opts)
keyset('i', "<C-n>", "<down>", opts)
keyset('i', "<C-p>", "<up>", opts)

keyset('i', "<M-f>", function() utils.functions.moveSingleWord(true) end, opts)
keyset('i', "<M-b>", function() utils.functions.moveSingleWord(false) end, opts)

keyset('i', "<C-l>", utils.functions.centerCurrentLine, opts)

keyset('i', "<C-e>", "<End>", opts)
keyset('i', "<C-a>", "<Home>", opts)
keyset('i', "<C-y>", '<C-r>"', opts)
keyset("n", "<leader>w", "<CMD>w<CR>", opts)
keyset('i', "<C-space>", " ", opts) -- for gui, avoid touching by mistake

keyset({ 'n', 'o', 'x' }, "<C-a>", "^", opts)
keyset({ 'n', 'o', 'x' }, "<C-e>", "$", opts)

keyset("n", "<leader>qd", function()
    vim.diagnostic.setqflist({
        open = true,
        title = "Diagnostics",
    })
end, { desc = "populate quickfix with diagnostics" })

keyset("n", "<C-\\>", utils.functions.enterLastTerminal, opts)
