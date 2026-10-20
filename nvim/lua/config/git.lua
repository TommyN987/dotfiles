-- Git: change markers, staging and blame in the buffer (gitsigns); side-by-side
-- review of changes across files (codediff). Committing, pushing and the rest
-- stay in tmux.

vim.pack.add({
	{ src = "https://github.com/lewis6991/gitsigns.nvim", version = vim.version.range("2.*") },
	-- Downloads its diff library (libvscode-diff) into the plugin folder on first use.
	{ src = "https://github.com/esmuellert/codediff.nvim", version = vim.version.range("4.*") },
})

local gitsigns = require("gitsigns")

---@param bufnr integer
local function map_hunk_keys(bufnr)
	local function map(mode, lhs, rhs, desc)
		vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
	end
	local function selected_lines()
		return { vim.fn.line("."), vim.fn.line("v") }
	end

	map("n", "<leader>gs", gitsigns.stage_hunk, "Stage hunk (again to unstage)")
	map("n", "<leader>gr", gitsigns.reset_hunk, "Reset hunk")
	map("x", "<leader>gs", function()
		gitsigns.stage_hunk(selected_lines())
	end, "Stage selected lines")
	map("x", "<leader>gr", function()
		gitsigns.reset_hunk(selected_lines())
	end, "Reset selected lines")
	map("n", "<leader>gS", gitsigns.stage_buffer, "Stage buffer")
	map("n", "<leader>gR", gitsigns.reset_buffer, "Reset buffer")
	-- Deprecated in v2 in favour of stage_hunk on a staged hunk, but still shipped;
	-- kept because <leader>gu is muscle memory.
	map("n", "<leader>gu", gitsigns.undo_stage_hunk, "Undo last stage")
	map("n", "<leader>gp", gitsigns.preview_hunk, "Preview hunk")
	map("n", "<leader>gb", function()
		gitsigns.blame_line({ full = true })
	end, "Blame line")
	map("n", "<leader>gB", gitsigns.toggle_current_line_blame, "Toggle line blame")
	map("n", "<leader>gd", gitsigns.diffthis, "Diff against index")
	map("n", "<leader>gD", function()
		gitsigns.diffthis("~")
	end, "Diff against last commit")
end

gitsigns.setup({
	on_attach = map_hunk_keys,
})

require("codediff").setup({
	keymaps = {
		view = {
			-- Default <leader>e would make the explorer group's prefix also an action.
			focus_explorer = "<leader>ge",
			-- Same keys as gitsigns for the same actions.
			stage_hunk = "<leader>gs",
			unstage_hunk = "<leader>gu",
			discard_hunk = "<leader>gr",
		},
	},
})

vim.keymap.set("n", "<leader>gc", "<cmd>CodeDiff<CR>", { desc = "Review changes (codediff)" })
