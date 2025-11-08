-- config = function()
--   vim.g.copilot_filetypes = {
--     ["copilot-chat"] = false,
--   }
-- end
-- Copilot chat
-- local cmp = require("cmp")
-- cmp.event:on("menu_opened", function()
--   vim.b.copilot_suggestion_hidden = true
-- end)
--
-- cmp.event:on("menu_closed", function()
--   vim.b.copilot_suggestion_hidden = false
-- end)

require("copilot").setup({
	suggestion = { enabled = false },
	panel = { enabled = false },
	model = "claude-sonnet-4.5",
	filetypes = {
		["copilot-chat"] = false,
	},
})

require("copilot_cmp").setup()
require("CopilotChat").setup({
	model = "claude-sonnet-4.5",
	window = {
		layout = "float",
		position = "right",
		width = 0.4,
		height = 0.9,
		border = "rounded",
		title = "Copilot Chat",
		col = 2000,
		row = 1,
		footer = "",
		win_opts = {
			winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
		},
	},
	mappings = {
		reset = {
			normal = "<C-c>",
			insert = "<C-c>",
		},
		close = {
			normal = "q",
		},
	},
	-- Enable the picker for agents and prompts
	picker = {
		enabled = true,
	},
	-- Custom prompts
	-- prompts = {
	--   CreateOnComment = {
	--     prompt = 'Create the piece of code for the selected comment',
	--   },
	-- }
})

vim.keymap.set({ "n", "v" }, "<leader>zz", ":CopilotChat<CR>", { desc = "Chat with Copilot" })
vim.keymap.set("v", "<leader>ze", ":CopilotChatExplain<CR>", { desc = "Explain" })
vim.keymap.set("v", "<leader>zr", ":CopilotChatReview<CR>", { desc = "Review" })
vim.keymap.set("v", "<leader>zf", ":CopilotChatFix<CR>", { desc = "Fix" })
vim.keymap.set("v", "<leader>zo", ":CopilotChatOptimize<CR>", { desc = "Optimize" })
vim.keymap.set("v", "<leader>zd", ":CopilotChatDocs<CR>", { desc = "GenerateDocs" })
vim.keymap.set("v", "<leader>zt", ":CopilotChatTests<CR>", { desc = "Generate Tests" })
vim.keymap.set("n", "<leader>zc", ":CopilotChatCommit<CR>", { desc = "Write commit message" })
vim.keymap.set("n", "<leader>zM", ":CopilotChatModels<CR>", { desc = "Select Chat model" })
vim.keymap.set("n", "<leader>zA", ":CopilotChatAgent<CR>", { desc = "Select Chat model" })
-- vim.keymap.set("v", "<leader>zm", ":CopilotChatCreateOnComment<CR>", { desc = "Create on Comment" })
