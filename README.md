# Neovim config — C/C++/Python, kernel, ns-3, Yocto/Buildroot

Lua config built on lazy.nvim. Requires **Neovim ≥ 0.11** (Fedora ships this).

## What you get

| Concern | Tool |
|---|---|
| C/C++ language server + static analysis | **clangd** with `--clang-tidy` enabled |
| Python type checking / static analysis | **basedpyright** |
| Python linting + import sorting | **ruff** (runs as an LSP) |
| Formatting on save | **conform.nvim** → clang-format, ruff |
| Syntax (incl. bitbake, dts, Kconfig) | nvim-treesitter |
| Completion + snippets | blink.cmp + friendly-snippets |
| Fuzzy find / grep | telescope + ripgrep |
| Git gutter + hunk staging | gitsigns |
| File manager | oil.nvim (press `-`) |
| Markdown | render-markdown.nvim (in-buffer) + markdown-preview.nvim (browser) |

All LSP servers and formatters are installed automatically through Mason on
first launch.

## Install (Fedora)

```sh
sudo dnf install neovim git gcc gcc-c++ make cmake unzip \
                 ripgrep fd-find nodejs npm python3-pip
```

Then copy this directory to `~/.config/nvim` (back up any existing config first):

```sh
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null
cp -r nvim ~/.config/nvim
nvim
```

First launch installs everything; wait for lazy.nvim, Mason, and `:TSUpdate`
to finish, then restart. Check health with `:checkhealth`.

A Nerd Font is recommended for icons (e.g. `dnf install jetbrains-mono-fonts`
gets you close; for full glyphs grab a font from nerdfonts.com and set it in
your terminal).

> Prefer system toolchain binaries? `sudo dnf install clang-tools-extra`
> provides clangd/clang-format, and you can remove them from
> `mason-tool-installer`'s list in `lua/plugins/lsp.lua`. Mason's versions work
> fine for all workflows below, though.

## Per-project setup — this is the important part

clangd is only as smart as the compilation database it can find. Each project
type needs a `compile_commands.json` at (or symlinked to) the project root.

### ns-3

ns-3's CMake build already exports a compilation database. After configuring:

```sh
./ns3 configure --enable-examples --enable-tests
ln -sf cmake-cache/compile_commands.json .
```

Open any file under `src/` and clangd resolves the whole module tree. ns-3
ships a `.clang-format`, which conform picks up automatically, so save-time
formatting matches upstream style.

### Linux kernel (modules, drivers, in-tree work)

Build first (the database is generated from actual build commands), then:

```sh
make defconfig          # or your config
make -j$(nproc)
./scripts/clang-tools/gen_compile_commands.py
```

or on recent kernels simply `make compile_commands.json`.

For **out-of-tree modules**, generate the database against the kernel build
dir: `gen_compile_commands.py -d /path/to/kernel/build` from your module dir
after building it.

This config auto-detects kernel trees (via `Kconfig` + `MAINTAINERS` at the
root) and switches those buffers to tabs, width 8, a 100-column guide, and
**disables format-on-save** so clang-format never rewrites code you'll run
through `checkpatch.pl`. `<leader>f` still formats manually if you want it —
the kernel's own `.clang-format` will be used.

Cross-compiling (e.g. `make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu-`)
works because clangd is launched with a `--query-driver` glob that matches
`*-gcc` cross compilers and asks them for their real include paths.

### Yocto / bitbake

- `.bb`, `.bbappend`, `.bbclass`, and layer `.conf` files get bitbake
  treesitter highlighting and 4-space indent out of the box.
- For C/C++ source of a recipe you're hacking on, use the devtool workflow:

  ```sh
  devtool modify <recipe>       # sources land in workspace/sources/<recipe>
  devtool build <recipe>
  ```

  For CMake/Meson recipes, `compile_commands.json` appears in the build tree
  (`tmp/work/.../build/`) — symlink it into the source dir. On Scarthgap and
  newer, `devtool ide-sdk <recipe>` can generate the clangd setup for you.
- The `--query-driver` glob already covers Yocto cross toolchains
  (`*-poky-linux-gcc` etc.), so sysroot headers resolve correctly.

### Buildroot

Same idea: for a package using CMake, add
`-DCMAKE_EXPORT_COMPILE_COMMANDS=ON` (Buildroot does this by default for
CMake packages in recent releases) and symlink the database from
`output/build/<pkg>-<version>/` into the source dir you're editing.
`*-buildroot-linux-*-gcc` is matched by the query-driver glob too.

### Python

basedpyright and ruff respect `pyproject.toml` / `ruff.toml` in the project
root. To pin a virtualenv, activate it before launching nvim, or drop a
`pyrightconfig.json` with `"venvPath"`/`"venv"` in the project. Adjust
strictness in `lua/plugins/lsp.lua` (`typeCheckingMode`).

## Key bindings (leader = Space)

### Moving around a project

| Keys | Action |
|---|---|
| `<leader>sf` | Fuzzy-find files |
| `<leader>sg` | Live grep the whole project |
| `<leader>sw` | Grep the word under the cursor |
| `<leader>ss` | Workspace symbol search (functions, classes, by name) |
| `<leader>sb` | Switch between open buffers |
| `<leader>s.` | Recent files |
| `<leader>sr` | Resume the last search where you left it |
| `<leader>sh` | Search Neovim help |
| `Shift-h` / `Shift-l` | Previous / next buffer |
| `<leader>bd` | Close buffer |
| `Ctrl-h/j/k/l` | Jump between split windows |
| `[q` / `]q` | Previous / next quickfix item (grep results, build errors) |

### Code intelligence (LSP)

| Keys | Action |
|---|---|
| `gd` | Go to definition (`Ctrl-o` jumps back) |
| `gD` | Go to declaration |
| `grr` / `gri` / `grt` | References / implementations / type definition |
| `grn` | Rename symbol project-wide |
| `gra` | Code action (auto-fixes, add include, etc.) |
| `K` | Hover docs |
| `<leader>ch` | Switch between source and header (clangd) |
| `<leader>ds` | Document symbols |
| `[d` / `]d` | Previous / next diagnostic |
| `<leader>e` | Expand diagnostic under cursor |
| `<leader>sd` | All diagnostics in a searchable list |
| `<leader>q` | Diagnostics to location list |
| `<leader>th` | Toggle inlay hints |

### Git (gitsigns)

| Keys | Action |
|---|---|
| `]h` / `[h` | Next / previous changed hunk |
| `<leader>hp` | Preview the hunk's diff |
| `<leader>hs` | Stage just that hunk |
| `<leader>hr` | Revert the hunk |
| `<leader>hb` | Blame current line (who / when / commit) |

Staging hunk-by-hunk from the editor is handy for kernel-style atomic commits.

### Editing

| Keys | Action |
|---|---|
| `<leader>f` | Format buffer or selection |
| `gcc` / `gc` (visual) | Toggle comment (built-in) |
| `J` / `K` (visual) | Drag selected lines down / up, re-indenting |
| `<` / `>` (visual) | Indent and keep selection for repeat presses |
| `Esc` | Also clears search highlighting |
| `:FormatDisable` / `:FormatDisable!` | Turn off format-on-save (global / buffer) |
| `:FormatEnable` | Turn it back on |

### Completion (blink.cmp, opens automatically)

| Keys | Action |
|---|---|
| `Ctrl-n` / `Ctrl-p` | Next / previous item |
| `Ctrl-y` | Accept selected item |
| `Ctrl-e` | Dismiss menu |
| `Ctrl-space` | Open menu manually / toggle docs window |
| `Tab` / `Shift-Tab` | Jump between snippet placeholders |

### Files (oil.nvim)

| Keys | Action |
|---|---|
| `-` | Open parent directory as an editable buffer (`-` again goes up) |
| `Enter` | Open file/dir under cursor |
| type a name, `:w` | Create file (`src/` creates a dir, `src/main.cpp` creates both) |
| edit a name, `:w` | Rename |
| `dd`, `:w` | Delete |
| `yy` + `p`, `:w` | Copy (works across two oil windows for cross-dir copies) |

Nothing touches disk until you `:w` and confirm; `u` undoes pending changes.

### Markdown

| Keys | Action |
|---|---|
| `<leader>tm` | Toggle in-buffer markdown rendering |
| `<leader>mp` | Live preview in browser (scroll-synced) |

Press `<Space>` and pause — which-key pops up everything under it, grouped.
Same works after `g`, `[`, and `]`.

## Structure

```
init.lua                  bootstrap + module loading
lua/options.lua           editor settings
lua/keymaps.lua           general keymaps
lua/autocmds.lua          kernel-tree detection, bitbake/dts/Kconfig styles
lua/plugins/lsp.lua       clangd, basedpyright, ruff, mason
lua/plugins/format.lua    conform.nvim + format toggles
lua/plugins/completion.lua blink.cmp
lua/plugins/treesitter.lua parsers
lua/plugins/editor.lua    telescope, oil, gitsigns, which-key, sleuth
lua/plugins/markdown.lua  in-buffer rendering + browser preview
lua/plugins/ui.lua        gruvbox-material + lualine
```
