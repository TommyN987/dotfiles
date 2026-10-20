-- Interface: messages, colorscheme, icons, statusline, keymap hints.

-- Before vim.pack.add(), so install progress already uses the new message UI.
require("vim._core.ui2").enable({})

vim.pack.add({
	{ src = "https://github.com/hyperb1iss/silkcircuit-nvim", version = vim.version.range("2.*") },
	-- 0.x releases may break things, so the minor version is raised by hand.
	{ src = "https://github.com/nvim-mini/mini.nvim", version = vim.version.range("0.18.*") },
	{ src = "https://github.com/folke/which-key.nvim", version = vim.version.range("3.*") },
})

-- An explicit variant wins over the one silkcircuit saves in stdpath("data"),
-- so a fresh clone starts in neon too.
require("silkcircuit").setup({ variant = "vibrant" })
vim.cmd.colorscheme("silkcircuit")

require("mini.icons").setup()
MiniIcons.mock_nvim_web_devicons()

require("config.statusline")

-- Leader groups (docs/spec.md §13). which-key shows a group once it has a keymap.
require("which-key").setup({
	spec = {
		{ "<leader>f", group = "find" },
		{ "<leader>e", group = "explorer" },
		{ "<leader>g", group = "git" },
		{ "<leader>c", group = "code" },
		{ "<leader>d", group = "debug" },
		{ "<leader>t", group = "test" },
		{ "<leader>q", group = "database" },
		{ "<leader>a", group = "AI" },
		{ "<leader>o", group = "toggles" },
		{ "<leader>w", group = "windows" },
	},
})
