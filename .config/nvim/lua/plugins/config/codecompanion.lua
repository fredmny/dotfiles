require("codecompanion").setup({
	strategies = {
		chat = {
			adapter = "copilot",
		},
		inline = {
			adapter = "copilot",
		},
		cmd = {
			adapter = "copilot",
		},
	},
	adapters = {
		copilot = function()
			return require("codecompanion.adapters").extend("copilot", {
				schema = {
					model = {
						default = "claude-sonnet-4", -- Default model to use
					},
				},
			})
		end,
	},
	display = {
		chat = {
			window = {
				layout = "vertical", -- float|vertical|horizontal|buffer
				position = "right", -- left|right|top|bottom (nil will default depending on vim.opt.splitright|vim.opt.splitbelow)
				border = "single",
				height = 0.8,
				width = 0.45,
				relative = "editor",
				full_height = true,
				opts = {
					breakindent = true,
					cursorcolumn = false,
					cursorline = false,
					foldcolumn = "0",
					linebreak = true,
					list = false,
					numberwidth = 1,
					signcolumn = "no",
					spell = false,
					wrap = true,
				},
			},
		},
		action_palette = {
			width = 95,
			height = 10,
			prompt = "Prompt ", -- Prompt used for interactive LLM calls
			provider = "default", -- Can be "default", "telescope", "fzf_lua", "mini_pick" or "snacks". If not specified, the plugin will autodetect installed providers.
			opts = {
				show_default_actions = true, -- Show the default actions in the action palette?
				show_default_prompt_library = true, -- Show the default prompt library in the action palette?
			},
		},
	},
	extensions = {
		mcphub = {
			callback = "mcphub.extensions.codecompanion",
			opts = {
				make_vars = true,
				make_slash_commands = true,
				show_result_in_chat = true,
			},
		},
	},
	prompt_library = {
		["Review code"] = {
			strategy = "chat",
			description = "Review code for quality and issues",
			opts = {
        short_name = "review",
				auto_submit = true, -- Automatically submit the prompt after filling in the code
				stop_context_insertion = true, -- Stop inserting context when the prompt is submitted
				user_prompt = true,
        contains_code = true, -- Whether the prompt contains code
			},
			prompts = {
				{
					role = "system",
					content = "You are an experienced software engineer. Apart from being a great professional you're also a good teacher in all topics related to software engineering",
				},
				{
					role = "user",
					content = function(context)
						return "Please review the code from buffer "
							.. " for quality, issues, and potential improvements. "
							.. "Provide a detailed analysis and suggestions for enhancement. "
							.. "You should review it carefully but also not try to overdo it on changes. "
							.. "Evaluate if the change really makes sense before suggesting it. "
							.. "You should enumerate the codeblock for each suggested change, "
							.. "so that it can be easily referred to in the following of the conversation. "
              -- .. "After showing the initial review you should apply each change, if the user confirms it. "
              -- .. "For this suggest the first change - then wait for confirmation - suggest the second change - wait for confirmation ... and so on"
              .. "\n\n"
              .. "#buffer"
              .. "\n"
              .. "@editor"

					end,
					opts = {
						contains_code = true,
					},
				},
			},
		},
	},
})

vim.keymap.set({ "n", "v" }, "<leader>cc", ":CodeCompanionChat<CR>", { desc = "Chat with CodeCompanion" })
vim.keymap.set({ "n", "v" }, "<leader>cz", ":CodeCompanionActions<CR>", { desc = "CodeCompanion Actions" })
vim.keymap.set({ "n", "v" }, "<leader>ci", ":CodeCompanion<CR>", { desc = "CodeCompanion Inline" })
vim.keymap.set("v", "<leader>ce", function()
	require("codecompanion").prompt("cw")
end, { noremap = true, silent = true, desc = "Use workflow to guide LLM" })
vim.keymap.set("v", "<leader>ce", function()
	require("codecompanion").prompt("explain")
end, { noremap = true, silent = true, desc = "Explain" })
vim.keymap.set("v", "<leader>cf", function()
	require("codecompanion").prompt("fix")
end, { noremap = true, silent = true, desc = "Fix" })
vim.keymap.set("v", "<leader>cl", function()
	require("codecompanion").prompt("lsp")
end, { noremap = true, silent = true, desc = "Explain LSP diagnostics" })
-- vim.keymap.set("v", "<leader>cd", function() require("codecompanion").prompt("docs") end, {noremap = true, silent = true, desc = "GenerateDocs" })
vim.keymap.set("v", "<leader>ct", function()
	require("codecompanion").prompt("tests")
end, { noremap = true, silent = true, desc = "Generate Tests" })
vim.keymap.set("n", "<leader>cm", function()
	require("codecompanion").prompt("commit")
end, { noremap = true, silent = true, desc = "Write commit message" })
vim.keymap.set("n", "<leader>cr", function()
	require("codecompanion").prompt("review")
end, { noremap = true, silent = true, desc = "Review Code" })
-- vim.keymap.set("v", "<leader>cm", ":CopilotChatCreateOnComment<CR>", { desc = "Create on Comment" })
