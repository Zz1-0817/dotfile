return {
    {
        "kevinhwang91/nvim-bqf",
        ft = "qf",
        config = function()
            local config = require('bqf.config')
            config['preview']['border'] = 'shadow'
            config['preview']['how_scroll_bar'] = false
            require("bqf").setup(config)
        end
    }
}
