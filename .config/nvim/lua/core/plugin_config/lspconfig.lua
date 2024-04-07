require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "lua_ls", "pyright", "sqlls"}
})

require("lspconfig").lua_ls.setup {}
require("lspconfig").terraformls.setup {}
require("lspconfig").dockerls.setup {}
