return {
  -- Side-by-side review of what an agent changed.
  {
    "esmuellert/codediff.nvim",
    cmd = "CodeDiff",
    keys = {
      { "<leader>gv", "<cmd>CodeDiff<cr>", desc = "Review Changes (side by side)" },
      { "<leader>gV", "<cmd>CodeDiff main<cr>", desc = "Review Changes Against main" },
      { "<leader>gH", "<cmd>CodeDiff history %<cr>", desc = "File History (side by side)" },
      { "<leader>gH", ":CodeDiff history<cr>", mode = "x", desc = "Selected Lines History" },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "css", "diff", "git_config", "git_rebase", "gitcommit", "gitignore" },
    },
  },
}
