-- LazyVim's defaults: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

-- Keep buffers in sync with files that agents write.
--
-- LazyVim only re-checks files on focus changes, which misses edits made while you are
-- looking at Neovim. A timer also survives the atomic renames that break per-file watchers.
local group = vim.api.nvim_create_augroup("agent_file_sync", { clear = true })

local timer = assert(vim.uv.new_timer())
timer:start(
  1000,
  1000,
  vim.schedule_wrap(function()
    -- Only from plain normal mode: never while typing, in a picker, or in lazygit.
    if vim.api.nvim_get_mode().mode == "n" and vim.fn.getcmdwintype() == "" then
      vim.cmd("silent! checktime")
    end
  end)
)

-- Defining this autocmd replaces Neovim's blocking W12 prompt, where a stray keystroke
-- could pick an answer for you.
vim.api.nvim_create_autocmd("FileChangedShell", {
  group = group,
  callback = function(event)
    local reason = vim.v.fcs_reason
    local name = vim.fn.fnamemodify(event.file, ":~:.")

    if reason == "changed" or reason == "mode" then
      vim.v.fcs_choice = "reload" -- `u` undoes the reload if you want the old text back
    elseif reason == "conflict" then
      -- Neovim records the new mtime here, so a later :w would silently overwrite the
      -- agent's work. 'readonly' makes :w ask first (LazyVim sets 'confirm').
      vim.v.fcs_choice = ""
      vim.schedule(function()
        vim.bo[event.buf].readonly = true
        vim.notify(
          name .. " changed on disk while you had unsaved edits.\n"
            .. ":e!  take the file on disk\n"
            .. ":w!  keep your edits and overwrite it",
          vim.log.levels.WARN,
          { title = "File conflict" }
        )
      end)
    elseif reason == "deleted" then
      vim.v.fcs_choice = ""
      vim.schedule(function()
        vim.notify(name .. " was deleted on disk. The buffer still holds its text.", vim.log.levels.WARN)
      end)
    else
      vim.v.fcs_choice = ""
    end
  end,
})
