-- Greeter: mini.starter (mini.nvim is added in config.ui), shown when Neovim
-- starts without a file. Type the start of an item's name to pick it, or move
-- with j/k and press <CR>.

local starter = require("mini.starter")

local logo = table.concat({
	"███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
	"████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
	"██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
	"██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
	"██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
	"╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
}, "\n")

---@param name string
---@param action string|function
local function action(name, action_)
	return { name = name, action = action_, section = "Actions" }
end

starter.setup({
	evaluate_single = true,
	header = logo,
	items = {
		starter.sections.recent_files(5, true, false),
		action("Files            ␣ff", function()
			require("fzf-lua").files()
		end),
		action("Grep             ␣fg", function()
			require("fzf-lua").live_grep()
		end),
		action("Explorer         ␣ee", function()
			require("mini.files").open()
		end),
		action("Database         ␣qq", "DBUIToggle"),
		action("Update plugins", "lua vim.pack.update()"),
		action("Health", "checkhealth config"),
		action("New file", "enew"),
		action("Quit", "qall"),
	},
	footer = function()
		return ("%d plugins · frozen until 2027-10"):format(#vim.pack.get())
	end,
	content_hooks = {
		starter.gen_hook.adding_bullet("▎ "),
		starter.gen_hook.aligning("center", "center"),
	},
})
