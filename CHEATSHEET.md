# Neovim cheatsheet

`<leader>` is **Space**. Press it and wait: a menu shows every key that can follow.
New to Vim? Run `:Tutor` once. It takes about 30 minutes and teaches everything below.

## Modes and moving

| Key | Action |
|---|---|
| `i` / `a` / `o` | Type before the cursor / after it / on a new line |
| `Esc` | Back to normal mode |
| `v` / `V` / `Ctrl-v` | Select characters / whole lines / a column block |
| `h j k l` | Left, down, up, right |
| `w` / `b` | Next word / previous word |
| `0` / `$` | Start / end of line |
| `gg` / `G` | Top / bottom of file |
| `Ctrl-d` / `Ctrl-u` | Half a page down / up |
| `s` | Jump anywhere: type 2 letters, then the label that appears |

## Editing

| Key | Action |
|---|---|
| `Ctrl-s` | Save (also formats) |
| `u` / `Ctrl-r` | Undo / redo |
| `dd` / `yy` / `p` | Cut line / copy line / paste (all use the system clipboard; `Cmd-v` pastes too) |
| `yyp` | Duplicate a line |
| `ciw` / `ci"` / `cif` | Replace the word / the text in quotes / a function body (`d` deletes, `v` selects) |
| `gsa` `iw` `"` | Put quotes around a word. `gsd"` deletes them, `gsr"'` swaps for `'` |
| `Ctrl-a` / `Ctrl-x` | Increase / decrease the number under the cursor |
| `gcc` | Toggle comment |
| `.` | Repeat the last change |
| `/text` then `n` | Search, then next match (`*` searches the word or selection) |
| `cgn` then `.` | Change the next match, then repeat on each one after (instead of multi-cursor) |

## Files and search

| Key | Action |
|---|---|
| `Ctrl-p` or `Space Space` | Find file |
| `Ctrl-Shift-f` or `Space /` | Find in project |
| `Space s r` | Search and replace across the project |
| `Space e` | File tree |
| `Shift-h` / `Shift-l` | Previous / next open tab |
| `Space b d` | Close tab |
| `Space \|` / `Space -` | Split right / below |
| `Ctrl-h j k l` | Move between splits |
| `Space q q` | Quit everything |

## Code

| Key | Action |
|---|---|
| `K` | Show type and docs |
| `gd` / `gr` | Go to definition / find references |
| `Ctrl-o` | Jump back |
| `Space c a` | Code action / quick fix |
| `Space c r` | Rename symbol |
| `Space c f` | Format |
| `]d` / `[d` | Next / previous diagnostic |
| `Space x x` | All diagnostics |
| `Enter` / `Ctrl-e` | Accept / dismiss completion |

## Rust

| Key | Action |
|---|---|
| `:RustLsp testables` | Pick a test to run (nextest). Failures show as diagnostics on the test |
| `Space d b` | Toggle breakpoint |
| `Space d r` | Debug a test or binary |
| `Space d c` | Continue to the next breakpoint |

## Reviewing agent changes

Open files reload by themselves when an agent writes them. `u` undoes a reload.

| Key | Action |
|---|---|
| `Space g v` | Side-by-side review of everything changed |
| `Space g V` | Same, compared with `main` |
| `Space g d` | Picker of every changed block, with preview |
| `Space g H` | Side-by-side history of this file (of the selected lines, in visual mode) |
| `]f` / `[f` | In review: next / previous file |
| `]c` / `[c` | In review: next / previous change |
| `-` | In review: stage or unstage the file |
| `q` | In review: close |
| `]h` / `[h` | In a file: next / previous changed block |
| `Space g h p` | Preview the changed block |
| `Space g h r` | Revert the changed block |
| `Space g h s` | Stage the changed block (`vih` selects it) |
| `Space g g` | Lazygit |
| `Space a c` | Claude Code in a split. In Claude Code, `/ide` connects to this Neovim |
| `Space a s` | In visual mode: send the selection to Claude |
| `Space a a` / `Space a d` | Accept / deny a change Claude proposes |

**If an agent changes a file while you have unsaved edits**, nothing is lost and a warning
appears. Run `:e!` to take the agent's version, or `:w!` to keep yours.

## Settings and upkeep

| Key | Action |
|---|---|
| `Space u C` | Preview and switch color themes |
| `Space u l` / `Space u L` | Toggle line numbers / relative numbers |
| `Space u f` | Toggle format on save |
| `Space l` | Plugins (`U` updates them) |
| `Space c m` | Installed language tools |
| `Space H` | This cheatsheet |
