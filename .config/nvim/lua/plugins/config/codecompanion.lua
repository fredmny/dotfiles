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
            default = "claude-3-5-sonnet-20241022",
          },
        },
      })
    end,
  },
  display = {
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
