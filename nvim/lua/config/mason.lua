-- Mason: the one list of external tools a fresh clone installs (design D5).
-- The Rust toolchain (rust-analyzer, rustfmt, clippy) comes from rustup instead (D4).

local M = {}

local health = require("config.health")
health.declare_tool({
	cmd = "npm",
	needed_by = "Mason (npm-based tools: tsc, prettierd, eslint, …)",
	packages = { pacman = "npm", apt = "npm" },
})
health.declare_tool({
	cmd = "python3",
	needed_by = "Mason (Python-based tools: ruff, basedpyright)",
	packages = { pacman = "python", apt = "python3-venv" },
})
health.declare_tool({
	cmd = "go",
	needed_by = "Mason (Go-based tools: gopls, gofumpt, goimports)",
	packages = { pacman = "go", apt = "golang-go" },
})

--- Language servers Mason installs, by lspconfig name. config.lsp enables exactly these.
M.lsp_servers = {
	"tsc",
	"tailwindcss",
	"cssls",
	"html",
	"emmet_language_server",
	"eslint",
	"biome",
	"gopls",
	"basedpyright",
	"ruff",
	"graphql",
	"postgres_lsp",
	"sqruff",
	"taplo",
	"yamlls",
	"marksman",
	"lua_ls",
}

--- Everything else Mason installs, by Mason package name.
local other_tools = {
	-- config.treesitter: compiles parsers
	"tree-sitter-cli",
	-- config.formatting
	"prettierd",
	"stylua",
	"gofumpt",
	"goimports",
	-- config.debug (codelldb is picked up by rustaceanvim)
	"codelldb",
	"js-debug-adapter",
	"delve",
	"debugpy",
}

vim.pack.add({
	{ src = "https://github.com/mason-org/mason.nvim", version = vim.version.range("2.*") },
	-- Only for its lspconfig-name -> Mason-package mapping. Its setup() is never
	-- called, because that would enable every installed server (rejected in D9).
	{ src = "https://github.com/mason-org/mason-lspconfig.nvim", version = vim.version.range("2.*") },
	{ src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
})

-- Puts Mason's bin directory on $PATH, so it must run before any tool starts.
require("mason").setup()

require("mason-tool-installer").setup({
	ensure_installed = vim.list_extend(vim.deepcopy(M.lsp_servers), other_tools),
})

return M
