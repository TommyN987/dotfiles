-- Language servers: built-in vim.lsp, server configs from nvim-lspconfig,
-- an explicit enable list (design D9). Linting comes from these servers too (D16).
-- Overrides of lspconfig's configs live in after/lsp/<server>.lua.

local health = require("config.health")
health.declare_tool({
	cmd = "rust-analyzer",
	needed_by = "rustaceanvim (from rustup: `rustup component add rust-analyzer`)",
	packages = { pacman = "rustup", apt = "rustup" },
})
health.declare_tool({
	cmd = "cargo",
	needed_by = "rustaceanvim (clippy checks)",
	packages = { pacman = "rustup", apt = "rustup" },
})

-- Read by rustaceanvim when it loads, so it must be set before vim.pack.add().
vim.g.rustaceanvim = {
	server = {
		default_settings = {
			["rust-analyzer"] = {
				check = { command = "clippy" },
			},
		},
	},
}

vim.pack.add({
	{ src = "https://github.com/neovim/nvim-lspconfig", version = vim.version.range("2.*") },
	-- Starts rust-analyzer itself, so rust_analyzer is not in the enable list.
	{ src = "https://github.com/mrcjkb/rustaceanvim", version = vim.version.range("9.*") },
})

vim.lsp.enable(require("config.mason").lsp_servers)

-- Signs in the gutter only (spec 4.2.4). <C-w>d opens the message, ]d / [d jump.
vim.diagnostic.config({
	virtual_text = false,
	virtual_lines = false,
	signs = true,
	-- With only signs to go on, a line's sign must show its most severe diagnostic.
	severity_sort = true,
})

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("config.lsp.keymaps", {}),
	desc = "Set LSP keymaps for the attached buffer",
	callback = function(event)
		local function map(lhs, rhs, desc)
			vim.keymap.set("n", lhs, rhs, { buffer = event.buf, desc = desc })
		end
		map("gD", vim.lsp.buf.declaration, "Go to declaration")
	end,
})

vim.keymap.set("n", "<leader>oh", function()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay hints" })
