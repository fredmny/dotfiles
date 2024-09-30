require("telescope").setup({
	extensions = {
		["ui-select"] = {
			require("telescope.themes").get_dropdown({
				-- even more opts
			}),
		},
	},
})

local builtin = require("telescope.builtin")
require("telescope").load_extension("ui-select")

vim.keymap.set("n", "<c-p>", builtin.find_files, {})
vim.keymap.set("n", "<Space><Space>", builtin.oldfiles, {})
vim.keymap.set("n", "<Space>tg", builtin.live_grep, {})
vim.keymap.set("n", "<Space>th", builtin.help_tags, {})
vim.keymap.set("n", "<Space>tb", builtin.buffers, {})
vim.keymap.set("n", "<Space>td", require("dbtpal.telescope").dbt_picker, {})
