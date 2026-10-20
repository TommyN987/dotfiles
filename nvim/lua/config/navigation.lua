-- Navigation: fuzzy finding (fzf-lua), file explorer (mini.files), file
-- bookmarks (arrow), moving between Neovim splits and tmux panes.
-- The LSP pickers on gd / gR are mapped in config.lsp.

local health = require("config.health")
health.declare_tool({
	cmd = "fzf",
	needed_by = "fzf-lua",
	min_version = "0.36",
	packages = { pacman = "fzf", apt = "fzf" },
})
health.declare_tool({
	cmd = "rg",
	needed_by = "fzf-lua (grep and file search)",
	packages = { pacman = "ripgrep", apt = "ripgrep" },
})

vim.pack.add({
	-- No usable release tags, so it follows the default branch.
	{ src = "https://github.com/ibhagwan/fzf-lua" },
	{ src = "https://github.com/otavioschwanck/arrow.nvim" },
	{ src = "https://github.com/christoomey/vim-tmux-navigator" },
})

local fzf = require("fzf-lua")
fzf.setup({
	defaults = { file_icons = "mini" },
})
fzf.register_ui_select()

vim.keymap.set("n", "<leader>ff", fzf.files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", fzf.live_grep, { desc = "Grep in project" })
vim.keymap.set("n", "<leader>fr", fzf.oldfiles, { desc = "Recent files" })
vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "Open buffers" })
vim.keymap.set("n", "<leader>fk", fzf.keymaps, { desc = "Keymaps" })
vim.keymap.set("n", "<leader>fh", fzf.helptags, { desc = "Help pages" })
vim.keymap.set("n", "<leader>fd", fzf.diagnostics_document, { desc = "Diagnostics in this file" })
vim.keymap.set("n", "<leader>fD", fzf.diagnostics_workspace, { desc = "Diagnostics in all open files" })

-- mini.nvim itself is added in config.ui. Keys inside the explorer are the old setup's.
local MiniFiles = require("mini.files")
MiniFiles.setup({
	mappings = {
		go_in = "<CR>",
		go_in_plus = "L",
		go_out = "-",
		go_out_plus = "H",
	},
})
vim.keymap.set("n", "<leader>ee", function()
	MiniFiles.open()
end, { desc = "File explorer at cwd" })
vim.keymap.set("n", "<leader>ef", function()
	MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
	MiniFiles.reveal_cwd()
end, { desc = "File explorer at current file" })

require("arrow").setup({
	show_icons = true,
	-- Not arrow's default ";", which would shadow Neovim's repeat-f/t motion.
	leader_key = "<leader>m",
})
