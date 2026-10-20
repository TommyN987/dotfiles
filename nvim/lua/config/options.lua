vim.opt.termguicolors = true

vim.g.netrw_banner = 0

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.wrap = false

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.laststatus = 3

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true

-- Words added with `zg` go into this repo, so the dictionary travels between machines.
-- `zg` fails (E484) if the folder doesn't exist yet.
local spell_dir = vim.fn.stdpath("config") .. "/spell"
vim.fn.mkdir(spell_dir, "p")
local word_list = spell_dir .. "/en.utf-8.add"
vim.opt.spellfile = word_list

-- Only the word list is committed (.gitignore): the compiled .spl would conflict
-- when both machines add words. Neovim doesn't rebuild it by itself, so rebuild
-- it when it's missing or older than the word list (e.g. after a pull).
local word_list_stat = vim.uv.fs_stat(word_list)
local compiled_stat = vim.uv.fs_stat(word_list .. ".spl")
if word_list_stat and (not compiled_stat or compiled_stat.mtime.sec < word_list_stat.mtime.sec) then
	vim.cmd("silent mkspell! " .. vim.fn.fnameescape(word_list))
end

vim.opt.clipboard:append("unnamedplus")
vim.opt.isfname:append("@-@")
vim.opt.hlsearch = true

vim.opt.colorcolumn = "100"
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.o.cmdheight = 0

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking text",
	callback = function()
		vim.hl.on_yank()
	end,
})
