-- Drop LazyVim's scroll percentage, cursor position and clock from the statusline.
return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.sections.lualine_y = {}
      opts.sections.lualine_z = {}
    end,
  },
}
