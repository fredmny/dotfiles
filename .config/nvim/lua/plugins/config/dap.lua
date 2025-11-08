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
-- Requires debugpy in specified folder
-- require('dap-python').setup('~/.virtualenvs/debugpy/bin/python')
-- To use with globally installed debugpy uncomment below
require("dap-python").setup("python")

-- To setup more debuggers refer to
-- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation

require("dap.ext.vscode").load_launchjs(nil, {})
--
-- DAP (debugger)
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
