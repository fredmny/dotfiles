require("obsidian").setup({
	workspaces = {
		{
			name = "Personal",
			path = "~/personal/obsidian_personal",
		},
	},
	ui = { enbale = false },
	disable_frontmatter = true,
})

vim.keymap.set("n", "<leader>oo", ":ObsidianOpen <cr>", { desc = "Open note in Obsidian" })
vim.keymap.set("n", "<leader>ob", ":ObsidianBacklinks <cr>", { desc = "Show backlinks" })
vim.keymap.set("n", "<leader>oi", ":ObsidianPasteImage <cr>", { desc = "Paste clipboard image into note" })
vim.keymap.set("n", "<leader>oc", ":ObsidianToggleCheckbox <cr>", { desc = "Toggle checkbox" })
vim.keymap.set("n", "<leader>of", ":ObsidianFollowLink <cr>", { desc = "Follow Obsidian link" })
