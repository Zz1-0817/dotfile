return {
    {
        "luukvbaal/statuscol.nvim",
        init = function()
            vim.o.fillchars = [[eob: ,fold: ,foldopen:󰅀,foldsep: ,foldclose:]]
            vim.o.foldcolumn = "1"
            vim.o.foldenable = true
        end,
        config = function()
            local builtin = require("statuscol.builtin")
            require("statuscol").setup({
                relculright = true,
                segments = {
                    { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
                    { text = { builtin.lnumfunc }, click = "v:lua.ScLa" },
                    {
                        sign = { namespace = { "gitsigns" } },
                        click = "v:lua.ScSa"
                    },
                    {
                        sign = { namespace = { "diagnostic/signs" } },
                        click = "v:lua.ScSa"
                    },
                },
            })
        end,
    },
}
