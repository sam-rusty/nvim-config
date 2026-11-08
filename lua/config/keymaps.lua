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

-- A few VS Code/Zed habits, kept only where they don't hide a Vim key. In normal and
-- visual mode y/d/p already use the system clipboard (LazyVim sets 'clipboard'), and
-- Cmd-V pastes in every mode, so Ctrl-c/x/v, Ctrl-a, Ctrl-d and Ctrl-f stay Vim's.
-- LazyVim already maps Ctrl-s to save.
local map = vim.keymap.set

map("i", "<C-v>", "<C-r><C-o>+", { desc = "Paste" })
map("c", "<C-v>", "<C-r>+", { desc = "Paste" })
map("i", "<C-z>", "<Cmd>undo<CR>", { desc = "Undo" })

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

-- Find in project. Ctrl-Shift-f only arrives if the terminal reports Shift with Ctrl;
-- otherwise use Space /. In a file, use / (or * on a selection).
map("n", "<C-S-f>", function()
  Snacks.picker.grep({ cwd = LazyVim.root() })
end, { desc = "Find in Project" })
map("v", "<C-S-f>", function()
  Snacks.picker.grep_word({ cwd = LazyVim.root() })
end, { desc = "Find Selection in Project" })

map({ "n", "i" }, "<A-Up>", "<Cmd>silent! move .-2<CR>", { desc = "Move Line Up" })
map({ "n", "i" }, "<A-Down>", "<Cmd>silent! move .+1<CR>", { desc = "Move Line Down" })
map("v", "<A-Up>", ":move '<-2<CR>gv", { silent = true, desc = "Move Selection Up" })
map("v", "<A-Down>", ":move '>+1<CR>gv", { silent = true, desc = "Move Selection Down" })
