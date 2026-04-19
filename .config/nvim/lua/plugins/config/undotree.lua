-- Persistent undo (survives closing and reopening files)
vim.opt.undofile = true

-- Undotree settings
vim.g.undotree_WindowLayout = 2 -- tree on left, diff below
vim.g.undotree_SetFocusWhenToggle = 1 -- auto-focus the tree when opened

-- Keymap
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Toggle Undotree" })
