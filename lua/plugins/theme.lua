return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      flavour = "auto", -- follows 'background', which Neovim reads from the terminal
      background = { light = "latte", dark = "mocha" },
      term_colors = true,
      transparent_background = true,
      float = { transparent = true },
    },
  },
  { "LazyVim/LazyVim", opts = { colorscheme = "catppuccin-nvim" } },
}
