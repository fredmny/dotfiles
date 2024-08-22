local null_ls = require("null-ls")

null_ls.setup({
	sources = {
		null_ls.builtins.formatting.stylua,
		null_ls.builtins.diagnostics.sqlfluff,
		null_ls.builtins.formatting.sqlfluff,
		null_ls.builtins.formatting.prettier,
		-- null_ls.builtins.diagnostics.eslint_d,
		null_ls.builtins.formatting.black,
		null_ls.builtins.formatting.isort,
		null_ls.builtins.formatting.yamlfmt,
		null_ls.builtins.diagnostics.yamllint,
		null_ls.builtins.diagnostics.actionlint,
		null_ls.builtins.diagnostics.checkmake,
		-- null_ls.builtins.completion.spell,
	},
})
