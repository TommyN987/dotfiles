require("config.options")
require("config.keymaps")
require("config.filetypes")
-- Must load before any capability module calls vim.pack.add().
require("config.pack")

-- Capability modules (docs/spec.md §3–§12) are added below as they are built.
require("config.ui")
-- Before anything that runs a Mason-installed tool.
require("config.mason")
require("config.treesitter")
require("config.lsp")
require("config.completion")
require("config.formatting")
require("config.navigation")
require("config.git")
require("config.debug")
require("config.test")
require("config.database")
