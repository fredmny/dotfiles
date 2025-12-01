local harpoon = require("harpoon")

harpoon:setup()

vim.keymap.set("n", "<Space>pa", function() harpoon:list():add() end, { desc = "Add file to harpoon" })
vim.keymap.set("n", "<Space>pp", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Toggle harpoon menu" })
vim.keymap.set("n", "<Space>pj", function() harpoon:list():next() end, { desc = "Next harpoon file" })
vim.keymap.set("n", "<Space>pk", function() harpoon:list():prev() end, { desc = "Previous harpoon file" })
vim.keymap.set("n", "<Space>pq", function() harpoon:list():select(1) end, { desc = "Select harpoon file 1" })
vim.keymap.set("n", "<Space>pw", function() harpoon:list():select(2) end, { desc = "Select harpoon file 2" })
vim.keymap.set("n", "<Space>pe", function() harpoon:list():select(3) end, { desc = "Select harpoon file 3" })
vim.keymap.set("n", "<Space>pr", function() harpoon:list():select(4) end, { desc = "Select harpoon file 4" })
