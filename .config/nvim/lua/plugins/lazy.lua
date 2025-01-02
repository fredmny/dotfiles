-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
	-- spec = {
	--   -- import your plugins
	--   { import = "plugins" },
	-- },
	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	install = { colorscheme = { "habamax" } },
	-- automatically check for plugin updates
	checker = { enabled = true },
	-- Plugins
	{ "catppuccin/nvim", name = "catppuccin", priority = 1000 },
	"nvim-tree/nvim-tree.lua",
	{
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
  },
	"nvim-lualine/lualine.nvim",
	-- "ellisonleao/gruvbox.nvim",
	"nvim-tree/nvim-tree.lua",
	"nvim-tree/nvim-web-devicons",
	-- Diffview
	"sindrets/diffview.nvim",
	-- "rcarriga/nvim-notify",
	-- for auto commenting with vim shortcut
	{
		"numToStr/Comment.nvim",
	},
	{
		"windwp/nvim-autopairs",
	},
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.2",
		dependencies = { { "nvim-lua/plenary.nvim" } },
	},
	"nvim-telescope/telescope-ui-select.nvim",
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { { "nvim-lua/plenary.nvim" } },
	},
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	"folke/twilight.nvim",
	{
		"nvim-treesitter/nvim-treesitter",
		run = "TSUpdate",
	},
	"christoomey/vim-tmux-navigator",
	"PedramNavid/dbtpal",
	-- For LSPs
	"williamboman/mason.nvim",
	"williamboman/mason-lspconfig.nvim",
	"neovim/nvim-lspconfig",
	-- none-ls
	"nvimtools/none-ls.nvim",
	-- Debugger
	"mfussenegger/nvim-dap",
	{
		"rcarriga/nvim-dap-ui",
		dependencies = {
			"mfussenegger/nvim-dap",
			"nvim-neotest/nvim-nio",
		},
	},
	"mfussenegger/nvim-dap-python",
	-- LSPsaga - has a lot of options to explore
	{
		"nvimdev/lspsaga.nvim",
		after = "nvim-lspconfig",
	},
	-- For which-key
	{"folke/which-key.nvim"},
	-- Git related
	"lewis6991/gitsigns.nvim",
	"tpope/vim-fugitive",
	"ThePrimeagen/git-worktree.nvim",
	-- For displaying indentation
	"lukas-reineke/indent-blankline.nvim",

	-- COMPLETIONS --
	"hrsh7th/nvim-cmp",
	"hrsh7th/cmp-nvim-lsp",
	{
		"L3MON4D3/LuaSnip",
		dependencies = {
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",
		},
	},
	"onsails/lspkind.nvim",
	-- CODEIUM
	{
		"Exafunction/codeium.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"hrsh7th/nvim-cmp",
		},
	},
  {
    'stevearc/oil.nvim',
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {},
    -- Optional dependencies
    dependencies = { { "echasnovski/mini.icons", opts = {} } },
    -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
  },
})

-- configure notify for telescope
