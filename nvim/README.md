# Neovim config

**Review: 2027-10.** Until then the plugin set is frozen. The only changes are fixes for a problem you've actually hit, each with a new entry here ([frame](docs/frame.md)).

Neovim 0.12+, plugins managed by the built-in `vim.pack`. The background is in [docs/](docs/):
- [frame.md](docs/frame.md): the problem.
- [research.md](docs/research.md): what was found out.
- [design.md](docs/design.md): the choices.
- [spec.md](docs/spec.md): the plan this config was built from.

**Status:**
- **core**: a must-have, or something already used before the rewrite.
- **experimental**: picked once from research (design §F). Keep or drop it at the review.

All plugins were added on 2026-10-20.

**Keymap cheat sheet:** [cheatsheet.md](cheatsheet.md), the most-used keys on one A4 page.

## Contents

- [Setup on a new machine](#setup-on-a-new-machine)
- [Updating plugins](#updating-plugins)
- [Files](#files)
- [Keys at a glance](#keys-at-a-glance)
- [Interface](#interface) · [Language tools](#language-tools) · [Formatting](#formatting) · [Completion](#completion)
- [Finding and navigating](#finding-and-navigating) · [Git](#git) · [Debugging](#debugging) · [Tests](#tests)
- [Databases](#databases) · [Editing](#editing) · [Markdown](#markdown)
- [Per-project files](#per-project-files)
- [Known gaps](#known-gaps)
- [Plugins and versions](#plugins-and-versions)

## Setup on a new machine

1. **Link the config.** From the dotfiles repo, run `./install.sh --tools nvim`. Anything already at `~/.config/nvim` is moved to `~/.config/nvim.bak-<timestamp>`.
2. **Install the tools Mason doesn't provide** (pacman / apt):
   - `git`, `rg` (ripgrep), `fzf` 0.36 or newer, a C compiler (`cc`), `curl`, `tar`
   - `npm`, `python3` (on Ubuntu: `python3-venv`), `go`
   - `tmux`
   - `psql` (pacman: `postgresql`, apt: `postgresql-client`), `sqlite3`
   - **WSL only:** `wl-clipboard`. Without it, yanks never reach the Windows clipboard.
3. **Rust toolchain:** `rustup component add rust-analyzer` (rustfmt and clippy come with rustup), plus `cargo install cargo-nextest --locked` for running tests.
4. **SurrealQL:**
   - The `surreal` CLI on `$PATH`, then `surreal install lsp`.
   - The formatter: `npm install -g @surrealdb/surql-fmt`.
5. **Start `nvim` and let it settle.** The first start:
   - installs every plugin in `nvim-pack-lock.json`;
   - then Mason installs its tools in the background;
   - and once Mason is done, the treesitter parsers are compiled.

   Expect "tree-sitter not found" errors on that first start; parsers install again as soon as Mason has finished.
6. **Run `:checkhealth config`.** Every tool the config needs should show OK. A missing or broken one shows as an ERROR, with the command that fixes it.

## Updating plugins

- **Update:** `:lua vim.pack.update()`. It shows what would change; `:w` applies it.
- **Revert:** `git checkout -- nvim-pack-lock.json`, then `:lua vim.pack.update(nil, { target = "lockfile" })`.
- **Reminder:** after 30 days without an update, the statusline shows `plugins updated N days ago :lua vim.pack.update()`.
- **Mason tools:** `:MasonToolsUpdate` updates them.
- **Neovim 0.13:** revisit the reminder then. 0.13 can report pending updates (design D8).

## Files

| Path | What's there |
|---|---|
| `init.lua` | Load order: options → keymaps → filetypes → pack hooks → modules |
| `lua/config/options.lua`, `keymaps.lua` | Editor options and core keymaps |
| `lua/config/filetypes.lua` | `*.surql` → `surql` |
| `lua/config/pack.lua` | Plugin build steps (`PackChanged`), last-update time |
| `lua/config/health.lua` | `:checkhealth config`; modules list their tools with `declare_tool()` |
| `lua/config/<capability>.lua` | One module per section below |
| `lua/config/statusline.lua` | The statusline |
| `lsp/surql.lua` | SurrealQL server config (not in lspconfig) |
| `after/lsp/lua_ls.lua` | Override of lspconfig's `lua_ls` |
| `after/ftplugin/markdown.lua` | Markdown editing settings |
| `spell/en.utf-8.add` | Your spelling dictionary (`zg`); the compiled `.spl` is rebuilt on startup and not committed |
| `nvim-pack-lock.json` | Exact plugin revisions; commit it |

## Keys at a glance

Leader is `Space`. Press it and wait: which-key lists every group.

| Group | Keys |
|---|---|
| `<leader>f` find | `ff` files, `fg` grep, `fr` recent, `fb` buffers, `fk` keymaps, `fh` help, `fd` / `fD` diagnostics (file / open files), `ft` TODOs |
| `<leader>e` explorer | `ee` at cwd, `ef` at current file |
| `<leader>g` git | `gs` stage, `gr` reset, `gS` / `gR` stage / reset buffer, `gu` undo stage, `gp` preview, `gb` / `gB` blame, `gd` / `gD` diff, `gc` codediff |
| `<leader>c` code | `cf` format |
| `<leader>d` debug | `db` breakpoint, `dB` conditional breakpoint, `dc` start/continue, `dn` / `di` / `do` step over / into / out, `dt` stop, `dv` view |
| `<leader>t` test | `tn` nearest, `tf` file, `ts` all, `tl` last |
| `<leader>q` database | `qq` toggle UI |
| `<leader>a` AI | `ab` add file, `as` send selection, `aa` / `ad` accept / reject diff |
| `<leader>o` toggles | `of` format on save, `oh` inlay hints |
| `<leader>w` windows | `w/` split vertically, `w-` split horizontally, `wx` close |
| On its own | `<leader>u` undo tree, `<leader>m` arrow |

**Without leader:**
- **LSP:** `gd`, `gR`, `gD`, built-in `gr*`, `K`, `<C-w>d`, `]d` / `[d`.
- **TODOs:** `]t` / `[t`.
- **Surround:** `sa`, `ds`, `sr`, `sf`, `sF`, `sh`, `sn`.
- **tmux / splits:** `<C-h/j/k/l>`.

**Core keymaps** (`lua/config/keymaps.lua`):

| Mode | Key | Action |
|---|---|---|
| Visual | `p` | Paste over the selection without losing what you yanked |
| Normal | `<C-c>` | Clear search highlighting |
| Visual | `J` / `K` | Move selected lines down / up |
| Normal | `<C-d>` / `<C-u>` | Half-page scroll, cursor centered |
| Normal | `n` / `N` | Next / previous match, centered and unfolded |
| Visual | `<` / `>` | Indent and keep the selection |
| Normal | `<leader>w/` / `<leader>w-` | Split window vertically / horizontally |
| Normal | `<leader>wx` | Close window |

## Interface

`lua/config/ui.lua`, `lua/config/statusline.lua`, `lua/config/greeter.lua`.

| Plugin | Status | Why | Keys |
|---|---|---|---|
| ui2 (built in) | core | Messages and command line without "Press ENTER", with `cmdheight=0` | — |
| silkcircuit-nvim | core | The colorscheme, variant **vibrant**. Set in the config, because silkcircuit's own saved choice lives outside the repo | `:SilkCircuit {variant}` to try another for this session |
| mini.icons (mini.nvim) | core | File icons. Also stands in for nvim-web-devicons | — |
| which-key.nvim | core | Lists the keys that follow a prefix, so forgotten keymaps can be found | press `<leader>` and wait |
| mini.starter (mini.nvim) | experimental | Greeter when Neovim starts without a file: logo, recent files in the current directory, common actions, plugin count | type the start of an item in lowercase (`fi` → Files), or `j` / `k` and `<CR>` |

**Diff colours:** silkcircuit's diff backgrounds are full-strength neon, which made syntax colours unreadable. `ui.lua` replaces them with dark tints of the palette, used in codediff and native diff mode (`<leader>gd`):
- Added lines: cyan at 8%; added words: cyan at 16%.
- Deleted lines: magenta at 12%; deleted words: magenta at 22%.
- Changed lines: blue at 10%; changed words: blue at 18%.

Every syntax colour keeps a contrast of 4.1 or more on them.

**Statusline:** Neovim's default (file, diagnostics counts, LSP progress, position), plus:
- the git branch (from gitsigns);
- `recording @x` while recording a macro (`cmdheight=0` hides Neovim's own message);
- the plugin-update reminder.

## Language tools

`lua/config/mason.lua`, `treesitter.lua`, `lsp.lua`, `lsp/`, `after/lsp/`.

| Plugin | Status | Why |
|---|---|---|
| mason.nvim | core | Installs language servers, formatters and debug adapters on Arch and WSL alike |
| mason-tool-installer.nvim | core | Installs the list in `mason.lua` on startup, so a fresh clone gets everything |
| mason-lspconfig.nvim | core | Only translates lspconfig server names to Mason package names. Its `setup()` is never called, because that would enable every installed server |
| nvim-lspconfig | core | Server configs (`lsp/*.lua`) for the built-in `vim.lsp`. `lsp.lua` enables an explicit list |
| rustaceanvim | core | Rust: starts rust-analyzer (from rustup, not Mason) with clippy checks, plus Rust debugging |
| nvim-treesitter (`main`) | core | Installs parsers; highlighting is switched on for every filetype with a parser |

**Servers** (all from Mason unless noted):

| Language | Servers |
|---|---|
| TS/TSX | `tsc` (TypeScript 7) |
| Web | `tailwindcss`, `cssls`, `html`, `emmet_language_server` |
| Linting | `eslint`, `biome` (each only where its config file exists) |
| Go | `gopls` |
| Python | `basedpyright`, `ruff` |
| GraphQL | `graphql` |
| SQL | `postgres_lsp` (only with `postgres-language-server.jsonc`), `sqruff` |
| TOML / YAML / Markdown | `taplo`, `yamlls`, `marksman` |
| Lua | `lua_ls` (knows Neovim's API) |
| SurrealQL | `surql` (`surreal lsp stdio`, not from Mason) |
| Rust | rust-analyzer (rustup, through rustaceanvim) |

**Parsers:** bash, css, go, graphql, html, javascript, json, lua, markdown, markdown_inline, python, rust, sql, surrealql (pinned commit), toml, tsx, typescript, yaml.

**Diagnostics:**
- Signs in the gutter only, with no text in the buffer. A line shows its worst diagnostic.
- `<C-w>d` shows the messages for the line; `]d` / `[d` jump between diagnostics.
- Code is still underlined (Neovim's default).

**Keys:**
- From this config: `gd` definition and `gR` references (both through fzf-lua; a single result jumps straight there), `gD` declaration.
- Built in: `grr` references, `gri` implementation, `grn` rename, `gra` code action, `grt` type definition, `grx` run code lens, `gO` symbols, `K` hover, insert `<C-s>` signature help.
- Toggle: `<leader>oh` inlay hints.

## Formatting

`lua/config/formatting.lua`.

| Plugin | Status | Why | Keys |
|---|---|---|---|
| conform.nvim | core | Formats on save, falling back to the language server where no formatter is set | `<leader>cf` format now, `<leader>of` toggle format on save |

| Filetype | Formatter |
|---|---|
| JS/TS/JSX/TSX/CSS | biome where the project has a biome config, otherwise prettierd |
| HTML, Markdown, YAML, GraphQL | prettierd |
| Rust | rustfmt (rustup) |
| Go | goimports, then gofumpt |
| Python | ruff format |
| Lua | stylua |
| SQL | sqruff |
| TOML | taplo |
| SurrealQL | surqlfmt (npm). A file that doesn't parse is left unchanged |

## Completion

`lua/config/completion.lua`.

| Plugin | Status | Why | Keys |
|---|---|---|---|
| blink.cmp (`1.*`) | core | Completion from language servers, file paths and buffer words. In SQL files, also table and column names from the connected database. No snippets | `<C-y>` accept, `<C-n>` / `<C-p>` move, `<C-e>` close, `<C-space>` open |

blink downloads its prebuilt matcher for its release tag. If that fails, it falls back to a Lua matcher.

## Finding and navigating

`lua/config/navigation.lua`.

| Plugin | Status | Why | Keys |
|---|---|---|---|
| fzf-lua | core | Fuzzy finder, and the menus Neovim shows for choices (`vim.ui.select`) | the `<leader>f` group (see [Keys](#keys-at-a-glance)), `gd`, `gR` |
| mini.files (mini.nvim) | core | File explorer | `<leader>ee`, `<leader>ef`; inside: `<CR>` open, `-` up, `L` open a file and close the explorer, `H` up and close the columns to the right |
| arrow.nvim | experimental | A few bookmarked files per project, labels shown on screen | `<leader>m` (not arrow's default `;`, which repeats `f`/`t`) |
| vim-tmux-navigator | core | Same keys move between Neovim splits and tmux panes | `<C-h/j/k/l>` |

## Git

`lua/config/git.lua`. Committing and pushing stay in tmux.

| Plugin | Status | Why | Keys |
|---|---|---|---|
| gitsigns.nvim | experimental | Change markers, staging single changes from the buffer, blame | see below |
| codediff.nvim | experimental | Side-by-side review of all changes, revisions, PRs and AI-agent edits. Downloads its diff library on first use | `<leader>gc` (`:CodeDiff`; also `:CodeDiff main`, `:CodeDiff pr 123`, `:CodeDiff history`) |

**gitsigns keys** (in any buffer under git):

| Key | Action |
|---|---|
| `<leader>gs` | Stage change (on a staged change: unstage). In visual mode: the selected lines |
| `<leader>gr` | Reset change. In visual mode: the selected lines |
| `<leader>gS` / `gR` | Stage / reset the whole buffer |
| `<leader>gu` | Undo last stage |
| `<leader>gp` | Preview change |
| `<leader>gb` | Blame line |
| `<leader>gB` | Toggle line blame |
| `<leader>gd` / `gD` | Diff against index / last commit |

**Inside codediff:**
- `<leader>gs` / `gu` / `gr` stage / unstage / discard a change (the same keys as gitsigns).
- `<leader>ge` focuses its file list; `-` stages the file.
- `]c` / `[c` and `]f` / `[f` move between changes and files.
- `q` closes; `g?` shows all keys.

## Debugging

`lua/config/debug.lua`. The debug adapters come from Mason.

| Plugin | Status | Why |
|---|---|---|
| nvim-dap | experimental | Debugger core (follows its branch: nvim-dap-view needs newer code than its 2025-03 release) |
| nvim-dap-view | experimental | Debug UI. Opens when a session starts and closes when it ends; `g?` inside shows its keys |
| nvim-dap-go | experimental | Go setups (delve) |
| nvim-dap-python | experimental | Python setups (debugpy) |

**What each language debugs:**

| Language | Ways to start |
|---|---|
| Rust | `:RustLsp debug` debugs the binary or test under the cursor (codelldb). `<leader>dc` also offers rust-analyzer's targets |
| JS/TS | **Node: run current file** (Node runs `.ts` directly), **Node: attach to process**, **Chrome: open app** (asks for the URL, default `http://localhost:5173`) |
| Go | dap-go's "Debug", "Debug test" and others |
| Python | dap-python's "file", "file:args" and others |

**Keys:** `<leader>db` breakpoint, `dB` conditional breakpoint, `dc` start/continue, `dn` / `di` / `do` step over / into / out, `dt` stop, `dv` toggle the view.

## Tests

`lua/config/test.lua`. Tests run in a tmux pane, not inside Neovim, so Neovim must run inside tmux.

| Plugin | Status | Why | Keys |
|---|---|---|---|
| vim-test | experimental | Builds the command for the test under the cursor | `<leader>tn` nearest, `tf` file, `ts` all, `tl` last |
| vimux | experimental | Runs it in a tmux pane below and reuses that pane | — |

- **Rust runs through nextest** (`cargo nextest run`), here and in rustaceanvim's own test commands.
- **Commands run from the project the file belongs to**, so monorepos work from the repo root:
  - Rust: the Cargo workspace root, e.g. `backend/`.
  - JS/TS: the nearest `package.json`.
  - Go: `go.mod`.
  - Python: `pyproject.toml` / `setup.cfg` / `pytest.ini` / `tox.ini`.
- **pytest** is only picked when the project has a pytest config, imports `pytest`, or has `pytest` on `$PATH`.

## Databases

`lua/config/database.lua`. This replaces DBeaver.

| Plugin | Status | Why | Keys |
|---|---|---|---|
| vim-dadbod | experimental | Runs queries (Postgres via `psql`, SQLite via `sqlite3`) | — |
| vim-dadbod-ui | experimental | Connections, schema browser, saved queries | `<leader>qq` toggle; `o` open, `?` help |
| vim-dadbod-completion | experimental | Table and column names in completion | — |
| vim-dotenv | experimental | Reads the nearest `.env` above the current file | — |

**Connections:**
- They come from environment variables, never from this repo. `DB_UI_<NAME>=<url>`, e.g. in the project's `.env`, becomes the connection `<name>`; `$DBUI_URL` also works. Examples: `postgres://user:pw@localhost:5432/db`, `sqlite:/abs/path/app.db`.
- Don't add connections with `:DBUIAddConnection`. It stores them in `~/.local/share/db_ui`.

## Editing

`lua/config/editing.lua`.

| Plugin | Status | Why | Keys |
|---|---|---|---|
| mini.pairs (mini.nvim) | core | Closes brackets and quotes | — |
| todo-comments.nvim (+ plenary.nvim) | core | Highlights TODO/FIXME/…, jumps, picker | `]t` / `[t`, `<leader>ft` |
| mini.ai (mini.nvim) | experimental | Text objects that also find the next or last one: `cin(` changes inside the next `()` | `a`/`i` objects; `an`/`in`, `al`/`il` next/last; `g[` / `g]` |
| mini.surround (mini.nvim) | experimental | Add, delete and replace surroundings | `sa` add, `ds` delete, `sr` replace, `sf` / `sF` find, `sh` highlight, `sn` lines (e.g. `saiw"`, `ds"`) |
| nvim-ts-autotag | experimental | Closes and renames HTML/JSX tags | — |
| `:Undotree` (built in) | experimental | Browse the undo history | `<leader>u` |
| crates.nvim | experimental | Latest crate versions next to `Cargo.toml` dependencies | — |
| claudecode.nvim | experimental | Lets Claude Code in a tmux pane see and edit what's open here. With Neovim running, start Claude with `claude --ide`, or run `/ide` inside Claude | `<leader>ab` add file, `<leader>as` send selection, `<leader>aa` / `ad` accept / reject Claude's diff |

## Markdown

`lua/config/markdown.lua`, `after/ftplugin/markdown.lua`.

| Plugin | Status | Why |
|---|---|---|
| render-markdown.nvim | experimental | Renders headings, lists, tables and code blocks in the buffer. The line under the cursor shows raw Markdown |

**Settings for Markdown files:**
- Spell checking on (`zg` adds a word to `spell/en.utf-8.add`).
- Long lines wrap on screen, and real line breaks are inserted at 80 columns.
- Enter or `o` on a `-`, `*`, `+` or `>` line starts the next item.

## Per-project files

| File | Needed for |
|---|---|
| `postgres-language-server.jsonc` | postgres_lsp attaches only where this exists (Postgres projects) |
| `.sqruff` with `[sqruff]` / `dialect = postgres` or `dialect = sqlite` | SQL linting and formatting in the right dialect |
| `.env` with `DB_UI_<NAME>=<url>` | Database connections. Keep it out of git |
| `biome.json` | Use biome instead of prettierd for formatting |
| `.editorconfig` | Indentation per project (built into Neovim) |
| `.git` | Project root for the SurrealQL and sqruff servers |

## Known gaps

- **Chrome debugging** is configured but untested: Chrome isn't installed on the Arch machine, and it's unknown whether it works from WSL.
- **Debugging Rust tests** doesn't go through nextest. The test binary runs directly, so settings from `.config/nextest.toml` (environment variables, setup scripts) don't apply while debugging.
- **mini.ai replaces Neovim's built-in visual `an` / `in`** (select by syntax node) with "around/inside next".
- **The WSL clipboard** (`wl-clipboard`) is untested; it needs the work laptop.

## Plugins and versions

Versions follow a release range where the plugin publishes current releases. Otherwise they follow the default branch, and the lockfile pins the exact commit.

| Plugin | Version | Module |
|---|---|---|
| silkcircuit-nvim | `2.*` | ui |
| mini.nvim | `0.18.*` (raise by hand) | ui |
| which-key.nvim | `3.*` | ui |
| mason.nvim | `2.*` | mason |
| mason-lspconfig.nvim | `2.*` | mason |
| mason-tool-installer.nvim | branch | mason |
| nvim-treesitter | `main` | treesitter |
| nvim-lspconfig | `2.*` | lsp |
| rustaceanvim | `9.*` | lsp |
| blink.cmp | `1.*` | completion |
| conform.nvim | `9.*` | formatting |
| fzf-lua | branch | navigation |
| arrow.nvim | branch | navigation |
| vim-tmux-navigator | branch | navigation |
| gitsigns.nvim | `2.*` | git |
| codediff.nvim | `4.*` | git |
| nvim-dap | branch | debug |
| nvim-dap-view | `1.*` | debug |
| nvim-dap-go | branch | debug |
| nvim-dap-python | branch | debug |
| vim-test | `3.*` | test |
| vimux | `1.*` | test |
| vim-dadbod | branch | database |
| vim-dadbod-ui | branch | database |
| vim-dadbod-completion | branch | database |
| vim-dotenv | branch | database |
| nvim-ts-autotag | branch | editing |
| plenary.nvim | branch | editing |
| todo-comments.nvim | `1.*` | editing |
| crates.nvim | `0.*` | editing |
| claudecode.nvim | branch | editing |
| render-markdown.nvim | `8.*` | markdown |
