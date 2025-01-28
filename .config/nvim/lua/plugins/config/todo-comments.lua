require("todo-comments").setup({
	keywords = {
		Q = { icon = " ", color = "#e26fe2" },
		REMOVE = { icon = " ", color = "#c8b966", alt = { "REM", "X" } },
	},
})

vim.keymap.set('n', '<leader>tta', ':TodoTelescope <cr>')
vim.keymap.set('n', '<leader>ttf', ':TodoTelescope cwd=%:p:h <cr>')
