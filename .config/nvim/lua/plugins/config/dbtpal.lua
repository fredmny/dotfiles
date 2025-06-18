require('dbtpal').setup()
require('telescope').load_extension('dbtpal')
vim.keymap.set("n", "<leader>tm", require("dbtpal.telescope").dbt_picker)
