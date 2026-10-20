require("config.options")
require("config.keymaps")
require("config.filetypes")
-- Must load before any capability module calls vim.pack.add().
require("config.pack")

-- Capability modules (docs/spec.md §3–§12) are added below as they are built.
require("config.ui")
