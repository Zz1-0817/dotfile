local keyset = vim.keymap.set
local opts = { noremap = true, silent = true }

keyset('i', "<C-f>", "<right>", opts)
keyset('i', "<C-b>", "<left>", opts)
keyset('i', "<C-n>", "<down>", opts)
keyset('i', "<C-p>", "<up>", opts)

keyset('i', "<M-f>", utils.move.moveForwardWord, opts)
keyset('i', "<M-b>", utils.move.moveInverseWord, opts)

keyset('i', "<C-l>", "<C-o>zz", opts)
keyset('i', "<C-e>", "<End>", opts)
keyset('i', "<C-a>", "<Home>", opts)
keyset('i', "<C-y>", "<C-o>p", opts)
keyset("n", "<leader>w", "<CMD>w<CR>", opts)
keyset('i', "<C-space>", " ", opts) -- for gui, avoid touching by mistake

keyset({ 'n', 'o', 'x' }, "<C-a>", "^", opts)
keyset({ 'n', 'o', 'x' }, "<C-e>", "$", opts)
