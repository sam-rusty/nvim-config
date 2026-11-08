-- Start the Claude Code connection when Neovim opens, so `/ide` in a Claude Code running
-- in another terminal can find it. The extra only loads it on a <leader>a keypress.
return {
  "coder/claudecode.nvim",
  event = "VeryLazy",
}
