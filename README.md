# Neovim Lua configuration

A Lua configuration for Neovim 0.11.3 or newer, with Gruvbox, native LSP support, completion, file and text search, a file explorer, Git change signs, and named sessions. Copilot is disabled and has no plugin or completion source.

## Setup

Clone this repository wherever you want, then run from its root:

```sh
bash vim_scripts/install_nvim.sh
bash vim_scripts/set_up_all.sh
nvim
```

The installer uses the official Linux release without sudo. Existing compatible Neovim installations are reused. The setup script links `nvim/` into `${XDG_CONFIG_HOME:-$HOME/.config}/nvim` and backs up an existing configuration first. Keep this checkout in place after linking it. Ensure `$HOME/.local/bin` is on your PATH.

First launch needs Git and network access to install [lazy.nvim](https://lazy.folke.io/installation) and plugins. Plugin revisions are recorded in `nvim/lazy-lock.json`; use `:Lazy restore` to restore those revisions and `:Lazy update` to update them deliberately. Use `,sv` to save an edited configuration file and reload options, keymaps, and autocommands. Restart Neovim for plugin changes or after installing language servers.

## Language support

The configuration enables these servers when their executables are installed:

| Files | Mason package | Neovim server |
| --- | --- | --- |
| C, C++, CUDA (`.cu`, `.cuh`) | `clangd` | `clangd` |
| Python | `pyright` | `pyright` |
| Lua | `lua-language-server` | `lua_ls` |
| Bazel `BUILD`, `WORKSPACE`, `.bazel`, `.bzl` | `starpls` | `starpls` |
| `.bazelrc` | `bazelrc-lsp` | `bazelrc_lsp` |
| `CMakeLists.txt`, `.cmake` | `neocmakelsp` | `neocmake` |
| Markdown | `marksman` | `marksman` |
| TOML | `taplo` | `taplo` |

Install packages with `:Mason` or, for the build and document servers:

```vim
:MasonInstall clangd starpls bazelrc-lsp neocmakelsp marksman taplo
```

Restart Neovim after installing servers. Servers already on PATH are also supported. Pyright requires Node.js and npm. clangd's Mason installer requires unzip. Marksman requires ICU on Linux; this setup also supports ICU libraries installed at `~/.local/opt/icu/lib` through an environment setting scoped to Marksman. Mason reports missing system dependencies with `:checkhealth mason`. No language server is downloaded automatically on startup.

Bazel's project-aware features require a working `bazel` command and a workspace containing `MODULE.bazel` or `WORKSPACE`. These language servers do not install Bazel, CMake, or the CUDA toolkit. For CUDA, provide the toolkit include paths and Clang-compatible compile flags through the compilation database or project `.clangd` configuration. clangd's [CUDA support has limitations](https://clangd.llvm.org/faq). A standalone `.cuh` file may need `-xcuda` in its project compile flags if clangd cannot infer its language from an including source file.

The configuration uses the current [native LSP configuration API](https://github.com/neovim/nvim-lspconfig). For C/C++, provide a `compile_commands.json` in the project or a parent directory for accurate flags. Formatting uses an attached server that supports it; Pyright does not provide formatting. Syntax highlighting and comments use Neovim's built-in support. Install ripgrep for live text search. Clipboard sharing requires a working clipboard provider; use `:checkhealth vim.provider` to inspect it.

## Keys

Space is the leader and comma is the local leader.

| Keys | Action |
| --- | --- |
| `jk`, `H`, `L` | Leave insert/visual mode, first nonblank character, end of line |
| `Ctrl+h/j/k/l` | Move between windows |
| `Ctrl+n`, `Space e` | Open file explorer (`q` closes it) |
| `Space ff/fg/fb/fh` | Find files, search text, buffers, help |
| `Space w/q/bd` | Save, quit window, delete buffer |
| `[b`, `]b` | Previous/next buffer |
| `,ev`, `,sv`, `,hl`, `,u`, `,c` | Edit keys, save/reload core configuration, clear search, uppercase word, toggle comment |
| `,"` in visual mode | Surround selected text with double quotes |
| `""`, `''`, `()`, `[]`, `<>`, `{}` in insert mode | Insert the pair and place the cursor inside |
| `gcc`, `gc` in visual mode | Built-in comment toggle |
| `sa`, `sd`, `sr` | Add, delete, replace surrounding delimiters (mini.surround) |
| `gd`, `gD`, `gr`, `gi`, `K`, `F2` | LSP definition, declaration, references, implementation, hover, rename |
| `Space lr/la/lf/ld` | Rename, code action, format, diagnostics |
| `[d`, `]d` | Previous/next diagnostic |
| `Tab`, `Shift+Tab`, `Enter`, `Ctrl+Space` | Select completion, accept selected item, trigger completion |
| `Space ss/sr/sd` | Save, restore, delete named session |
| `Space pm/pl` | Mason / Lazy plugin manager |

Completion uses [mini.completion](https://nvim-mini.org/mini.nvim/doc/mini-completion.html) with LSP suggestions and buffer-word fallback. Enter inserts a newline when nothing is selected. Session saving and restoring are manual. Arrow keys are disabled in normal, visual, select, operator-pending, and insert modes. Ctrl+[ is disabled in insert and visual modes; because it shares the Escape key code, use `jk` to leave those modes. In insert mode, `jk` preserves the cursor position, including just past the last character of a line (`virtualedit=onemore`). Terminal Escape remains available. Quote/bracket insertion uses the original two-character shortcuts instead of automatic pairing. Files are never reformatted automatically when opened or saved.

## Layout

`nvim/init.lua` loads `lua/config/options.lua`, `keymaps.lua`, `autocmds.lua`, and `lazy.lua`. Plugin specifications live in `lua/config/plugins.lua`. Four spaces remain the default indentation; Lua and common web configuration formats use two.

The old Vimscript configuration, vim-plug installer, and obsolete Clang/Python installation scripts have been replaced. To roll back, remove the configuration symlink and move the setup script's backup back to the original path. Repository history also retains the original files.

## Sync to an SSH host

`~/sync-nvim.sh` links to this repository's `sync-nvim.sh`. Run:

```sh
~/sync-nvim.sh horde
```

This copies the active config, installed plugins, language servers, Neovim, Node/npm, unzip, and ICU to a Linux x86_64 host with Git and rsync. Existing remote settings are backed up. Each upload shows progress; the first sync transfers roughly 1 GB before compression and may take several minutes. SSH uses keepalives, and transfers fail after 120 seconds without I/O. Errors identify the phase that failed. Interrupting with Ctrl+C stops the sync; an interrupted upload can leave a staging directory under the remote `~/.cache/codex-nvim-sync-*` path. Run again to start a new attempt.
