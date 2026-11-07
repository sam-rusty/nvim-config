-- LazyVim's defaults: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

-- Use the native TypeScript 7 language server (`tsc --lsp`). vtsls wraps tsserver,
-- which TypeScript 7 no longer ships.
vim.g.lazyvim_ts_lsp = "tsc"

-- Agents edit the same files, so swap files would only produce E325 prompts.
-- Persistent undo (on by default in LazyVim) is the recovery path instead.
vim.o.swapfile = false

-- VS Code/Zed style selection: Shift+arrows select, and typing replaces a selection
-- made with Shift+arrows or the mouse. Selections made with v/V still take Vim commands.
vim.o.keymodel = "startsel,stopsel"
vim.o.selectmode = "mouse,key"
