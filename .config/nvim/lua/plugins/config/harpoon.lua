local harpoon = require("harpoon")

harpoon:setup()

vim.keymap.set("n", "<Space>pa", function() harpoon:list():add() end)
vim.keymap.set("n", "<Space>pp", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
vim.keymap.set("n", "<Space>pj", function() harpoon:list():next() end)
vim.keymap.set("n", "<Space>pk", function() harpoon:list():prev() end)
vim.keymap.set("n", "<Space>pq", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<Space>pw", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<Space>pe", function() harpoon:list():select(3) end)
vim.keymap.set("n", "<Space>pr", function() harpoon:list():select(4) end)
