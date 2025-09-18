require("snacks").setup({
	zen = { enabled = true },
	gitbrowse = { enabled = true },
  image = { enabled = true},
  indent = { enabled = true },
	dashboard = {
		enabled = true,
		sections = {
			{ section = "header" },
			{ section = "keys", gap = 1, padding = 1 },
			{ section = "startup" },
			{
				section = "terminal",
				cmd = "ascii-image-converter -C ~/.config/nvim/resources/gandalf.png",
				random = 10,
				pane = 2,
				indent = 4,
				height = 30,
			},
		},
	},
	notifier = {
		enabled = true,
		timeout = 3000, -- default timeout in ms
		width = { min = 40, max = 50 },
		height = { min = 1, max = 0.6 },
		-- editor margin to keep free. tabline and statusline are taken into account automatically
		margin = { top = 0, right = 1, bottom = 0 },
		padding = true, -- add 1 cell of left/right padding to the notification window
		sort = { "level", "added" }, -- sort by level and time
		styles = "expanded",
		-- minimum log level to display. TRACE is the lowest
		-- all notifications are stored in history
		level = vim.log.levels.TRACE,
		icons = {
			error = " ",
			warn = " ",
			info = " ",
			debug = " ",
			trace = " ",
		},
		keep = function(notif)
			return vim.fn.getcmdpos() > 0
		end,
		---@type snacks.notifier.style
		style = "compact",
		top_down = false, -- place notifications from top to bottom
		date_format = "%R", -- time format for notifications
		-- format for footer when more lines are available
		-- `%d` is replaced with the number of lines.
		-- only works for styles with a border
		---@type string|boolean
		more_format = " ↓ %d lines ",
		refresh = 50, -- refresh at most every 50ms
	},
})

-- NOTE: Version below used for debugging
-- -- Debug autocmd to see what's happening
-- vim.api.nvim_create_autocmd({ "BufEnter", "FileType", "BufRead" }, {
-- 	callback = function(ev)
-- 		local bufname = vim.api.nvim_buf_get_name(0)
-- 		local filetype = vim.bo.filetype
-- 		if bufname:match("snacks") or filetype:match("snacks") or filetype == "" then
-- 			print("Event:", ev.event, "Bufname:", bufname, "Filetype:", filetype)
-- 			vim.b.minitrailspace_disable = true
-- 			pcall(function()
-- 				require('mini.trailspace').unhighlight()
-- 			end)
-- 		end
-- 	end,
-- })
--

vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		local bufname = vim.api.nvim_buf_get_name(0)
		local filetype = vim.bo.filetype

		-- Check if this is a Snacks dashboard buffer
		if filetype:match("snacks") or filetype == "" then
			vim.b.minitrailspace_disable = true
		end
	end,
})

local Snacks = require("snacks")
vim.keymap.set("n", "<leader>gl", function()
	Snacks.lazygit.log()
end, { desc = "Lazygit Log (cwd)" })
vim.keymap.set("n", "<leader>nu", function()
	Snacks.notifier.hide()
end, { desc = "Dismiss All Notifications" })
vim.keymap.set("n", "<leader>nh", function()
	Snacks.notifier.show_history()
end, { desc = "Show notifier history" })
vim.keymap.set("n", "<leader>gg", function()
	Snacks.lazygit()
end, { desc = "Lazygit" })
vim.keymap.set("n", "<leader>Z", function()
	Snacks.zen.zoom()
end, { desc = "Toggle Zoom" })
vim.keymap.set({ "n", "v" }, "<leader>gB", function()
	Snacks.gitbrowse()
end, { desc = "Git Browse" })
