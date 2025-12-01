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
-- require("telescope").load_extension("notify")

vim.keymap.set("n", "<c-p>", builtin.find_files, { desc = "Find files" })
vim.keymap.set("n", "<Space><Space>", builtin.oldfiles, { desc = "Recent files" })
vim.keymap.set("n", "<Space>tg", builtin.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<Space>th", builtin.help_tags, { desc = "Help tags" })
vim.keymap.set("n", "<Space>tb", builtin.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<Space>td", require("dbtpal.telescope").dbt_picker, { desc = "DBT picker" })
