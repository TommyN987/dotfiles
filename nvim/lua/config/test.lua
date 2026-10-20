-- Tests: vim-test builds the command for the test under the cursor and vimux
-- runs it in a tmux pane (spec §8). Neovim never runs the tests itself.

require("config.health").declare_tool({
	cmd = "tmux",
	needed_by = "vimux (runs tests in a tmux pane; Neovim must itself run inside tmux)",
	packages = { pacman = "tmux", apt = "tmux" },
})

-- Read when a test command runs, so the order relative to vim.pack.add() doesn't matter.
vim.g["test#strategy"] = "vimux"
vim.g["test#rust#runner"] = "cargonextest"

--- Files marking the project a test file belongs to, per filetype (Rust: see cargo_workspace_root).
local project_markers = {
	javascript = { "package.json" },
	javascriptreact = { "package.json" },
	typescript = { "package.json" },
	typescriptreact = { "package.json" },
	go = { "go.mod" },
	python = { "pyproject.toml", "setup.cfg", "pytest.ini", "tox.ini" },
}

---@param file string
---@return string? root of the Cargo workspace the file belongs to, or of its crate
local function cargo_workspace_root(file)
	local crate_root = vim.fs.root(file, "Cargo.toml")
	if not crate_root then
		return nil
	end
	local result = vim.system(
		{ "cargo", "locate-project", "--workspace", "--message-format", "plain" },
		{ cwd = crate_root, text = true }
	):wait()
	if result.code ~= 0 then
		return crate_root
	end
	return vim.fs.dirname(vim.trim(result.stdout))
end

--- Where vim-test builds and runs the command: the current file's project, not
--- Neovim's cwd. In a monorepo (backend/Cargo.toml, frontend/package.json) the
--- cwd is the repo root, where cargo and npx find no project.
---@return string
local function test_project_root()
	local file = vim.api.nvim_buf_get_name(0)
	local root
	if vim.bo.filetype == "rust" then
		root = cargo_workspace_root(file)
	elseif project_markers[vim.bo.filetype] then
		root = vim.fs.root(file, project_markers[vim.bo.filetype])
	end
	return root or vim.fn.getcwd()
end
vim.g["test#project_root"] = test_project_root

-- vim-test cds into the project root only while building the command; the vimux
-- pane keeps its own cwd, so the command has to cd there itself.
vim.g["test#custom_transformations"] = {
	in_project_root = function(cmd)
		return "cd " .. vim.fn.shellescape(vim.fn.getcwd()) .. " && " .. cmd
	end,
}
vim.g["test#transformation"] = "in_project_root"

vim.pack.add({
	{ src = "https://github.com/vim-test/vim-test", version = vim.version.range("3.*") },
	{ src = "https://github.com/preservim/vimux", version = vim.version.range("1.*") },
})

vim.keymap.set("n", "<leader>tn", "<cmd>TestNearest<CR>", { desc = "Run nearest test" })
vim.keymap.set("n", "<leader>tf", "<cmd>TestFile<CR>", { desc = "Run tests in file" })
vim.keymap.set("n", "<leader>ts", "<cmd>TestSuite<CR>", { desc = "Run all tests" })
vim.keymap.set("n", "<leader>tl", "<cmd>TestLast<CR>", { desc = "Rerun last test" })
