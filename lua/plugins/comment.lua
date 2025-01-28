return {
    {
        'echasnovski/mini.comment',
        event = { "bufreadpost", "bufwritepost", "bufnewfile" },
        version = false,
        opts = {}
    },
    {
        "folke/todo-comments.nvim",
        event = { "bufreadpost", "bufwritepost", "bufnewfile" },
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {}
    },
}
