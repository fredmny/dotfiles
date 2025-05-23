require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = { "lua_ls", "sqlls", "ruff" },
})

local capabilities = require("cmp_nvim_lsp").default_capabilities()

require("lspconfig").lua_ls.setup({
	capabilities = capabilities,
})
require("lspconfig").terraformls.setup({
	capabilities = capabilities,
})
require("lspconfig").dockerls.setup({
	capabilities = capabilities,
})
require("lspconfig").sqlls.setup({
	capabilities = capabilities,
})
require("lspconfig").ruff.setup({
	capabilities = capabilities,
})
require("lspconfig").pyright.setup({
	capabilities = capabilities,
})
require("lspconfig").ts_ls.setup({
  capabilities = capabilities,
})
-- require("lspconfig").eslint.setup({
-- 	capabilities = capabilities,
-- })
