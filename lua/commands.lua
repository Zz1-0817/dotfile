vim.api.nvim_create_user_command("BackgroundToggle", function ()
    if vim.o.background == 'dark' then
        vim.o.background = 'light'
    else
        vim.o.background = 'dark'
    end
end, { desc = "Toggle background" })
