-- Databases: vim-dadbod runs queries, vim-dadbod-ui browses schemas, and
-- vim-dadbod-completion completes table and column names (spec §9).
--
-- Connections come only from environment variables, never from this repo:
-- DB_UI_<NAME>=<url> (e.g. in the project's .env, read by vim-dotenv) becomes
-- the connection <name>. dadbod-ui also reads $DBUI_URL.

local health = require("config.health")
health.declare_tool({
	cmd = "psql",
	needed_by = "vim-dadbod (Postgres)",
	packages = { pacman = "postgresql", apt = "postgresql-client" },
})
health.declare_tool({
	cmd = "sqlite3",
	needed_by = "vim-dadbod (SQLite)",
	packages = { pacman = "sqlite", apt = "sqlite3" },
})

vim.g.db_ui_use_nerd_fonts = 1

vim.pack.add({
	-- Default branches: the tpope plugins' last tags are from 2021 (dadbod) and
	-- 2015 (dotenv), far behind; the other two have no tags.
	{ src = "https://github.com/tpope/vim-dadbod" },
	{ src = "https://github.com/kristijanhusak/vim-dadbod-ui" },
	-- Its blink source is registered in config.completion.
	{ src = "https://github.com/kristijanhusak/vim-dadbod-completion" },
	-- Reads the nearest .env above the current file.
	{ src = "https://github.com/tpope/vim-dotenv" },
})

vim.keymap.set("n", "<leader>qq", "<cmd>DBUIToggle<CR>", { desc = "Toggle database UI" })
