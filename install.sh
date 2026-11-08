#!/usr/bin/env bash
# Sets up this Neovim config on macOS or Linux. Safe to run again to sync a machine.
#
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/sam-rusty/nvim-config/main/install.sh)"
#
# Use that form rather than `curl | bash`: Homebrew's installer needs a real terminal
# to ask for your password.
set -euo pipefail

REPO="${NVIM_CONFIG_REPO:-https://github.com/sam-rusty/nvim-config.git}"
DEST="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
DATA="${XDG_DATA_HOME:-$HOME/.local/share}/nvim"
OS="$(uname -s)"

# Keep these two lists in step: a Mason package and the binary it provides can differ.
MASON_PKGS="codelldb json-lsp lua-language-server markdown-toc markdownlint-cli2 marksman prettier shfmt stylua taplo tsc yaml-language-server"
MASON_BINS="codelldb vscode-json-language-server lua-language-server markdown-toc markdownlint-cli2 marksman prettier shfmt stylua taplo tsc yaml-language-server"

LOG="$(mktemp -t nvim-install.XXXXXX)"
PARSERS_OK=0

step() { printf '\n==> %s\n' "$1"; }
die() {
  printf '\nError: %s\n' "$1" >&2
  exit 1
}
has() { command -v "$1" >/dev/null 2>&1; }
has_display() { [ -n "${DISPLAY:-}" ] || [ -n "${WAYLAND_DISPLAY:-}" ]; }

# Runs a noisy command with its output in the log, shown only if the command fails.
quiet() {
  if ! "$@" >>"$LOG" 2>&1; then
    tail -n 30 "$LOG" >&2
    die "command failed: $1 (full log: $LOG)"
  fi
}

linux_packages() {
  local packages=("$@")
  [ "${#packages[@]}" -gt 0 ] || return 0
  local sudo=""
  if [ "$(id -u)" -ne 0 ]; then
    has sudo || die "sudo is needed to install: ${packages[*]}"
    sudo="sudo"
  fi
  if has apt-get; then
    $sudo apt-get update -qq
    DEBIAN_FRONTEND=noninteractive $sudo apt-get install -y -qq "${packages[@]}"
  elif has dnf; then
    $sudo dnf install -y -q "${packages[@]}"
  elif has pacman; then
    $sudo pacman -S --needed --noconfirm "${packages[@]}"
  elif has zypper; then
    $sudo zypper --non-interactive install "${packages[@]}"
  else
    die "no supported package manager found. Install these yourself and rerun: ${packages[*]}"
  fi
}

# What Homebrew and Mason need before they can run. Mason unpacks some tools with unzip.
install_linux_prerequisites() {
  local needed=0 tool
  for tool in git curl gcc g++ make unzip tar gzip file ps; do
    has "$tool" || needed=1
  done
  if [ "$needed" -eq 1 ]; then
    step "Installing system packages"
    if has apt-get; then
      linux_packages git curl ca-certificates build-essential unzip tar gzip file procps
    elif has dnf; then
      linux_packages git curl gcc gcc-c++ make unzip tar gzip file procps-ng
    elif has pacman; then
      linux_packages git curl base-devel unzip tar gzip file procps-ng
    elif has zypper; then
      linux_packages git curl gcc gcc-c++ make unzip tar gzip file procps
    else
      die "no supported package manager found. Install git, curl, gcc, g++, make, unzip, tar, gzip, file and ps, then rerun."
    fi
  fi

  # Marksman, the Markdown language server, crashes on startup without ICU. Minimal systems
  # don't have it, and nothing reports that until you open a Markdown file.
  if ! { ldconfig -p 2>/dev/null || /sbin/ldconfig -p 2>/dev/null; } | grep -q libicuuc; then
    step "Installing ICU"
    if has apt-get; then
      linux_packages libicu-dev
    elif has dnf; then
      linux_packages libicu
    elif has pacman; then
      linux_packages icu
    elif has zypper; then
      linux_packages libicu-devel
    fi
  fi

  # The keymaps copy and paste through the + register, which needs a clipboard tool on Linux.
  # Over SSH Neovim uses the terminal's clipboard instead, so servers can skip this.
  if has_display && ! has xclip && ! has wl-copy; then
    step "Installing clipboard tools"
    linux_packages xclip wl-clipboard
  fi
}

install_linux_font() {
  # The font belongs on the machine running the terminal, so skip machines with no display.
  has_display || return 0
  local fonts="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
  [ -d "$fonts" ] && return 0
  step "Installing JetBrainsMono Nerd Font"
  local archive
  archive="$(mktemp -t nerd-font.XXXXXX)"
  curl -fsSL -o "$archive" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
  mkdir -p "$fonts"
  unzip -qo "$archive" -d "$fonts"
  rm -f "$archive"
  if has fc-cache; then fc-cache -f "$fonts"; fi
}

find_brew() {
  local candidate
  for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew "$HOME/.linuxbrew/bin/brew"; do
    if [ -x "$candidate" ]; then
      echo "$candidate"
      return 0
    fi
  done
  return 1
}

install_homebrew() {
  local brew_bin
  if ! brew_bin="$(find_brew)"; then
    step "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew_bin="$(find_brew)" || die "Homebrew installed, but its brew command wasn't found."
  fi
  eval "$("$brew_bin" shellenv)"

  # Put brew on PATH for new shells too.
  local profile
  case "${SHELL:-}" in
    */zsh) profile="$HOME/.zprofile" ;;
    */bash) if [ "$OS" = Darwin ]; then profile="$HOME/.bash_profile"; else profile="$HOME/.bashrc"; fi ;;
    *) profile="$HOME/.profile" ;;
  esac
  if ! grep -qs 'brew shellenv' "$profile"; then
    printf '\neval "$(%s shellenv)"\n' "$brew_bin" >>"$profile"
  fi
}

install_config() {
  step "Fetching config"
  if [ -d "$DEST/.git" ]; then
    git -C "$DEST" pull --ff-only --quiet
  else
    if [ -e "$DEST" ]; then
      local backup
      backup="$DEST.bak.$(date +%s)"
      mv "$DEST" "$backup"
      echo "Moved your existing config to $backup"
    fi
    mkdir -p "$(dirname "$DEST")"
    git clone --quiet "$REPO" "$DEST"
  fi
}

install_rust_analyzer() {
  step "Installing Rust and rust-analyzer"
  export PATH="$HOME/.cargo/bin:$PATH"
  if has rustup; then
    quiet rustup component add rust-analyzer
  else
    curl -fsSL https://sh.rustup.rs | quiet sh -s -- -y --component rust-analyzer
  fi
}

install_neovim_parts() {
  step "Installing plugins at the versions in lazy-lock.json"
  quiet nvim --headless "+Lazy! restore" +qa

  # nvim exits 0 even when one of these errors, so the results are checked below. MasonInstall
  # can also print a traceback after finishing, which is harmless and goes to the log.
  step "Installing language servers and formatters"
  quiet nvim --headless "+Lazy! load mason.nvim" "+MasonInstall $MASON_PKGS" +qa
  local bin
  for bin in $MASON_BINS; do
    [ -x "$DATA/mason/bin/$bin" ] || die "Mason tool is missing: $bin (full log: $LOG)"
  done

  # A parser that won't build only costs highlighting for that language, so warn rather than
  # abort. The usual cause is low memory: some parsers are killed while compiling on a 2 GB
  # machine. The second attempt covers one-off failures such as a dropped download.
  step "Installing Treesitter parsers"
  local attempt
  for attempt in 1 2; do
    install_parsers >>"$LOG" 2>&1 || true
    if parsers_complete >>"$LOG" 2>&1; then
      PARSERS_OK=1
      return 0
    fi
  done
}

install_parsers() {
  nvim --headless "+Lazy! load nvim-treesitter" \
    "+lua require('nvim-treesitter').install(LazyVim.opts('nvim-treesitter').ensure_installed, { max_jobs = 2 }):wait(600000)" +qa
}

parsers_complete() {
  nvim --headless "+Lazy! load nvim-treesitter" "+lua
    local have = {}
    for _, lang in ipairs(require('nvim-treesitter').get_installed()) do have[lang] = true end
    for _, lang in ipairs(LazyVim.opts('nvim-treesitter').ensure_installed) do
      if not have[lang] then
        print('Parser is missing: ' .. lang)
        vim.cmd.cquit()
      end
    end" +qa
}

# Points lazygit's diffs at delta. lazygit keeps its config in a different place per OS,
# so ask it. A config you have already customized is left alone.
configure_lazygit() {
  has lazygit && has delta || return 0
  local dir file
  dir="$(lazygit --print-config-dir)"
  file="$dir/config.yml"
  if [ -s "$file" ]; then
    grep -q 'diffRenderers' "$file" ||
      printf '\nNote: %s exists, so delta was not added. See the README to add it.\n' "$file"
    return 0
  fi
  step "Configuring lazygit to show diffs with delta"
  mkdir -p "$dir"
  cat >"$file" <<'YAML'
git:
  diffRenderers:
    - command: delta --{{colorScheme}} --paging=never
YAML
}

main() {
  case "$OS" in
    Darwin) ;;
    Linux)
      # Homebrew refuses to run as root.
      [ "$(id -u)" -ne 0 ] || die "run this as a normal user with sudo access, not as root."
      install_linux_prerequisites
      ;;
    *) die "unsupported system: $OS. This script supports macOS and Linux." ;;
  esac

  install_homebrew
  install_config

  step "Installing tools from the Brewfile"
  # brew bundle also upgrades whatever is outdated, so only run it when something is missing.
  # Otherwise rerunning this to sync a machine would change its Neovim version.
  if ! brew bundle check --file="$DEST/Brewfile" >/dev/null 2>&1; then
    quiet brew bundle --file="$DEST/Brewfile"
  fi
  if [ "$OS" = Linux ]; then install_linux_font; fi

  configure_lazygit
  install_rust_analyzer
  install_neovim_parts

  if [ "$PARSERS_OK" -eq 1 ]; then
    rm -f "$LOG"
  else
    printf '\nWarning: these Treesitter parsers did not build, so those languages lose highlighting:\n'
    grep -o 'Parser is missing: [a-z_]*' "$LOG" | sort -u | sed 's/Parser is missing: /  /' || true
    printf 'Low memory is the usual cause. Add swap or RAM, then rerun this script. Log: %s\n' "$LOG"
  fi
  printf '\nDone. Open a new shell and run nvim.\n'
  printf 'Set your terminal font to JetBrainsMono Nerd Font so icons display correctly.\n'
}

main "$@"
