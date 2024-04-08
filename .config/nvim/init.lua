require("core.settings")
require("core.keymaps")
if not vim.g.vscode then
  require("core.plugins")
  require("core.plugin_config")
end

