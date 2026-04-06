return {
    init = function()
        vim.pack.add({
            { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" }
        })
        require("nvim-treesitter").install({ "cpp", "css", "html", "javascript", "typescript", "typst", "python"
        })
    end
}
