return {
    {
        "folke/todo-comments.nvim",
        event = { "bufreadpost", "bufwritepost", "bufnewfile" },
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {}
    },
}
