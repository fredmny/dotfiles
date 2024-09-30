require("lualine").setup({
	options = {
		icons_enabled = true,
		theme = "dracula",
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = {'branch', 'diff', 'diagnostics'},
		-- lualine_b = { "diff", "diagnostics" },
		lualine_c = { "filename" },
		lualine_x = { "encoding", "fileformat", "filetype" },
		lualine_y = { "progress" },
		lualine_z = { "location" },
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { "filename" },
		lualine_x = { "location" },
		lualine_y = {},
		lualine_z = {},
	},
	-- sections = {
	-- lualine_a = {
	--   {
	--     'filename',
	--     path = 1,
	--   }
	-- },
	-- lualine_b = {
	--   {
	--
	--   }
	-- }
	-- }
})
