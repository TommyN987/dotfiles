-- Markdown editing (spec §12.2–12.3).

vim.opt_local.spell = true
-- Long lines wrap on screen (globally off), breaking at word boundaries.
vim.opt_local.wrap = true
vim.opt_local.linebreak = true
-- Real line breaks at 80 columns while typing.
vim.opt_local.textwidth = 80

-- Enter / o on a list item or quote starts the next one. Neovim's default
-- leaders are "fb:-" etc., where "f" keeps the bullet on the first line only.
vim.opt_local.comments = "b:*,b:-,b:+,n:>"
vim.opt_local.formatoptions:append("ro")
