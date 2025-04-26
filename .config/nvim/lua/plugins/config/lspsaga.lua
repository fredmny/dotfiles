require("lspsaga").setup({
	symbol_in_winbar = {
		enable = true,
	},
	outline = {
		win_position = "right",
		win_width = 60,
	},
})

vim.keymap.set("n", "<leader>lo", ":Lspsaga outline <cr>", { desc = "Open outline" })
vim.keymap.set({ "n", "v" }, "<leader>ca", ":Lspsaga code_action <cr>", { desc = "Run code action" })
vim.keymap.set({ "n", "v" }, "<leader>lr", ":Lspsaga rename <cr>", { desc = "Replace in Project" })
vim.keymap.set({ "n", "v" }, "<leader>lj", ":Lspsaga diagnostic_jump_next <cr>", { desc = "Diagnostig: jump next" })
vim.keymap.set({ "n", "v" }, "<leader>lk", ":Lspsaga diagnostic_jump_pref <cr>", { desc = "Diagnostig: jump previous" })
vim.keymap.set({ "n", "v" }, "<leader>ld", ":Lspsaga peek_definition <cr>", { desc = "Peek definition" })
vim.keymap.set({ "n", "v" }, "<leader>lt", ":Lspsaga peek_type_definition <cr>", { desc = "Peek type definition" })
vim.keymap.set({ "n", "v" }, "<leader>lf", ":Lspsaga finder <cr>", { desc = "Open Lspsaga finder" })
vim.keymap.set({ "n", "v" }, "<leader>lm", ":Lspsaga hover_doc <cr>", { desc = "Open hover docs" })
