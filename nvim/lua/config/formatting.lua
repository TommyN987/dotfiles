-- Formatting: conform.nvim, on save with a toggle (design D15).
-- Formatters come from Mason (config.mason), except rustfmt (rustup).

vim.pack.add({
	{ src = "https://github.com/stevearc/conform.nvim", version = vim.version.range("9.*") },
})

-- biome where the project has a biome config, prettierd everywhere else.
local biome_or_prettier = { "biome", "prettierd", stop_after_first = true }

local format_on_save_enabled = true

require("conform").setup({
	formatters_by_ft = {
		javascript = biome_or_prettier,
		javascriptreact = biome_or_prettier,
		typescript = biome_or_prettier,
		typescriptreact = biome_or_prettier,
		css = biome_or_prettier,
		html = { "prettierd" },
		markdown = { "prettierd" },
		yaml = { "prettierd" },
		graphql = { "prettierd" },
		rust = { "rustfmt" },
		go = { "goimports", "gofumpt" },
		python = { "ruff_format" },
		lua = { "stylua" },
		sql = { "sqruff" },
		toml = { "taplo" },
	},
	formatters = {
		-- Without this, biome also runs in projects that only use prettier.
		biome = { require_cwd = true },
	},
	default_format_opts = { lsp_format = "fallback" },
	format_on_save = function()
		if format_on_save_enabled then
			return { timeout_ms = 1000 }
		end
	end,
})

vim.keymap.set({ "n", "x" }, "<leader>cf", function()
	require("conform").format({ async = true })
end, { desc = "Format buffer or selection" })

vim.keymap.set("n", "<leader>of", function()
	format_on_save_enabled = not format_on_save_enabled
	vim.notify("Format on save " .. (format_on_save_enabled and "on" or "off"))
end, { desc = "Toggle format on save" })
