-- vim.pack plumbing: plugin build steps and update tracking.
--
-- Build steps live here, not next to the vim.pack.add() of each plugin:
-- on a fresh clone the very first vim.pack.add() installs every plugin in
-- nvim-pack-lock.json at once, so all steps must be registered before it.

require("config.health").declare_tool({
	cmd = "git",
	needed_by = "vim.pack (installing and updating plugins)",
	packages = { pacman = "git", apt = "git" },
})

--- Plugin name -> step to run after that plugin is installed or updated.
---@type table<string, fun(data: vim.event.packchanged.data)>
local build_steps = {}

-- Read by the statusline's update reminder.
local last_update_path = vim.fs.joinpath(vim.fn.stdpath("state"), "pack-updated")

local function record_update_time()
	vim.fn.mkdir(vim.fs.dirname(last_update_path), "p")
	vim.fn.writefile({ tostring(os.time()) }, last_update_path)
end

---@param data vim.event.packchanged.data
local function run_build_step(data)
	local name = data.spec.name
	local step = build_steps[name]
	if not step then
		return
	end
	local ok, err = pcall(function()
		-- A plugin installed from the lockfile is on disk but not loaded yet.
		if not data.active then
			vim.cmd.packadd(name)
		end
		step(data)
	end)
	if not ok then
		vim.notify(("Build step for %s failed: %s"):format(name, err), vim.log.levels.ERROR)
	end
end

vim.api.nvim_create_autocmd("PackChanged", {
	group = vim.api.nvim_create_augroup("config.pack", {}),
	desc = "Run plugin build steps and record the last plugin update",
	callback = function(event)
		local data = event.data
		if data.kind == "update" then
			record_update_time()
		end
		if data.kind == "install" or data.kind == "update" then
			run_build_step(data)
		end
	end,
})
