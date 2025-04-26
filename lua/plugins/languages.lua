return {
    { "jannis-baum/vivify.vim", cond = vim.fn.executable('viv'), },
    {
        "lervag/vimtex",
        init = function()
            if jit.os ~= 'Windows' then
                vim.g.vimtex_view_method = 'zathura'
            end

            vim.g.vimtex_quickfix_ignore_filters = {
                "Missing character: There",
                "Package xeCJK Warning: Undefined",
                "Package xeCJK Warning: Unknown",
                "Package xeCJK Warning: Fandol",
                "Package fontspec Warning: Font",
                "LaTeX Font Warning: Font shape",
                "Package tcolorbox Warning: Using nobreak failed",
                "Empty bibliography",
                "You have requested",
                "Overfull",
                "Underfull",
                "Package unicode-math",
                "Some font shapes were not available"
            }
            vim.g.vimtex_imaps_enabled = false
            vim.g.vimtex_fold_enabled = true
            vim.g.vimtex_fold_bib_enabled = true
            vim.g.vimtex_mappings_disable = {
                i = { "]]" }
            }
            -- vim.g.vimtex_env_toggle_math_map = {
            --     equation =  "\\(",
            --     ['$'] =  '\\(',
            --     ['$$'] =  '\\[',
            --     ['\\['] =  "equation",
            --     ['\\('] =  "\\["
            -- }
        end,
    },
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },
}
