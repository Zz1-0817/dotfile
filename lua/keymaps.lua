local keyset = vim.keymap.set
local opts = { noremap = true, silent = true }

keyset('i', "<C-f>", "<right>", opts)
keyset('i', "<C-b>", "<left>", opts)
keyset('i', "<C-n>", "<down>", opts)
keyset('i', "<C-p>", "<up>", opts)

keyset('i', "<M-f>", function() utils.edit.next_ptn(true) end, opts)
keyset('i', "<M-b>", function() utils.edit.next_ptn(false) end, opts)

keyset('i', "<C-l>", utils.edit.center, opts)

keyset('i', "<C-e>", "<End>", opts)
keyset('i', "<C-a>", utils.edit.begin, opts)
keyset('i', "<C-y>", '<C-r>"', opts)
keyset("n", "<leader>w", function() vim.cmd.write() end, opts)
keyset('i', "<C-space>", " ", opts) -- for gui, avoid touching by mistake

keyset({ 'n', 'o', 'x' }, "<C-a>", "^", opts)
keyset({ 'n', 'o', 'x' }, "<C-e>", "$", opts)

keyset({ 'n' }, "<C-_>", function() utils.panel.quickfix.create() end, opts)
keyset({ 'n', 't' }, "<C-\\>", function () utils.panel.terminal:toggle() end, opts)
