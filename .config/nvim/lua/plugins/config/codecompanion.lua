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
    }
  },
  adapters = {
    copilot = function()
      return require("codecompanion.adapters").extend("copilot", {
        schema = {
          model = {
            -- default = "claude-3-7-sonnet",
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
})

vim.keymap.set({ "n", "v" }, "<leader>cc", ":CodeCompanionChat<CR>", { desc = "Chat with CodeCompanion" })
vim.keymap.set({ "n", "v" }, "<leader>cz", ":CodeCompanionActions<CR>", { desc = "CodeCompanion Actions" })
vim.keymap.set({ "n", "v" }, "<leader>ci", ":CodeCompanion<CR>", { desc = "CodeCompanion Inline" })
vim.keymap.set("v", "<leader>ce", function() require("codecompanion").prompt("cw") end, {noremap = true, silent = true, desc = "Use workflow to guide LLM" })
vim.keymap.set("v", "<leader>ce", function() require("codecompanion").prompt("explain") end, {noremap = true, silent = true, desc = "Explain" })
vim.keymap.set("v", "<leader>cf", function() require("codecompanion").prompt("fix") end, {noremap = true, silent = true, desc = "Fix" })
vim.keymap.set("v", "<leader>cl", function() require("codecompanion").prompt("lsp") end, {noremap = true, silent = true, desc = "Explain LSP diagnostics" })
-- vim.keymap.set("v", "<leader>cd", function() require("codecompanion").prompt("docs") end, {noremap = true, silent = true, desc = "GenerateDocs" })
vim.keymap.set("v", "<leader>ct", function() require("codecompanion").prompt("tests") end, {noremap = true, silent = true, desc = "Generate Tests" })
vim.keymap.set("n", "<leader>cm", function() require("codecompanion").prompt("commit") end, {noremap = true, silent = true, desc = "Write commit message" })
-- vim.keymap.set("v", "<leader>cm", ":CopilotChatCreateOnComment<CR>", { desc = "Create on Comment" })
