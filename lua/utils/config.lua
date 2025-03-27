---@class utils.config
local M = {
    mason = {},
    obsidian = {
        workspaces = {
            {
                name = "personal",
                path = "~/vaults/personal",
            },
        },
    },
    servers = {}
}
return vim.tbl_deep_extend('force', M, require("config") or {})
