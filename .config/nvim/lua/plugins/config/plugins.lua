return require("packer").startup(function(use)
	use("folke/snacks.nvim")
	use("wbthomason/packer.nvim")
	use({ "catppuccin/nvim", as = "catppuccin" })
	use("nvim-lualine/lualine.nvim")
	-- use("ellisonleao/gruvbox.nvim")
	use("nvim-tree/nvim-tree.lua")
	use("nvim-tree/nvim-web-devicons")
	-- Diffview
	use("sindrets/diffview.nvim")
	use("rcarriga/nvim-notify")
	-- for auto commenting with vim shortcut
	use({
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
		end,
	})
	use({
		"windwp/nvim-autopairs",
	})
	use({
		"nvim-telescope/telescope.nvim",
		tag = "0.1.2",
		requires = { { "nvim-lua/plenary.nvim" } },
	})
	use({ "nvim-telescope/telescope-ui-select.nvim" })
	use({
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		requires = { { "nvim-lua/plenary.nvim" } },
	})
	use({
		"folke/todo-comments.nvim",
		requires = { "nvim-lua/plenary.nvim" },
	})
	use("folke/twilight.nvim")
	use({
		"nvim-treesitter/nvim-treesitter",
		run = "TSUpdate",
	})
	use("christoomey/vim-tmux-navigator")
	use("PedramNavid/dbtpal")
	-- For LSPs
	use("williamboman/mason.nvim")
	use("williamboman/mason-lspconfig.nvim")
	use("neovim/nvim-lspconfig")
	-- none-ls
	use("nvimtools/none-ls.nvim")
	-- Debugger
	use("mfussenegger/nvim-dap")
	use({ "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" } })
	use("mfussenegger/nvim-dap-python")
	-- LSPsaga - has a lot of options to explore
	use({
		"nvimdev/lspsaga.nvim",
		after = "nvim-lspconfig",
	})
	-- For which-key
	use("folke/which-key.nvim")
	-- Git related
	use("lewis6991/gitsigns.nvim")
	use("tpope/vim-fugitive")
	use("ThePrimeagen/git-worktree.nvim")
	-- For displaying indentation
	use("lukas-reineke/indent-blankline.nvim")

	-- COMPLETIONS --
	use("hrsh7th/nvim-cmp")
	use("hrsh7th/cmp-nvim-lsp")
	use({
		"L3MON4D3/LuaSnip",
		requires = {
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",
		},
	})
	use("onsails/lspkind.nvim")
	-- CODEIUM
	use({
		"Exafunction/codeium.nvim",
		requires = {
			"nvim-lua/plenary.nvim",
			"hrsh7th/nvim-cmp",
		},
	})
	use({ "github/copilot.vim" })
	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if packer_bootstrap then
		require("packer").sync()
	end
end)
