-- Treesitter: parsers and highlighting (nvim-treesitter `main`).
-- Its build step (:TSUpdate after a plugin update) is in config.pack.

local health = require("config.health")
for _, cmd in ipairs({ "cc", "curl", "tar" }) do
	health.declare_tool({ cmd = cmd, needed_by = "nvim-treesitter (installing parsers)" })
end
health.declare_tool({
	cmd = "tree-sitter",
	needed_by = "nvim-treesitter (compiling parsers; installed by Mason)",
	min_version = "0.26.1",
})

vim.pack.add({
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
})

local parsers = {
	"bash",
	"css",
	"go",
	"graphql",
	"html",
	"javascript",
	"json",
	"lua",
	"markdown",
	"markdown_inline",
	"python",
	"rust",
	"sql",
	"surrealql",
	"toml",
	"tsx",
	"typescript",
	"yaml",
}

-- SurrealQL isn't in nvim-treesitter's list. Pinned, so an update can't change
-- .surql highlighting unannounced.
vim.api.nvim_create_autocmd("User", {
	group = vim.api.nvim_create_augroup("config.treesitter.surrealql", {}),
	pattern = "TSUpdate",
	desc = "Register the SurrealQL parser with nvim-treesitter",
	callback = function()
		require("nvim-treesitter.parsers").surrealql = {
			install_info = {
				url = "https://github.com/surrealdb/surrealql-tree-sitter",
				revision = "329dcec0a057e4bc25d71e2c97e16c391573ecb0",
				queries = "queries",
			},
		}
	end,
})
vim.treesitter.language.register("surrealql", { "surql" })

-- No-op for parsers already installed; runs in the background.
require("nvim-treesitter").install(parsers)

-- On a fresh clone the tree-sitter CLI arrives from Mason only after startup,
-- so the first install attempt fails; retry once Mason has finished.
vim.api.nvim_create_autocmd("User", {
	group = vim.api.nvim_create_augroup("config.treesitter.install", {}),
	pattern = "MasonToolsUpdateCompleted",
	desc = "Install missing parsers once Mason has installed tree-sitter",
	callback = function()
		require("nvim-treesitter").install(parsers)
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("config.treesitter.highlight", {}),
	desc = "Start treesitter highlighting when a parser is installed",
	callback = function(event)
		local lang = vim.treesitter.language.get_lang(event.match)
		if lang and vim.treesitter.language.add(lang) then
			vim.treesitter.start(event.buf, lang)
		end
	end,
})
