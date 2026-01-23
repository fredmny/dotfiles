require("dapui").setup()

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

-- Node.js/TypeScript
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

require("dap.ext.vscode").load_launchjs(nil, {})

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
