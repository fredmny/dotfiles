require("notify").setup()
vim.notify = require("notify")
vim.keymap.set("n", "<Space>twc", "<CMD>lua require('telescope').extensions.git_worktree.create_git_worktree()<CR>", silent)
vim.keymap.set("n", "<Space>tn", "<CMD> lua require('telescope').extensions.notify.notify()<CR>", silent)
