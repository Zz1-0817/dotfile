local keyset = vim.keymap.set
local opts = { noremap = true, silent = true }

keyset('i', "<C-f>", "<right>", opts)
keyset('i', "<C-b>", "<left>", opts)
keyset('i', "<C-n>", "<down>", opts)
keyset('i', "<C-p>", "<up>", opts)
keyset('i', "<M-b>", "<C-left>", opts)
keyset('i', "<M-f>", "<C-right>", opts)

keyset('i', "<C-l>", "<Esc>zza", opts)
keyset('i', "<C-e>", "<End>", opts)
keyset('i', "<C-a>", "<Home>", opts)
keyset('i', "<C-y>", "<Esc>pa", opts)
keyset("n", "<leader>w", "<CMD>w<CR>", opts)

keyset('i', "<C-space>", " ", opts) -- for gui, avoid touching by mistake

keyset({ 'n', 'o', 'x' }, "<C-a>", "^", opts)
keyset({ 'n', 'o', 'x' }, "<C-e>", "$", opts)
