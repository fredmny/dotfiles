require("snacks").setup({
	zen = { enabled = true },
	gitbrowse = { enabled = true },
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
    styles = 'expanded',
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
vim.keymap.set("n", "<leader>z", function()
	Snacks.zen()
end, { desc = "Toggle Zen Mode" })
vim.keymap.set("n", "<leader>Z", function()
	Snacks.zen.zoom()
end, { desc = "Toggle Zoom" })
vim.keymap.set({ "n", "v" }, "<leader>gB", function()
	Snacks.gitbrowse()
end, { desc = "Git Browse" })
