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
