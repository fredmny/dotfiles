require("git-worktree").setup({
	update_on_change = true,
})
require("telescope").load_extension("git_worktree")
vim.keymap.set("n", "<Space>twl", "<CMD>lua require('telescope').extensions.git_worktree.git_worktrees()<CR>", silent)
vim.keymap.set("n", "<Space>twc", "<CMD>lua require('telescope').extensions.git_worktree.create_git_worktree()<CR>", silent)
