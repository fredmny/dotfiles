vim.keymap.set("n", "<leader>h", ":nohlsearch<cr>", { desc = "Clear search highlights" })
vim.keymap.set("n", "<leader>w", ":w<cr>", { desc = "Save file" })
vim.keymap.set("n", "<leader>qq", ":q<cr>", { desc = "Quit" })
vim.keymap.set("n", "<leader>qw", ":wq<cr>", { desc = "Save and quit" })
-- Quickfix list
vim.keymap.set("n", "qn", ":cnext<cr>", { desc = "Next quickfix item" })
vim.keymap.set("n", "qp", ":cprev<cr>", { desc = "Previous quickfix item" })
-- vim.keymap.set('n', '<leader>qq', ':q!<cr>')
vim.keymap.set("n", "<leader>j", ":bn<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>k", ":bp<cr>", { desc = "Previous buffer" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
vim.keymap.set("n", "<leader>bo", ":1, $-1 bd <cr>", { desc = "Delete all buffers except current" })
vim.keymap.set("n", "<leader>-", ":Twilight <cr>", { desc = "Toggle Twilight" })
-- GitSigns
vim.keymap.set("n", "<leader>gb", ":Gitsigns blame_line <cr>", { desc = "Git blame line" })
vim.keymap.set("n", "<leader>gj", ":Gitsigns next_hunk <cr>", { desc = "Next git hunk" })
vim.keymap.set("n", "<leader>gk", ":Gitsigns prev_hunk <cr>", { desc = "Previous git hunk" })
vim.keymap.set("n", "<leader>gp", ":Gitsigns preview_hunk <cr>", { desc = "Preview git hunk" })
vim.keymap.set("n", "<leader>gtb", ":Gitsigns toggle_current_line_blame <cr>", { desc = "Toggle git line blame" })
-- LSP
-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		-- Enable completion triggered by <c-x><c-o>
		vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

		-- Buffer local mappings.
		-- See `:help vim.lsp.*` for documentation on any of the below functions
		local opts = { buffer = ev.buf }
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = ev.buf, desc = "Go to declaration" })
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf, desc = "Go to definition" })
		vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = ev.buf, desc = "Show hover documentation" })
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = ev.buf, desc = "Go to implementation" })
		vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { buffer = ev.buf, desc = "Show diagnostics" })
		-- vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
		-- vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
		-- vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
		-- vim.keymap.set('n', '<leader>wl', function()
		--   print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		-- end, opts)
		vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, { buffer = ev.buf, desc = "Go to type definition" })
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = ev.buf, desc = "Rename symbol" })
		-- vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
		vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = ev.buf, desc = "Show references" })
		vim.keymap.set("n", "<leader>f", function()
			vim.lsp.buf.format({ async = true })
		end, { buffer = ev.buf, desc = "Format file" })
	end,
})
-- none-ls related
-- Misc
vim.keymap.set("n", "<Leader>bt", ":tabnew %<CR>", { desc = "Open current buffer in new tab" })
