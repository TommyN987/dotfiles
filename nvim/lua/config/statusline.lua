-- Statusline: Neovim's default, plus the git branch on the left and, on the
-- right, macro recording and a reminder when plugins haven't been updated.

local M = {}

local UPDATE_REMINDER_AFTER_DAYS = 30

--- Branch of the current buffer's repo, as tracked by gitsigns.
function M.git_branch()
	local branch = vim.b.gitsigns_head
	if not branch or branch == "" then
		return ""
	end
	return "\u{e0a0} " .. branch .. " "
end

--- cmdheight=0 hides Neovim's own "recording @x" message, so show it here.
function M.macro_recording()
	local register = vim.fn.reg_recording()
	if register == "" then
		return ""
	end
	return "recording @" .. register .. " "
end

function M.update_reminder()
	local days = require("config.pack").days_since_last_update()
	if days < UPDATE_REMINDER_AFTER_DAYS then
		return ""
	end
	return ("plugins updated %d days ago :lua vim.pack.update() "):format(days)
end

-- %{} (not %{%}) so a branch name containing "%" is shown, not interpreted.
local function item(fn_name)
	return ("%%{v:lua.require'config.statusline'.%s()}"):format(fn_name)
end

local default_statusline = vim.go.statusline
local left, right = default_statusline:match("^(.-)%%=(.*)$")
if left then
	vim.go.statusline = left .. item("git_branch") .. "%=" .. item("macro_recording") .. item("update_reminder") .. right
else
	vim.go.statusline = default_statusline .. item("git_branch") .. item("macro_recording") .. item("update_reminder")
end

vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
	group = vim.api.nvim_create_augroup("config.statusline", {}),
	desc = "Show macro recording state in the statusline",
	callback = function()
		-- During RecordingLeave reg_recording() still returns the register.
		vim.schedule(function()
			vim.cmd.redrawstatus()
		end)
	end,
})

return M
