vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.cursorline = true
vim.opt.autoread = true
vim.opt.showcmd = true

-- Better editor UI
vim.o.number = true
vim.o.relativenumber = true
vim.o.numberwidth = 3
vim.o.signcolumn = "yes:3"

-- Number of screen lines to keep above and below the cursor
vim.o.scrolloff = 8

-- Better editing experience
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.shiftround = true
vim.opt.expandtab = true
vim.opt.smarttab = true
--vim.opt.cindent = true
vim.opt.autoindent = true
vim.opt.wrap = true
vim.opt.textwidth = 300
vim.o.autoread = true

-- Makes neovim and host OS clipboard play nicely with each other
vim.o.clipboard = "unnamedplus"

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
-- use case sensitiveness with <leader>c
vim.o.smartcase = true

-- Undo and backup options
vim.o.backup = false
vim.o.writebackup = false
vim.o.undofile = true
vim.o.swapfile = false

-- Better buffer splitting
--vim.o.splitright = true
--vim.o.splitbelow = true

-- Use mouse on all modes
--vim.opt.mouse = "a"

vim.cmd([[ set noswapfile ]])
