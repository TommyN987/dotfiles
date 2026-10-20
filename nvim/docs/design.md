# Neovim revamp — design

Decided on 2026-10-20. This builds on [frame.md](frame.md) and [research.md](research.md). It records what was chosen and why; implementation details go to the spec.

Decision IDs (D1–D26) match the design discussion. Rejected options are listed so the reasoning can be traced at the year-end review.

## A. Foundation

### D1 — Linking: `install.sh` with a tool → target map
- The script links whole folders with `ln -sfn` and backs up anything already in place first.
  - `nvim/` → `~/.config/nvim`
  - `tmux/` → `~/.config/tmux`
  - `alacritty/` → `~/.config/alacritty`
  - `.zshrc`, `.p10k.zsh` → `~`
- `./install.sh` installs everything. `./install.sh --tools nvim tmux …` installs only the listed tools.
- **Why:**
  - It matches the repo's current layout, so no files move.
  - Linking the whole folder means `nvim-pack-lock.json` is written into the repo.
- **Why the backup is required:** `~/.zshrc` on this machine is already newer than the repo's copy (5357 vs 5241 bytes).
- **Rejected:**
  - stow: every tool would move into `<tool>/.config/<tool>/`, and it only links the whole folder if the target doesn't exist yet.
  - chezmoi: it copies files, so the lockfile would be written outside the repo.
  - Making `~/.config` itself the repo: all or nothing, and it mixes in other apps' configs.

### D2 — Old config: tag `nvim-lazy-final`, then replace it
- **Why:** the old config can be found again by a name, and the repo stays uncluttered.
- **Rejected:**
  - Relying on git history alone: you'd have to dig for a commit hash.
  - A `nvim-legacy/` folder: clutter.
  - Keeping it runnable with `NVIM_APPNAME`: too tempting to fall back to.

### D3 — Prerequisites outside Mason: a README list plus a custom `:checkhealth config`
- **What's covered:** rg, fzf (≥ 0.36), a C compiler, curl, tar, node, rustup, go, python, git.
  - The health check names each missing tool, says why it's needed, and gives the install command.
- **Why:** when something is missing, you see the problem, the cause and the fix in one place. `install.sh` stays a linker.
- **Rejected:**
  - Installing packages from `install.sh`: two package managers to handle.
  - Doing nothing and letting the errors surface.

### D4 — Tool sources: Mason, except the Rust toolchain
- rust-analyzer, rustfmt and clippy come from rustup. Everything else comes from Mason.
- **Why:** a Mason-installed rust-analyzer can drift from the Rust toolchain's version, per rustaceanvim.
- This amends the frame's Mason constraint.
- **Rejected:**
  - Mason for everything: the version drift above.
  - System packages: versions differ between Arch and Ubuntu.
  - Project-local tools only: nothing would work outside a project.

### D5 — Mason tools: one list in one file
- A fresh clone installs everything that list names.
- **Open for spec:** use the mason-tool-installer plugin, or a short loop of our own over Mason's API? It depends on whether mason-tool-installer is still maintained, which wasn't researched.

## B. Structure

### D6 — Layout: one file per capability
- The files are `editor`, `ui`, `lsp`, `completion`, `find`, `git`, `debug`, `test`, `lang`, `db` (final names in spec).
- Server configs go in `lsp/<server>.lua`, and per-language settings in `after/ftplugin/`.
- Whether a plugin is core or experimental is recorded in the README, not in the folder structure.
- **Why:** a README section, a file and a which-key group all map one-to-one, so there's a single mental map.
- **Rejected:**
  - One file per plugin: it doesn't line up with the README sections.
  - One list of every plugin: each plugin would live in two places.
  - Splitting files by status: related plugins would end up in different files.

### D7 — Versions: a version range where the plugin publishes releases, otherwise the default branch
- Examples: blink `1.*`, nvim-dap-view `1.*`.
- **Why:** blink's main branch is v2 and makes breaking changes.
- **Rejected:**
  - The default branch for everything: blink v2 would come in.
  - Exact tags only: every update becomes a manual chore.
  - Bleeding edge everywhere.

### D8 — Update reminder: "plugins updated N days ago" in the statusline after 30 days
- The timestamp is saved to `stdpath('state')` whenever an update runs. No network, no plugin.
- Revisit in Neovim 0.13, which adds a way to check for pending updates.
- **Rejected:**
  - No reminder at all.
  - Checking for updates in the background: unclear which git refs to compare.
  - tiny-packupdate: too new.
  - No updates during the freeze year.

## C. Core stack

### D9 — LSP: built-in LSP + nvim-lspconfig (configs only) + an explicit `vim.lsp.enable{...}` list
- **Why:** the config says exactly which servers run, and leaving rust-analyzer out for rustaceanvim is easy.
- **Rejected:**
  - `automatic_enable`: what runs would depend on what happens to be installed.
  - Copying configs by hand without lspconfig.
  - The deprecated `require('lspconfig').setup`.

### D10 — Language servers

| Language | Choice |
|---|---|
| Rust | rustaceanvim, with rust-analyzer from rustup |
| TS/TSX | `tsc` (TypeScript 7), because the projects are on TS 7 |
| Web | tailwindcss, cssls, html, emmet_language_server |
| Linting | eslint and biome; each attaches only where its config exists |
| Go | gopls |
| Python | basedpyright + ruff |
| GraphQL | graphql |
| SQL | see D25 |
| TOML / YAML / Markdown | taplo, yamlls, marksman |
| Lua | lua_ls, set up by hand to know Neovim's API (no lazydev) |
| SurrealQL | hand-written `surreal-lsp` config + official tree-sitter parser + filetype `surql` |

- **Known gap:** whether TS 7's `tsc` server matches tsserver's features (e.g. refactors) is unverified. Switching to vtsls would be a named-problem fix.
- **Rejected:**
  - vtsls, ts_ls, typescript-tools: the projects are on TS 7, and typescript-tools is stale.
  - pyright, ty, pyrefly: their maturity is unknown.
  - tombi, markdown_oxide, emmylua_ls: their maturity is unknown.

### D11 — Completion: blink.cmp `1.*`
- **Why:** completion is the most-used feature, and Neovim's built-in `'autocomplete'` is new in 0.12, so it's the most likely to cause a problem mid-year.
- It falls back to its Lua matcher if the prebuilt binary fails.
- **Rejected:**
  - Built-in completion: newest, with fewer sources.
  - nvim-cmp: needs one plugin per source.
  - No completion popup at all.

### D12 — Snippets: language-server snippets only
- blink gets no snippet source.
- **Why:** snippets aren't used.
- **Rejected:** friendly-snippets, a snippets file of your own, LuaSnip.

### D13 — Treesitter: nvim-treesitter `main`
- It installs a listed set of parsers, and highlighting is switched on per filetype with `vim.treesitter.start()`.
- Text objects come from mini.ai (F) instead of the textobjects plugin.
- **Rejected:**
  - Built-in parsers only: just 7 languages.
  - No treesitter.

### D14 — Fuzzy finder: fzf-lua
- It needs the `fzf` program, version 0.36 or newer.
  - Arch: pacman.
  - Ubuntu 24.04: apt has 0.44 (to be confirmed by the health check).
- silkcircuit has a theme for it.
- **Why:** your choice, over the recommended telescope.
- **Rejected:**
  - telescope: it was the recommendation, kept for familiarity.
  - mini.pick: a new interface, with LSP pickers that come from mini.extra.
  - snacks.picker: snacks.nvim has been quiet since May 2026.
  - Built-in `:find` + `:grep`: no fuzzy LSP references.

### D15 — Formatting: conform.nvim, formatting on save, with a toggle
- **Why:**
  - prettier, rustfmt, gofumpt, stylua and surqlfmt don't work through a language server.
  - The toggle covers repos with no formatter config.
- **Rejected:**
  - Built-in LSP formatting on save: those formatters aren't covered.
  - Formatting by keypress only.
  - Formatting outside Neovim.

### D16 — Linting: language servers only
- That means eslint, ruff, clippy through rust-analyzer, gopls, yamlls and sqruff.
- **Why:** every tier 1 and tier 2 language already has a language server that lints.
- Adding nvim-lint (e.g. for markdownlint) would be a named-problem fix.
- **Rejected:**
  - nvim-lint, alone or alongside language servers.
  - Linting only in CI.

## D. Keymaps and finding them again

### D17 — LSP keymaps: keep `gd` / `gR` plus the built-in `gr*` keymaps
- **Open for spec:** wiring them to fzf-lua.
- **Rejected:**
  - Everything under a `<leader>l` group.
  - Built-ins only, relearning `gd` and `gR`.
  - No keymaps.

### D18 — Forgotten keymaps: which-key + fzf-lua's keymap search
- **Rule:** every keymap gets a description. `n` and `N` currently lack one.
- **Why:** which-key shows every keymap that has a description, with no setup.
- **Rejected:**
  - mini.clue: one missed trigger key leaves those keymaps hidden.
  - A cheat sheet or the README alone.

### D19 — Leader groups by first letter, matching D6
- `<leader>f` find, `g` git, `d` debug, `t` test, `c` code, `u` toggles, plus a database group (letter in spec).
- **Rejected:**
  - One flat list.
  - No leader key at all.

## E. Interface

### D20 — Statusline: the built-in default plus our own pieces
- The added pieces are the git branch, macro recording (needed because `cmdheight=0`) and the update reminder (D8).
- **Why:** the default already shows diagnostics and LSP progress, and our own code doesn't change when plugins update.
- Switching to lualine is an easy fallback if this looks too plain.
- **Rejected:**
  - lualine and mini.statusline: plugins for something the default mostly covers.
  - No statusline: macro recording would have nowhere to show.

### D21 — Messages and command line: ui2 (already enabled)
- It's experimental, so it may change when Neovim updates.
- **Rejected:**
  - noice: a heavy plugin.
  - `cmdheight=1` with neither.
  - `cmdheight=0` without ui2.

### D22 — File explorer: mini.files
- **Why:** it was used in the old setup.
- **Rejected:** oil, neo-tree, netrw.

### D23 — Icons: mini.icons, standing in for devicons where a plugin expects them
- A Nerd Font is set up on both machines.
- **Rejected:**
  - nvim-web-devicons: a separate plugin, while mini.nvim is already installed.
  - No icons.

## F. Plugin set

Plugins that work without any keys can't be forgotten, so they're the safest picks.

### Core (already used, kept)
- vim-tmux-navigator, mini.files, fzf-lua (replacing telescope), mini.pairs (replacing autopairs), todo-comments.

### Experimental batch
| Plugin | Purpose |
|---|---|
| gitsigns | Change markers, staging single chunks, blame |
| codediff.nvim | Side-by-side diffs across files, review of PRs and AI-agent changes (downloads a prebuilt binary) |
| nvim-dap + nvim-dap-view | Debugging; adapters from Mason (codelldb via rustaceanvim, js-debug-adapter, delve, debugpy) |
| vim-test + vimux | Runs the nearest test in a tmux pane |
| arrow.nvim | Quick file bookmarks, with labels shown on screen |
| mini.ai, mini.surround | Text objects and surround (mini.pairs is in core) |
| built-in `:Undotree` | Undo history (no plugin, just a keymap) |
| crates.nvim | Version hints in `Cargo.toml` |
| nvim-ts-autotag | Closes and renames tags in TSX/HTML |
| claudecode.nvim | Links Neovim to Claude Code running in a tmux pane |
| vim-dadbod + dadbod-ui + dadbod-completion | Postgres/SQLite database UI, replacing DBeaver (a named problem, see D26) |
| render-markdown.nvim | Renders Markdown inside the editor (added in the spec, 2026-10-20; see spec.md §12) |

### Optional — not chosen
- **neogit:** overlaps with lazygit in a pane.
- **package-info.nvim:** not picked.
- **flash.nvim:** a new movement habit to learn.
- **harpoon2:** its list stays hidden; arrow was picked instead.

### Rejected
| Plugin | Reason |
|---|---|
| mini.diff | gitsigns also does blame |
| fugitive | Lots of commands to remember |
| diffview-plus | codediff covers it; the fork is young |
| snacks lazygit / snacks.terminal | Same as a tmux pane; snacks has been quiet |
| nvim-dap-ui | Heavier than dap-view |
| neotest | Adapters break; vim-test keeps the tmux workflow |
| overseer | Little gain over tmux |
| toggleterm | Stale |
| built-in marks | No visible list |
| trouble | The picker covers it |
| colorizer plugins | Neovim's built-in LSP document colors cover it |
| Copilot / codecompanion / avante | Claude Code is the AI tool |
| kulala | Core went closed-source and needs a license |
| rest.nvim | Stale |
| Session plugins | One tmux window per project, plus `:restart` |
| nvim-dbee | Stale, ships a Go binary |

### D25 — SQL: postgres_lsp in Postgres projects + sqruff everywhere
- sqruff handles linting and formatting, with the dialect set per project.
- **Why:** Postgres has a language server of its own; SQLite has none among the options.
- **Rejected:**
  - sqls: maintenance unknown, and it needs a live database connection.
  - sqruff only: no completion or hover.
  - No SQL server.

### D26 — Queries: vim-dadbod + dadbod-ui + dadbod-completion
- **Why:** DBeaver is a named annoyance, and you want the database UI inside Neovim.
- **Rejected:**
  - psql or sqlite3 in a tmux pane: you're not comfortable with plain psql.
  - nvim-dbee: stale.
  - Piping the buffer to the command line: results are plain text.

## G. Documentation

### D24 — README: one section per capability
- Each plugin gets: why it's there, its keymaps, its status (core or experimental), and the date it was added.
- The top says **Review: 2027-10**.
- **Rejected:**
  - One big table.
  - Generated from code comments.
  - No README.

## Fixes the spec must include
- Turn on `undofile` and drop the custom `undodir`, using Neovim's default folder.
- Fix the `vim.expandtab`, `vim.autoindent` and `vim.smartindent` lines, which set nothing.
- Clipboard on WSL: `unnamedplus` needs win32yank.exe or WSLg's wl-clipboard.
- Register the `PackChanged` build hooks (treesitter `:TSUpdate`, blink binary, codediff library) before the first `vim.pack.add`.
- Add a `vim.filetype.add` entry so `.surql` files are recognized.
- Give every keymap a description.

## Open for spec

All of these were settled in [spec.md](spec.md) on 2026-10-20.
- **D5:** mason-tool-installer or our own loop.
- **D17:** the keymap list, including `gd` / `gR` through fzf-lua.
- **D19:** the database group's letter.
- **Database passwords:** where connection URLs live (environment variables, a gitignored file per project, or a file outside the repo), so they never reach the dotfiles repo.
- **blink and dadbod-completion:** whether blink reads it directly or needs a compatibility layer.
- **postgres_lsp:** how it decides which projects to attach to, so it stays out of SQLite projects.
- **SurrealQL:** which branch of the parser to follow. If dadbod doesn't support SurrealDB, queries go through the `surreal` command line.
- **blink binary:** where it's stored under vim.pack.
