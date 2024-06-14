vim.g.mapleader = " "

local keymap = vim.keymap

keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- window management
keymap.set("n", "<leader>w/", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>w-", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>w=", "<C-w>=", { desc = "Make splits equal size" })
keymap.set("n", "<leader>wx", "<C-w>c", { desc = "Close current split" })

-- tab management
keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" })
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })

-- Diagnostic keymaps
keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Toggles undo tree" })

keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Moves highlighted section down" })
keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Moves highlighted section up" })

keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Re-centers screen when half page jump down" })
keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Re-centers screen when half page jump up" })
keymap.set("n", "n", "nzzzv", { desc = "Keeps search term in the center of the screen" })
keymap.set("n", "N", "Nzzzv", { desc = "Keeps search term in the center of the screen" })

keymap.set(
	"x",
	"<leader>p",
	[["_dP]],
	{ desc = "Keeps yanked word in the clipboard after pasting over a highlighted word" }
)

keymap.set("n", "<leader>y", '"+y', { desc = "Yanks to the system clipboard" })
keymap.set("v", "<leader>y", '"+y', { desc = "Yanks to the system clipboard" })
keymap.set("n", "<leader>Y", '"+y', { desc = "Yanks to the system clipboard" })

keymap.set("n", "<leader>d", '"_d', { desc = "Deletes to a void register" })
keymap.set("v", "<leader>d", '"_d', { desc = "Deletes to a void register" })

keymap.set("n", "<leader>fml", "<cmd>CellularAutomaton make_it_rain<CR>")
