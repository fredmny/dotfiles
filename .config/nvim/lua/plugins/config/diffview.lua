-- Diffview keymaps (plugin is lazy-loaded via :Diffview* commands in lazy.lua)
-- <leader>gd is a prefix only; do not bind it directly (timeoutlen delay).

local function default_branch()
	local ref = vim.fn.systemlist("git symbolic-ref --short refs/remotes/origin/HEAD")[1]
	if vim.v.shell_error == 0 and ref and ref ~= "" then
		return ref
	end
	for _, b in ipairs({ "origin/main", "origin/master", "main", "master" }) do
		vim.fn.system("git rev-parse --verify --quiet " .. b)
		if vim.v.shell_error == 0 then
			return b
		end
	end
	return "HEAD~1"
end

vim.keymap.set("n", "<leader>gdd", "<cmd>DiffviewToggle<cr>", { desc = "Diffview: toggle working tree" })
vim.keymap.set("n", "<leader>gdh", "<cmd>DiffviewFileHistory %<cr>", { desc = "Diffview: current file history" })
vim.keymap.set("x", "<leader>gdh", ":DiffviewFileHistory<cr>", { silent = true, desc = "Diffview: selection history" })
vim.keymap.set("n", "<leader>gdH", "<cmd>DiffviewFileHistory<cr>", { desc = "Diffview: branch history" })
vim.keymap.set("n", "<leader>gdm", function()
	vim.cmd("DiffviewOpen " .. default_branch() .. "...HEAD")
end, { desc = "Diffview: branch vs default (merge-base)" })
vim.keymap.set("n", "<leader>gds", "<cmd>DiffviewOpen --staged<cr>", { desc = "Diffview: staged changes" })

-- Pick a commit in Telescope; Diffview opens from that commit (inclusive) to the working tree.
vim.keymap.set("n", "<leader>gdc", function()
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	require("telescope.builtin").git_commits({
		attach_mappings = function(bufnr)
			actions.select_default:replace(function()
				local entry = action_state.get_selected_entry()
				actions.close(bufnr)
				-- <hash>~1 on the left includes that commit's own changes
				vim.cmd("DiffviewOpen " .. entry.value .. "~1")
			end)
			return true
		end,
	})
end, { desc = "Diffview: commit → working tree" })
