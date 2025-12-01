local stages_util = require("notify.stages.util")

require("notify").setup({
  top_down = false,
  max_width = 50,
})
vim.notify = require("notify")
vim.keymap.set("n", "<Space>twc", "<CMD>lua require('telescope').extensions.git_worktree.create_git_worktree()<CR>",
  { silent = true, desc = "Create git worktree" })
vim.keymap.set("n", "<Space>tn", "<CMD> lua require('telescope').extensions.notify.notify()<CR>", { silent = true, desc = "Show notifications" })
