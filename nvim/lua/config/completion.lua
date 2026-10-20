-- Completion: blink.cmp v1 (design D11). No snippet source (D12); default keys
-- (<C-y> accept, <C-n>/<C-p> move, <C-e> close, <C-space> open).

vim.pack.add({
	-- On a release tag blink downloads its prebuilt Rust matcher during setup().
	-- main is v2, which has breaking changes.
	{ src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },
})

require("blink.cmp").setup({
	keymap = { preset = "default" },
	sources = {
		default = { "lsp", "path", "buffer" },
	},
	fuzzy = { implementation = "prefer_rust_with_warning" },
})
