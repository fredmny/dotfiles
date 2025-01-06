-- Get terminal output
local function get_cmd_output(cmd)
	local handle = io.popen(cmd)
	local result = handle:read("*a")
	handle:close()
	return result
end

-- Get Obsidian path
local system_name = get_cmd_output("uname -s")
system_name = system_name:gsub("%s+", "")
local obsidian_path = ""
if system_name == "Linux" then
	obsidian_path = "~/shared_drive/obsidian_personal/"
else
	obsidian_path = "~/personal/obsidian_personal/"
end

require("obsidian").setup({
	workspaces = {
		{
			name = "Personal",
			path = obsidian_path,
		},
	},
	ui = { enbale = false },
	disable_frontmatter = true,
})

vim.keymap.set("n", "<leader>oo", ":ObsidianOpen <cr>", { desc = "Open note in Obsidian" })
vim.keymap.set("n", "<leader>ob", ":ObsidianBacklinks <cr>", { desc = "Show backlinks" })
vim.keymap.set("n", "<leader>oi", ":ObsidianPasteImage <cr>", { desc = "Paste clipboard image into note" })
vim.keymap.set("n", "<leader>oc", ":ObsidianToggleCheckbox <cr>", { desc = "Toggle checkbox" })
vim.keymap.set("n", "<leader>of", ":ObsidianFollowLink <cr>", { desc = "Follow Obsidian link" })
