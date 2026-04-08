require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"bash",
		"dockerfile",
		"json",
		"lua",
		"markdown",
		"markdown_inline",
		"python",
		"sql",
		"terraform",
		"typescript",
		"javascript",
		"vim",
		"vimdoc",
		"yaml",
	},

	-- Install parsers synchronously (only applied to `ensure_installed`)
	sync_install = false,
	auto_install = true,
	highlight = {
		enable = true,
	},
	indent = {
		enable = true,
	},
})
