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
    http = {
      copilot = function()
        return require("codecompanion.adapters").extend("copilot", {
          schema = {
            model = {
              default = "claude-opus-4.5", -- Default model to use
            },
          },
        })
      end,
    }
	},
	memory = {
		opts = {
			chat = {
				enabled = true,
			},
		},
		agno = {
			description = "Memory files for Agno AI",
      parser = "claude",
			files = {
				vim.fn.expand("~/.config/nvim/llm-context/agno-ai.txt"),
			},
		},
	},
    display = {
      diff = {
        provider_opts = {
          split = {
            close_chat_at = 240, -- Close an open chat buffer if the total columns of your display are less than...
            layout = "vertical", -- vertical|horizontal split
            opts = {
              "internal",
              "filler",
              "closeoff",
              "algorithm:histogram", -- https://adamj.eu/tech/2024/01/18/git-improve-diff-histogram/
              "indent-heuristic", -- https://blog.k-nut.eu/better-git-diffs
              "followwrap",
              "linematch:120",
            },
          },
        },
      },
		chat = {
      auto_scroll = false,
      icons = {
        buffer_sync_all = "󰪴 ",
        buffer_sync_diff = " ",
        chat_context = " ",
        chat_fold = " ",
        tool_pending = "  ",
        tool_in_progress = "  ",
        tool_failure = "  ",
        tool_success = "  ",
      },
      fold_context = true,
      variables = {
        ["buffer"] = {
          opts = {
            -- Always sync the buffer by sharing its "diff"
            -- Or choose "all" to share the entire buffer
            default_params = "diff",
          },
        },
      },
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
    interactions = {
      chat = {
        -- The following decorates the prompt before sending it to the LLM
        -- Enclosing it in <prmompt> tags is how VS Code does it to make it clear this is user input
        opts = {
          ---Decorate the user message before it's sent to the LLM
          ---@param message string
          ---@param adapter CodeCompanion.Adapter
          ---@param context table
          ---@return string
          prompt_decorator = function(message, adapter, context)
            return string.format([[<prompt>%s</prompt>]], message)
          end,
          -- completion_provider = "cmp",
        }
      }
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
	prompt_library = require("plugins.config.codecompanion_prompts"),
})

vim.keymap.set({ "n", "v" }, "<leader>cc", ":CodeCompanionChat<CR>", { desc = "Chat with CodeCompanion" })
vim.keymap.set({ "n", "v" }, "<leader>ct", ":CodeCompanionChat Toggle<CR>", { desc = "CodeCompanion chat toggle" })
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
vim.keymap.set("v", "<leader>cpt", function()
	require("codecompanion").prompt("tests")
end, { noremap = true, silent = true, desc = "Generate Tests" })
vim.keymap.set("n", "<leader>cm", function()
	require("codecompanion").prompt("commit")
end, { noremap = true, silent = true, desc = "Write commit message" })
vim.keymap.set("n", "<leader>cpr", function()
vim.keymap.set({ "n", "v" }, "<leader>ci", ":CodeCompanionChat Toggle<CR>", { desc = "CodeCompanion chat toggle" })
	require("codecompanion").prompt("review")
end, { noremap = true, silent = true, desc = "Review Code" })
vim.keymap.set("n", "<leader>cpp", function()
	require("codecompanion").prompt("pr_description")
end, { noremap = true, silent = true, desc = "Create PR Description" })
vim.keymap.set("n", "<leader>cb", function()
	require("codecompanion").prompt("chat_with_buffer")
end, { noremap = true, silent = true, desc = "Chat window with current buffer" })
-- vim.keymap.set("v", "<leader>cm", ":CopilotChatCreateOnComment<CR>", { desc = "Create on Comment" })
