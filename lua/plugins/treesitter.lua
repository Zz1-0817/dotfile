return {
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        branch = "main",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").install({
                "cpp", "css", "html", "javascript", "typescript", "typst", "python"
            })
        end
    },
}
