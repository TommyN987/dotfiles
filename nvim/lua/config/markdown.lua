-- Markdown rendered in the buffer (spec §12.1); editing settings are in
-- after/ftplugin/markdown.lua. silkcircuit themes it (config.ui).

vim.pack.add({
	{ src = "https://github.com/MeanderingProgrammer/render-markdown.nvim", version = vim.version.range("8.*") },
})

require("render-markdown").setup()
