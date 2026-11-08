-- LazyVim's defaults: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

-- Zed's file finder, for muscle memory. <leader><space> does the same thing.
vim.keymap.set("n", "<C-p>", function()
  Snacks.picker.files({ cwd = LazyVim.root() })
end, { desc = "Find Files (Root Dir)" })

vim.keymap.set("n", "<leader>H", function()
  Snacks.win({
    file = vim.fn.stdpath("config") .. "/CHEATSHEET.md",
    title = " Cheatsheet (q to close) ",
    border = "rounded",
    width = 0.7,
    height = 0.85,
    bo = { modifiable = false },
    wo = { conceallevel = 2, wrap = false, number = false, relativenumber = false },
  })
end, { desc = "Open Cheatsheet" })

-- VS Code/Zed style editing, using Ctrl because terminals keep Cmd for themselves.
-- LazyVim already maps Ctrl-s to save.
local map = vim.keymap.set

-- Copy and cut act on the current line when nothing is selected.
map("v", "<C-c>", '"+y', { desc = "Copy" })
map("n", "<C-c>", '"+yy', { desc = "Copy Line" })
map("i", "<C-c>", '<Cmd>normal! "+yy<CR>', { desc = "Copy Line" })
map("v", "<C-x>", '"+d', { desc = "Cut" })
map("n", "<C-x>", '"+dd', { desc = "Cut Line" })
map("i", "<C-x>", '<Cmd>normal! "+dd<CR>', { desc = "Cut Line" })

map({ "n", "v" }, "<C-v>", '"+P', { desc = "Paste" })
map("i", "<C-v>", "<C-r><C-o>+", { desc = "Paste" })
map("c", "<C-v>", "<C-r>+", { desc = "Paste" })

-- Shift+Right should select one character, which needs selection=exclusive. Setting that
-- globally breaks snippet placeholders (`foo(${1:bar})` + X gives `foo(Xr)`), so it only
-- applies while a Shift selection is active.
for _, key in ipairs({ "<S-Left>", "<S-Right>", "<S-Up>", "<S-Down>", "<S-Home>", "<S-End>" }) do
  map({ "n", "i" }, key, function()
    vim.o.selection = "exclusive"
    return key
  end, { expr = true, replace_keycodes = true })
end
vim.api.nvim_create_autocmd("ModeChanged", {
  pattern = "*:[ni]",
  callback = function()
    vim.o.selection = "inclusive"
  end,
})

map("n", "<C-z>", "u", { desc = "Undo" })
map("i", "<C-z>", "<Cmd>undo<CR>", { desc = "Undo" })
map("n", "<C-y>", "<C-r>", { desc = "Redo" })
map("i", "<C-y>", "<Cmd>redo<CR>", { desc = "Redo" })

-- Find in file. With a selection, searches that exact text (\V = no regex).
map("n", "<C-f>", "/", { desc = "Find in File" })
map("i", "<C-f>", "<Esc>/", { desc = "Find in File" })
map("v", "<C-f>", [["zy/\V<C-r>=escape(@z, '/\')<CR><CR>]], { desc = "Find Selection in File" })

-- Find in project. Ctrl-Shift-f only arrives if the terminal reports Shift with Ctrl;
-- otherwise use Space /.
map("n", "<C-S-f>", function()
  Snacks.picker.grep({ cwd = LazyVim.root() })
end, { desc = "Find in Project" })
map("v", "<C-S-f>", function()
  Snacks.picker.grep_word({ cwd = LazyVim.root() })
end, { desc = "Find Selection in Project" })

map("n", "<C-a>", "ggVG", { desc = "Select All" })
map("i", "<C-a>", "<Esc>ggVG", { desc = "Select All" })

map({ "n", "i" }, "<C-d>", "<Cmd>t.<CR>", { desc = "Duplicate Line" })
map("v", "<C-d>", ":t'><CR>gv", { silent = true, desc = "Duplicate Selection" })

map({ "n", "i" }, "<A-Up>", "<Cmd>silent! move .-2<CR>", { desc = "Move Line Up" })
map({ "n", "i" }, "<A-Down>", "<Cmd>silent! move .+1<CR>", { desc = "Move Line Down" })
map("v", "<A-Up>", ":move '<-2<CR>gv", { silent = true, desc = "Move Selection Up" })
map("v", "<A-Down>", ":move '>+1<CR>gv", { silent = true, desc = "Move Selection Down" })
