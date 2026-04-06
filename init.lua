_G.utils = require("utils")

require("options")
require("keymaps")
require("autocmd")

require("modules.appearence").init()
require("modules.lsp").init()
require("modules.treesitter").init()
require("modules.filebrowser").init()
require("modules.fuzzy").init()
require("modules.git").init()
require("modules.miscellaneous").init()
