-- Interface: messages, colorscheme, icons, statusline, keymap hints.

-- Before vim.pack.add(), so install progress already uses the new message UI.
require("vim._core.ui2").enable({})

vim.pack.add({
	{ src = "https://github.com/hyperb1iss/silkcircuit-nvim", version = vim.version.range("2.*") },
	-- 0.x releases may break things, so the minor version is raised by hand.
	{ src = "https://github.com/nvim-mini/mini.nvim", version = vim.version.range("0.18.*") },
	{ src = "https://github.com/folke/which-key.nvim", version = vim.version.range("3.*") },
})

--- `color` mixed into `base` at `amount` (0–1), both "#rrggbb".
---@return string
local function tint(color, base, amount)
	local function channels(hex)
		return tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16)
	end
	local r1, g1, b1 = channels(color)
	local r2, g2, b2 = channels(base)
	local function mix(a, b)
		return math.floor(a * amount + b * (1 - amount) + 0.5)
	end
	return ("#%02x%02x%02x"):format(mix(r1, r2), mix(g1, g2), mix(b1, b2))
end

-- silkcircuit's diff backgrounds are full-strength neon (#50fa7b, #ff5555), which
-- leaves syntax colors unreadable on them (contrast down to 1.0). Dark tints of
-- the palette keep every syntax color at a WCAG contrast of 4.1 or more.
-- Lines get a faint tint, changed words inside them a stronger one.
-- DiffTextAdd / DiffTextDelete are the word-level groups; config.git points codediff at them.
---@param highlights table<string, vim.api.keyset.highlight>
---@param colors table<string, string> the active variant's palette
local function readable_diff_colors(highlights, colors)
	highlights.DiffAdd = { bg = tint(colors.cyan, colors.bg, 0.08) }
	highlights.DiffTextAdd = { bg = tint(colors.cyan, colors.bg, 0.16) }
	highlights.DiffDelete = { bg = tint(colors.pink, colors.bg, 0.12) }
	highlights.DiffTextDelete = { bg = tint(colors.pink, colors.bg, 0.22) }
	highlights.DiffChange = { bg = tint(colors.blue, colors.bg, 0.10) }
	highlights.DiffText = { bg = tint(colors.blue, colors.bg, 0.18) }
end

-- An explicit variant wins over the one silkcircuit saves in stdpath("data"),
-- so a fresh clone starts in vibrant too.
require("silkcircuit").setup({ variant = "vibrant", on_highlights = readable_diff_colors })
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
