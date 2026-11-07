-- Projects on Vite+ keep their formatter settings in vite.config.ts, and only `vp fmt` reads
-- that file. Plain oxfmt would ignore options like sortImports and undo them on every save.
local function vp_bin(ctx)
  return vim.fs.find("node_modules/.bin/vp", { upward = true, path = ctx.dirname })[1]
end

return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    opts.formatters = opts.formatters or {}
    opts.formatters.vp_fmt = {
      command = function(_, ctx)
        return vp_bin(ctx) or "vp"
      end,
      args = { "fmt", "--stdin-filepath", "$FILENAME" },
      stdin = true,
      cwd = function(_, ctx)
        local bin = vp_bin(ctx)
        return bin and vim.fn.fnamemodify(bin, ":h:h:h")
      end,
      condition = function(_, ctx)
        return vp_bin(ctx) ~= nil
      end,
    }

    opts.formatters_by_ft = opts.formatters_by_ft or {}
    for _, ft in ipairs({ "javascript", "javascriptreact", "typescript", "typescriptreact", "css" }) do
      opts.formatters_by_ft[ft] = { "vp_fmt", "prettier", stop_after_first = true }
    end
  end,
}
