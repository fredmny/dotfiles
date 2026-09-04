require("dapui").setup({
	layouts = {
		-- Listed first so it claims the full width at the bottom; the "right"
		-- layout below then only gets the remaining space above it, instead
		-- of spanning the whole screen height.
		{
			elements = {
				{ id = "console", size = 2 / 3 },
				{ id = "repl", size = 1 / 3 },
			},
			size = 30,
			position = "bottom",
		},
		{
			elements = {
				{ id = "scopes", size = 0.35 },
				{ id = "stacks", size = 0.35 },
				{ id = "watches", size = 0.20 },
				{ id = "breakpoints", size = 0.10 },
			},
			size = 50,
			position = "right",
		},
	},
})

local dap, dapui = require("dap"), require("dapui")

vim.fn.sign_define("DapBreakpoint", { text = "🛑", texthl = "", linehl = "", numhl = "" })

dap.listeners.before.attach.dapui_config = function()
	dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
	dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
	dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
	dapui.close()
end

-- Debuggers
-- Python
require("dap-python").setup("python")

-- debugpy honors the runInTerminal request, so this routes program
-- stdin/stdout through dapui's "console" element instead of the "repl".
for _, config in ipairs(dap.configurations.python) do
	config.console = "integratedTerminal"
end

-- Node.js/TypeScript
-- pwa-node (js-debug) does NOT wire into dapui's "console" element: js-debug
-- spawns a child session for the actual process, and nvim-dap-vscode-js
-- can't route that through nvim-dap's integrated terminal. Its output always
-- arrives as DAP OutputEvents, which land in the "repl" element regardless
-- of any console setting here.
dap.adapters['pwa-node'] = {
	type = 'server',
	host = 'localhost',
	port = '${port}',
	executable = {
		command = 'node',
		args = {
			vim.fn.stdpath("data") .. '/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js',
			'${port}'
		},
	}
}

dap.configurations.typescript = {
	{
		type = 'pwa-node',
		request = 'launch',
		name = 'Launch TypeScript',
		runtimeArgs = {'-r', 'ts-node/register'},
		args = {'${file}'},
		cwd = '${workspaceFolder}',
		sourceMaps = true,
		protocol = 'inspector',
	},
}

-- Use same config for JavaScript
dap.configurations.javascript = dap.configurations.typescript

-- To setup more debuggers refer to
-- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation

-- .vscode/launch.json files are now read automatically on-demand by nvim-dap.
-- See :help dap-providers

-- DAP (debugger) keymaps
vim.keymap.set("n", "<Leader>db", function()
	require("dap").toggle_breakpoint()
end, {desc = "DAP: Toggle breakpoint"})
vim.keymap.set("n", "<Leader>dC", function()
	require("dap").clear_breakpoints()
end, {desc = "DAP: Clear breakpoints"})
vim.keymap.set("n", "<Leader>dc", function()
	require("dap").continue()
end, {desc = "DAP: Continue"})
vim.keymap.set("n", "<Leader>dl", function()
	require("dap").repl.open()
end, {desc = "DAP: REPL open"})
vim.keymap.set("n", "<Leader>dr", function()
	require("dap").restart()
end, {desc = "DAP: Restart"})
vim.keymap.set("n", "<Leader>dt", function()
	require("dap").terminate()
end, {desc = "DAP: Terminate"})
vim.keymap.set("n", "<Leader>dI", function()
	require("dap").step_into()
end, {desc = "DAP: Step into"})
vim.keymap.set("n", "<Leader>dO", function()
	require("dap").step_out()
end, {desc = "DAP: Step out"})
vim.keymap.set("n", "<Leader>do", function()
	require("dap").step_over()
end, {desc = "DAP: Step over"})
vim.keymap.set("n", "<Leader>du", function()
  require('dapui').toggle()
end, {desc = "DAP: Toggle UI"})
