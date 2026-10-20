-- `:checkhealth config`: checks what this config needs from the system.
--
-- Modules declare the external tools they depend on with declare_tool();
-- check() reports on all of them. This file holds no tool list of its own.

local M = {}

---@class config.health.Tool
---@field cmd string Executable looked up on $PATH.
---@field needed_by string What stops working without it.
---@field min_version? string Lowest acceptable version, e.g. "0.36".
---@field version_args? string[] Arguments that print the version. Default: { "--version" }.
---@field verify_runs? boolean Run it with version_args and require success. Catches launchers
---  that exist but can't run the tool, like a rustup proxy for an uninstalled component.
---@field when? fun(): boolean Only check the tool when this returns true.
---@field packages? { pacman?: string, apt?: string } Package that provides it.
---@field fix? string Advice shown when it's missing or fails, instead of a package install.

---@type table<string, config.health.Tool>
local tools_by_cmd = {}
---@type string[]
local declaration_order = {}

--- Declares an external executable that part of this config depends on.
--- Declaring the same cmd twice merges `needed_by` and keeps the higher `min_version`.
---@param tool config.health.Tool
function M.declare_tool(tool)
	local existing = tools_by_cmd[tool.cmd]
	if not existing then
		tools_by_cmd[tool.cmd] = vim.deepcopy(tool)
		table.insert(declaration_order, tool.cmd)
		return
	end
	existing.needed_by = existing.needed_by .. "; " .. tool.needed_by
	if tool.min_version and (not existing.min_version or vim.version.lt(existing.min_version, tool.min_version)) then
		existing.min_version = tool.min_version
	end
end

local install_command_templates = {
	pacman = "sudo pacman -S %s",
	apt = "sudo apt install %s",
}

---@return "pacman"|"apt"|nil
local function system_package_manager()
	for _, manager in ipairs({ "pacman", "apt" }) do
		if vim.fn.executable(manager) == 1 then
			return manager
		end
	end
end

---@param tool config.health.Tool
---@return string[]? advice nil when there's nothing to suggest, so no empty ADVICE heading shows
local function advice_for(tool)
	if tool.fix then
		return { tool.fix }
	end
	local manager = system_package_manager()
	local package = manager and tool.packages and tool.packages[manager]
	if not package then
		return nil
	end
	return { "Install with: " .. install_command_templates[manager]:format(package) }
end

--- Runs the tool with its version arguments.
---@param tool config.health.Tool
---@return integer exit_code, string message first stdout line, or last stderr line on failure
local function run_version_command(tool)
	local result = vim.system({ tool.cmd, unpack(tool.version_args or { "--version" }) }, { text = true }):wait()
	local stdout, stderr = result.stdout or "", result.stderr or ""
	if result.code ~= 0 then
		local last_stderr_line = vim.trim(stderr):match("([^\n]*)$")
		return result.code, last_stderr_line ~= "" and last_stderr_line or vim.trim(stdout)
	end
	return 0, (stdout ~= "" and stdout or stderr):match("[^\n]*")
end

---@param tool config.health.Tool
local function check_tool(tool)
	local label = ("%s (needed by: %s)"):format(tool.cmd, tool.needed_by)

	if vim.fn.executable(tool.cmd) == 0 then
		vim.health.error(label .. ": not found on $PATH", advice_for(tool))
		return
	end

	if not tool.min_version and not tool.verify_runs then
		vim.health.ok(label)
		return
	end

	local exit_code, message = run_version_command(tool)
	if exit_code ~= 0 then
		vim.health.error(("%s: fails to run: %s"):format(label, message), advice_for(tool))
		return
	end

	if not tool.min_version then
		vim.health.ok(("%s: %s"):format(label, message))
		return
	end

	local version = vim.version.parse(message, { strict = false })
	if not version then
		vim.health.warn(("%s: could not read its version from %q"):format(label, message))
	elseif vim.version.lt(version, tool.min_version) then
		vim.health.error(
			("%s: version %s is older than the required %s"):format(label, tostring(version), tool.min_version),
			advice_for(tool)
		)
	else
		vim.health.ok(("%s: version %s"):format(label, tostring(version)))
	end
end

local function check_neovim()
	vim.health.start("Neovim")
	local v = vim.version()
	local version = ("%d.%d.%d"):format(v.major, v.minor, v.patch)
	if vim.fn.has("nvim-0.12") == 1 then
		vim.health.ok("Neovim " .. version)
	else
		vim.health.error(("Neovim %s is older than the required 0.12"):format(version))
	end
end

-- 'clipboard' includes "unnamedplus" (config.options), so yanks must reach the system clipboard.
local function check_clipboard()
	vim.health.start("System clipboard")
	local provider = vim.fn["provider#clipboard#Executable"]()
	local on_wsl = vim.fn.has("wsl") == 1

	if on_wsl and (provider == "" or provider == "tmux") then
		vim.health.error(
			("Clipboard provider is %q, so yanks never reach the Windows clipboard"):format(provider),
			{ "Install wl-clipboard: sudo apt install wl-clipboard" }
		)
	elseif provider == "" then
		vim.health.warn("No clipboard provider found; yanks stay inside Neovim")
	else
		vim.health.ok("Clipboard provider: " .. provider)
	end
end

function M.check()
	check_neovim()
	check_clipboard()

	vim.health.start("External tools")
	local checked_any = false
	for _, cmd in ipairs(declaration_order) do
		local tool = tools_by_cmd[cmd]
		if not tool.when or tool.when() then
			check_tool(tool)
			checked_any = true
		end
	end
	if not checked_any then
		vim.health.info("No external tools declared")
	end
end

return M
