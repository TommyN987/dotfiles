-- Editing helpers (spec §10): text objects, surround and auto-pairs (mini.nvim,
-- added in config.ui), tag closing, TODO comments, undo tree, Cargo.toml
-- version hints, and the bridge to Claude Code running in a tmux pane.

vim.pack.add({
	{ src = "https://github.com/windwp/nvim-ts-autotag" },
	-- Needed by todo-comments for searching. Its last tag (v0.1.4) is far behind.
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/folke/todo-comments.nvim", version = vim.version.range("1.*") },
	{ src = "https://github.com/saecki/crates.nvim", version = vim.version.range("0.*") },
	-- Its last tag (v0.3.0) is far behind.
	{ src = "https://github.com/coder/claudecode.nvim" },
})

-- `cin(` changes inside the next parentheses, even with the cursor before them.
require("mini.ai").setup()

-- The old setup's keys: `ds` instead of mini's default `sd`.
require("mini.surround").setup({
	mappings = {
		add = "sa",
		delete = "ds",
		find = "sf",
		find_left = "sF",
		highlight = "sh",
		replace = "sr",
		update_n_lines = "sn",
	},
})

require("mini.pairs").setup()

require("nvim-ts-autotag").setup()

local todo_comments = require("todo-comments")
todo_comments.setup()
vim.keymap.set("n", "]t", todo_comments.jump_next, { desc = "Next TODO comment" })
vim.keymap.set("n", "[t", todo_comments.jump_prev, { desc = "Previous TODO comment" })
vim.keymap.set("n", "<leader>ft", "<cmd>TodoFzfLua<CR>", { desc = "TODO comments" })

vim.cmd.packadd("nvim.undotree")
vim.keymap.set("n", "<leader>u", "<cmd>Undotree<CR>", { desc = "Undo tree" })

require("crates").setup()

-- Claude Code runs in its own tmux pane; start it with `claude --ide` or pick
-- Neovim with `/ide`. With no terminal provider, :ClaudeCode opens nothing.
require("claudecode").setup({
	terminal = { provider = "none" },
	-- "info" reports the server starting and stopping on every launch and exit.
	log_level = "warn",
})
vim.keymap.set("n", "<leader>ab", "<cmd>ClaudeCodeAdd %<CR>", { desc = "Add file to Claude's context" })
vim.keymap.set("x", "<leader>as", "<cmd>ClaudeCodeSend<CR>", { desc = "Send selection to Claude" })
vim.keymap.set("n", "<leader>aa", "<cmd>ClaudeCodeDiffAccept<CR>", { desc = "Accept Claude's diff" })
vim.keymap.set("n", "<leader>ad", "<cmd>ClaudeCodeDiffDeny<CR>", { desc = "Reject Claude's diff" })
