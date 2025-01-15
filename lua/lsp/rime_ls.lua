local rime_on_attach = function(client, _)
    local toggle_rime = function()
        client.request('workspace/executeCommand',
            { command = "rime-ls.toggle-rime" },
            function(_, result, ctx, _)
                if ctx.client_id == client.id then
                    vim.g.rime_enabled = result
                end
            end
        )
    end
    -- keymaps for executing command
    vim.keymap.set('i', '<C-x>', toggle_rime, { desc = 'Toggle Rime' })
end

local M = {
    name = "rime_ls",
    cmd = { 'rime_ls' },
    filetypes = { 'markdown' },
    single_file_support = true,
    init_options = {
        enabled = vim.g.rime_enabled,
        shared_data_dir = "~/Library/Rime",
        user_data_dir = "~/.local/share/rime-ls",
        log_dir = "/tmp",
        max_candidates = 9,
        paging_characters = { "-", "=" },
        trigger_characters = {},
        schema_trigger_character = "&",
        max_tokens = 4,
        always_incomplete = true,
        preselect_first = false,
    },
    on_attach = rime_on_attach,
}

return M
