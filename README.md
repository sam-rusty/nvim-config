# Neovim config

My [LazyVim](https://github.com/LazyVim/LazyVim) setup. Works on macOS and Linux.

## Install

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/sam-rusty/nvim-config/main/install.sh)"
```

This installs Homebrew if needed, the tools in the `Brewfile`, Rust with rust-analyzer,
the plugins at the versions in `lazy-lock.json`, language servers, and Treesitter parsers.
An existing `~/.config/nvim` is moved to a timestamped backup first.

On Linux, run it as a normal user with sudo access, not as root. It supports apt, dnf,
pacman and zypper.

Terminal settings aren't included, so set your terminal font to JetBrainsMono Nerd Font.

## Keeping machines in sync

Run `:Lazy update`, commit the changed `lazy-lock.json`, then rerun the install command on
the other machines.

If you add a Mason tool, add it to both lists at the top of `install.sh`.

`<leader>H` opens the [cheatsheet](CHEATSHEET.md).
