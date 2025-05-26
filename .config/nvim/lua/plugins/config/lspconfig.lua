-- Setup LSP servers with capabilities
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local lspconfig = require("lspconfig")

-- Manually setup each server
local servers = { "lua_ls", "sqlls", "ruff", "terraformls", "dockerls", "pyright", "ts_ls" }
for _, server in ipairs(servers) do
	lspconfig[server].setup({
		capabilities = capabilities,
	})
end
