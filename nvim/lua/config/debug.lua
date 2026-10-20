-- Debugging: nvim-dap with the nvim-dap-view UI (spec §7).
-- Adapters come from Mason (config.mason): codelldb (Rust, set up by rustaceanvim),
-- js-debug-adapter (Node, Chrome), delve (Go), debugpy (Python).

vim.pack.add({
	-- Default branch, not its last release (0.10.0, 2025-03): nvim-dap-view 1.x
	-- needs dap.listeners.on_session, which came after that release.
	{ src = "https://github.com/mfussenegger/nvim-dap" },
	{ src = "https://github.com/igorlfs/nvim-dap-view", version = vim.version.range("1.*") },
	-- No release tags, so these follow their default branch.
	{ src = "https://github.com/leoluz/nvim-dap-go" },
	{ src = "https://github.com/mfussenegger/nvim-dap-python" },
})

local dap = require("dap")

-- Opens when a session starts and closes when it ends.
require("dap-view").setup({ auto_toggle = true })

-- js-debug-adapter serves both Node and Chrome on a port nvim-dap picks.
local js_debug_adapter = {
	type = "server",
	host = "localhost",
	port = "${port}",
	executable = { command = "js-debug-adapter", args = { "${port}" } },
}
dap.adapters["pwa-node"] = js_debug_adapter
dap.adapters["pwa-chrome"] = js_debug_adapter

local js_configurations = {
	{
		type = "pwa-node",
		request = "launch",
		name = "Node: run current file",
		program = "${file}",
		cwd = "${workspaceFolder}",
	},
	{
		type = "pwa-node",
		request = "attach",
		name = "Node: attach to process",
		processId = require("dap.utils").pick_process,
		cwd = "${workspaceFolder}",
	},
	{
		type = "pwa-chrome",
		request = "launch",
		name = "Chrome: open app",
		url = function()
			return vim.fn.input("App URL: ", "http://localhost:5173")
		end,
		webRoot = "${workspaceFolder}",
	},
}
for _, filetype in ipairs({ "javascript", "javascriptreact", "typescript", "typescriptreact" }) do
	dap.configurations[filetype] = js_configurations
end

require("dap-go").setup()
require("dap-python").setup("debugpy-adapter")

local function map(lhs, rhs, desc)
	vim.keymap.set("n", lhs, rhs, { desc = desc })
end
map("<leader>db", dap.toggle_breakpoint, "Toggle breakpoint")
map("<leader>dB", function()
	dap.set_breakpoint(vim.fn.input("Break when: "))
end, "Conditional breakpoint")
map("<leader>dc", dap.continue, "Start or continue")
map("<leader>dn", dap.step_over, "Step over")
map("<leader>di", dap.step_into, "Step into")
map("<leader>do", dap.step_out, "Step out")
map("<leader>dt", dap.terminate, "Stop debugging")
map("<leader>dv", "<cmd>DapViewToggle<CR>", "Toggle debug view")
