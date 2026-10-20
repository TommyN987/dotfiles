# Neovim revamp — spec

Agreed on 2026-10-20. It builds on [frame.md](frame.md), [research.md](research.md) and [design.md](design.md).

**Reading this file:**
- Each item is marked MUST, SHOULD, MAY or WONT.
- **Done:** is the check that shows an item is finished.
- **How sure:** **C** confirmed · **P** probable · **U** uncertain · **?** unknown.
- Facts checked on 2026-10-20 against copies of each plugin's repo and the Neovim 0.12.5 docs are marked (C).

## 1. Dotfiles bootstrap — MUST

- **1.1** Tag the current repo state `nvim-lazy-final` — MUST.
  - Done: `git -C ~/dotfiles tag -l nvim-lazy-final` points at a commit that contains `nvim/lazy-lock.json`.
- **1.2** Replace `dotfiles/nvim/` with the new config, `docs/` included — MUST.
  - Done: `dotfiles/nvim/init.lua` is the new one, `lazy-lock.json` is gone, and `docs/frame.md` exists.
- **1.3** `install.sh` — MUST.
  - **1.3.1** Tool map — MUST.
    - `nvim`, `tmux`, `alacritty` → `~/.config/<tool>`.
    - `zsh` → `~/.zshrc` and `~/.p10k.zsh`.
    - Each link points at the whole folder.
    - Done: each mapped tool's target resolves to the repo path.
  - **1.3.2** `--tools a b …` links only the named tools — MUST.
    - With no flag, it links all of them.
    - An unknown name prints the valid names and exits with code 1.
    - Done: `./install.sh --tools foo` exits 1 and lists the valid tools.
  - **1.3.3** Anything real at the target is moved to `<target>.bak-YYYYmmdd-HHMMSS` first — MUST.
    - Done: the existing `~/.zshrc` survives as a `.bak-*` file with the same contents.
  - **1.3.4** Running it twice is safe — MUST.
    - A second run changes nothing and reports "already linked".
    - Done: no new `.bak-*` files, and the link targets are unchanged.
  - **1.3.5** A symlink that points somewhere else is replaced and reported — MUST.
    - Done: the output names the old target.
  - **1.3.6** `--dry-run` prints what it would do and changes nothing — SHOULD.
    - Done: no file modification times change.
  - **1.3.7** Installing system packages — WONT (D3).
- **1.4** Move this machine over in order — MUST.
  - First copy `~/.config/nvim` into the repo (1.2), then link it (1.3).
  - Done: `readlink ~/.config/nvim` = `~/dotfiles/nvim`, and `docs/` is intact.
- **1.5** hyprland — WONT for now. It's not in the repo.

## 2. Neovim skeleton — MUST

All of the config's Lua modules live under `lua/config/` (changed while coding, 2026-10-20). Top-level names would collide with Lua's built-in modules: `require("debug")` returns Lua's own `debug` library. It also matches `:checkhealth config`, which loads `lua/config/health.lua`.

- **2.1** `init.lua` loads in this order: options → core keymaps → pack hooks → capability modules — MUST.
  - Done: after plugins are installed on a fresh clone, `nvim --headless +qa` exits 0 with no errors.
- **2.2** Plugin hooks and update tracking (`lua/config/pack.lua`) — MUST.
  - **2.2.1** All `PackChanged` build steps are registered in one place, before the first `vim.pack.add` — MUST.
    - The pattern is in `:help vim.pack-events`.
    - Done: deleting a plugin's folder and restarting reinstalls it *and* runs its build step.
  - **2.2.2** On every update, write a timestamp to `stdpath('state')/pack-updated` — MUST (D8).
    - Done: after `vim.pack.update()`, the file holds the current time.
- **2.3** Option fixes — MUST.
  - **2.3.1** `expandtab`, `autoindent` and `smartindent` are set through `vim.opt`.
    - Done: `:set expandtab?` reports `expandtab`.
  - **2.3.2** `undofile` is on, and the custom `undodir` is removed.
    - Done: undo history survives `:restart`.
  - **2.3.3** The clipboard on WSL works with `wl-clipboard`, which WSLg can use.
    - Neovim tries clipboard tools in order: `wl-copy`, then `win32yank.exe`, then tmux. Without the first two, inside tmux, it falls back to tmux's clipboard (C, `autoload/provider/clipboard.vim:184-266`).
    - Done: `yy` in Neovim on WSL and pasting in a Windows app gives the same line.
    - Whether WSLg's `wl-copy` reaches the Windows clipboard: P.
- **2.4** Core keymaps — MUST.
  - Everything in `lua/keymaps.lua` stays.
  - Every keymap gets a `desc`; `n` and `N` lack one now.
  - Done: `:map` shows a description for every keymap defined in the config.
- **2.5** A `:checkhealth config` check — MUST.
  - **2.5.1** Each capability module declares the external tools it needs. The check only collects them — MUST.
    - Done: adding a tool to one module makes it appear in the check, with no edit to the check itself.
  - **2.5.2** Minimum versions: fzf ≥ 0.36, tree-sitter ≥ 0.26.1, nvim ≥ 0.12 — MUST.
    - Done: a fake `fzf 0.29` on the PATH produces an ERROR that names the required version.
  - **2.5.3** Each error includes an install command for pacman or apt — SHOULD.
    - Done: each ERROR contains a command for the current OS.
  - **2.5.4** On WSL, report an error when the clipboard tool is tmux — MUST.
    - Done: with `wl-clipboard` uninstalled, the check reports an ERROR.
- **2.6** Recognize `*.surql` as the filetype `surql` — MUST.
  - Done: opening `x.surql` gives `:set ft?` = `surql`.
- **2.7** Use the built-in `.editorconfig` support for per-project indentation (P) — SHOULD.
  - Done: in a project with `indent_size = 2`, `:set shiftwidth?` reports `2`.
  - Per-language indentation files — WONT. The old Python and TSX ones duplicated the global settings.

### Things Mason doesn't install (D3)

These go in the README and in the health check:
- rg
- fzf ≥ 0.36: pacman on Arch, apt 0.44 on Ubuntu 24.04 (U)
- A C compiler, curl, tar, git
- node/npm, rustup, go, python
- wl-clipboard (WSL)
- libgomp for codediff (U)

## 3. Interface — MUST

- **3.1** silkcircuit, in the **neon** variant, set in the config — MUST.
  - The config sets it because otherwise the choice lives in a preferences file under `stdpath("data")`, outside the repo.
  - Done: a fresh clone starts in neon.
- **3.2** ui2 — MUST.
  - Done: long `:messages` output gives no "Press ENTER" prompt.
- **3.3** Statusline: the built-in default plus a few additions — MUST.
  - **3.3.1** Keep the default diagnostics and LSP progress.
    - Done: both show while rust-analyzer is indexing.
  - **3.3.2** Git branch, taken from gitsigns (C3).
    - Done: the branch shows inside a repo and is absent outside one.
  - **3.3.3** Macro recording.
    - Needed because `cmdheight=0` hides Neovim's own "recording" message.
    - Done: after `qa`, the statusline shows that `@a` is recording.
  - **3.3.4** A reminder when plugins haven't been updated for 30 days.
    - Done: backdating `pack-updated` by 31 days makes it appear.
- **3.4** mini.icons, also standing in for nvim-web-devicons — MUST.
  - Done: fzf-lua's file list shows icons.
- **3.5** which-key, with a label for every leader group in §13 — MUST.
  - Done: pressing `<leader>` lists all the groups with their labels.

## 4. Language intelligence — MUST

- **4.1** Treesitter (nvim-treesitter `main`) — MUST.
  - **4.1.1** Parsers: rust, typescript, tsx, javascript, html, css, go, python, graphql, sql, toml, yaml, json, lua, markdown, markdown_inline, bash — MUST.
    - Done: `:checkhealth nvim-treesitter` lists them all.
  - **4.1.2** Highlighting is switched on per filetype with `vim.treesitter.start()` — MUST.
    - Done: `:Inspect` in a `.rs` file shows treesitter highlight groups.
  - **4.1.3** SurrealQL parser — SHOULD.
    - Registered through `User TSUpdate`, as `surrealql`.
    - URL: `https://github.com/surrealdb/surrealql-tree-sitter`.
    - Pinned to revision `329dcec`.
    - Mapped to the `surql` filetype with `vim.treesitter.language.register` (C).
    - Done: `.surql` files get treesitter highlighting.
  - **4.1.4** Treesitter-based indentation — MAY. It's experimental.
- **4.2** LSP — MUST.
  - **4.2.1** Mason plus mason-tool-installer, with one tool list — MUST.
    - The list takes lspconfig server names, which it translates through mason-lspconfig.
    - It installs on `VimEnter` (C).
    - Done: on a fresh clone, startup installs everything on the list without being asked.
  - **4.2.2** An explicit `vim.lsp.enable{...}` list — MUST.
    - Servers: tsc, tailwindcss, cssls, html, emmet_language_server, eslint, biome, gopls, basedpyright, ruff, graphql, postgres_lsp, sqruff, taplo, yamlls, marksman, lua_ls, surql.
    - rust-analyzer comes from rustup through rustaceanvim, not lspconfig.
    - Done: in a `.tsx` file, `:lsp` lists `tsc` and `tailwindcss`, plus eslint or biome where the project has a config for them. It never lists lspconfig's `rust_analyzer`.
  - **4.2.3** Per-server overrides — MUST. Overrides of lspconfig's configs go in `after/lsp/`, which is what overrides a plugin's `lsp/*.lua` (`:help lsp-config`). Servers lspconfig doesn't have go in `lsp/`.
    - **4.2.3.1** `lua_ls` gets the Neovim runtime as a library.
      - Done: `vim.` completes in config files.
    - **4.2.3.2** `surql` is a hand-written config with `cmd = { 'surreal-lsp' }` (or `surreal lsp stdio`) and `filetypes = { 'surql' }`.
      - Done: hover works in a `.surql` file.
    - **4.2.3.3** `postgres_lsp` attaches only where a `postgres-language-server.jsonc` exists (C, lspconfig default). No override is needed.
      - Done: no `postgres_lsp` client in a SQLite project.
  - **4.2.4** Diagnostics show as signs only, with no text in the buffer — MUST.
    - The built-in `<C-w>d` opens the message for the line, and `]d`/`[d` jump between them (P).
    - The counts stay in the statusline.
    - Done: an error shows a sign and no text, and `<C-w>d` opens a float with the message.
  - **4.2.5** `tsc` uses the project's `node_modules/.bin/tsc` when it's version 7 or newer, otherwise Mason's (C).
    - Side effect: a bare `tsc` typed inside Neovim runs Mason's 7.x (P).
- **4.3** blink.cmp `1.*` — MUST.
  - Pinning to `1.*` makes blink download its prebuilt binary to `<plugin>/target/release/` on `setup()` (C). `main` is v2, which needs `blink.lib`.
  - Sources: lsp, path, buffer. SQL files use `lsp`, `dadbod` (`vim_dadbod_completion.blink`, no compatibility layer needed (C)) and `buffer`.
  - No snippet source (D12). Keys are blink's defaults.
  - Done:
    - `target/release/libblink_cmp_fuzzy.so` exists after the first start.
    - Path completion offers files.
    - SQL completion offers table names when connected.
    - `<C-y>` accepts.
- **4.4** Formatting with conform — MUST.
  - **4.4.1** Formatters by filetype — MUST.

    | Filetype | Formatter |
    |---|---|
    | TS/JS/CSS/HTML/Markdown/YAML/GraphQL | prettierd, or biome where `biome.json` exists |
    | Rust | rustfmt |
    | Go | goimports + gofumpt |
    | Python | ruff |
    | Lua | stylua |
    | SQL | sqruff (built into conform (C)) |
    | SurrealQL | surqlfmt, as a custom formatter |
    | TOML | taplo |

    - Done: saving a badly formatted file of each type reformats it.
  - **4.4.2** Format on save, with a toggle — MUST.
    - Done: after toggling it off, saving leaves the file unchanged.
- **4.5** Linting comes only from language servers. rustaceanvim runs clippy — MUST.
  - Done: `if v.len() == 0` in a `.rs` file shows a clippy `len_zero` warning. An unused `mut` would be a rustc warning, so it wouldn't prove clippy runs.

## 5. Navigation — MUST

- **5.1** fzf-lua — MUST.
  - Pickers: files, grep, recent files, buffers, keymaps, help, diagnostics, TODOs, the LSP pickers, plus `register_ui_select` (C).
  - Icons come from mini.icons (`file_icons = "mini"`).
  - Done: every key in §13 under `<leader>f`, `gd` and `gR` opens the matching picker.
- **5.2** mini.files — MUST.
  - Done: `<leader>ee` and `<leader>ef` work as before.
- **5.3** arrow.nvim with `leader_key = "<leader>m"` — MUST.
  - No `buffer_leader_key` — WONT.
  - Whether `leader_key` accepts a `<leader>` combination: P.
  - Done: `<leader>m` opens arrow, and `;` still repeats `f`/`t`.
- **5.4** vim-tmux-navigator — MUST.
  - The tmux side already lives in `dotfiles/tmux/plugins`.
  - Done: `<C-h/j/k/l>` moves between Neovim splits and tmux panes in both directions.

## 6. Git — MUST

- **6.1** gitsigns `2.*` — MUST.
  - Done: `<leader>gs` stages one chunk, confirmed by `git diff --cached`.
- **6.2** codediff `4.*` — MUST.
  - Its library downloads on first use into the plugin folder (C), using curl.
  - Done: `:CodeDiff HEAD~1` shows every changed file side by side.

## 7. Debugging — MUST

- **7.1** nvim-dap + nvim-dap-view `1.*` — MUST.
  - Done: a breakpoint set in a source file stops execution there.
- **7.2** Debug adapters.
  - **7.2.1** Rust through rustaceanvim `9.*` and codelldb — MUST.
    - Done: debugging a `cargo test` stops at the breakpoint.
  - **7.2.2** Node through js-debug-adapter — MUST.
    - Done: a Node script stops at the breakpoint.
  - **7.2.3** The browser (Chrome) through js-debug-adapter — SHOULD.
    - Whether it works from WSL: ?.
    - Done: a breakpoint in a React component is hit.
  - **7.2.4** Go through delve — SHOULD.
    - Done: same check as 7.2.1.
  - **7.2.5** Python through debugpy — SHOULD.
    - Done: same check as 7.2.1.

## 8. Tests — MUST

- **8.1** vim-test `3.*` + vimux `1.*`, with `vim.g['test#strategy'] = 'vimux'` — MUST.
  - It detects vitest, cargo test, go test and pytest (C).
  - Done: running the nearest test under the cursor runs it in a tmux pane.

## 9. Databases — MUST

- **9.1** vim-dadbod + vim-dadbod-ui + vim-dadbod-completion — MUST.
  - Done: you can browse Postgres and SQLite schemas and run a query from a buffer.
- **9.2** Connection details come only from environment variables — MUST.
  - vim-dotenv loads the project's `.env`.
  - dadbod-ui reads `DB_UI_<NAME>` variables, which become connections named `<name>`, or `$DBUI_URL` (C, dadbod-ui README:71-94).
  - Done: `git -C ~/dotfiles grep -iE 'postgres(ql)?://'` finds nothing, and a project's `.env` with `DB_UI_DEV=…` shows a `dev` connection.
- **9.3** Database config files per project.
  - **9.3.1** The README explains what each kind of project needs — MUST.
    - A Postgres project needs `postgres-language-server.jsonc` and a `.sqruff` with `dialect = postgres`.
    - A SQLite project needs a `.sqruff` with `dialect = sqlite` (C).
    - Done: following the README, a Postgres project shows postgres_lsp diagnostics and a SQLite project shows none.
  - **9.3.2** Creating these files automatically — WONT. They belong to each project.
  - **9.3.3** Keeping each project's `.env` out of git — WONT here. That's the project's job.

## 10. Editing helpers — MUST

Each item is done when its check passes:

| # | Plugin | Done |
|---|---|---|
| 10.1 | mini.ai | `cin(` changes inside the next parentheses, even with the cursor before them |
| 10.2 | mini.surround | Surrounding a word with quotes works |
| 10.3 | mini.pairs | Typing `(` inserts `()` |
| 10.4 | nvim-ts-autotag | Typing `<div>` in a `.tsx` file adds `</div>` |
| 10.5 | todo-comments | `]t` jumps to the next TODO |
| 10.6 | `:Undotree` (built in, `packadd nvim.undotree`) | `<leader>u` opens the undo tree |
| 10.7 | crates.nvim | Version hints show in `Cargo.toml` |
| 10.8 | claudecode.nvim (main), terminal provider `"none"` | Inside Claude Code in a tmux pane, `/ide` lists Neovim; it connects through `~/.claude/ide/<port>.lock` (C) |

## 11. Documentation — MUST

- **11.1** `nvim/README.md`, laid out as in D24 — MUST.
  - Contents:
    - One section per capability.
    - For each plugin: why it's there, its keys, its status, and the date it was added.
    - "Review: 2027-10" at the top.
    - The prerequisites (§2).
    - The per-project database files (9.3).
  - Done: every plugin in `nvim-pack-lock.json` has an entry in the README.
- **11.2** `docs/` goes into the repo along with the config — MUST (covered by 1.2).

## 12. Markdown — MUST

- **12.1** render-markdown.nvim, using silkcircuit's theme for it — MUST.
  - Done: headings, code blocks, lists and tables render in normal mode and show as plain text in insert mode (P).
- **12.2** `after/ftplugin/markdown.lua` — MUST.
  - **12.2.1** `spell` and `linebreak`.
    - Done: a misspelled word is underlined.
  - **12.2.2** `wrap`, overriding the global `nowrap` for Markdown only.
    - Done: a long line wraps on screen.
  - **12.2.3** `textwidth=80`, which inserts real line breaks while typing.
    - Done: typing past column 80 starts a new line.
  - **12.2.4** The spelling dictionary `spell/*.add` is stored in the config folder, so it lives in the repo (P) — SHOULD.
    - Done: after `zg`, `git status` shows `spell/en.utf-8.add` changed.
- **12.3** List continuation through `formatoptions` `r`/`o` and the Markdown `comments` setting (P) — SHOULD.
  - Done: pressing Enter on `- foo` starts a new `- ` item.
  - If it doesn't, that's a named problem to fix.
- **12.4** The old hard-coded Tokyo Night heading colours — WONT. They would clash with silkcircuit.
- **12.5** Covered elsewhere: marksman (4.2.2), prettier (4.4.1) and the markdown parsers (4.1.1).

## 13. Keymaps

### Leader groups

| Key | Group |
|---|---|
| `f` | find |
| `e` | explorer |
| `g` | git |
| `c` | code |
| `d` | debug |
| `t` | test |
| `q` | database ("query") |
| `a` | AI (claudecode) |
| `o` | toggles |

- `<leader>u` = undotree and `<leader>m` = arrow, each on its own.
- A leader key is either an action or a group prefix, never both.

### Assigned keys

| Keys | Action | Source |
|---|---|---|
| everything in `lua/keymaps.lua` | unchanged | current config |
| `gd` / `gR` | fzf-lua `lsp_definitions` / `lsp_references` | old config |
| `gD` | `vim.lsp.buf.declaration` | old config |
| `grr` `gri` `grn` `gra` `grt` `grx` `gO` `K`, insert `<C-s>` | built-in LSP keymaps | Neovim 0.12 |
| `<C-w>d`, `]d` / `[d` | diagnostic float, next/previous diagnostic | Neovim built-in (P) |
| `<leader>ff` / `fg` / `fr` | files / live grep / recent files | old config |
| `<leader>ee` / `ef` | mini.files at cwd / at the current file | old config |
| `<leader>gs` / `gr` (normal and visual) | stage / reset chunk | old config |
| `<leader>gS` / `gR` / `gu` / `gp` | stage buffer / reset buffer / undo stage / preview | old config |
| `<leader>gb` | blame line (previously `gbl`) | old config, renamed |
| `<leader>gB` | toggle line blame | old config |
| `<leader>gd` / `gD` | diff this / diff against `~` | old config |
| `<leader>cf` | format (moved from `<leader>f`) | moved |
| `<leader>db` / `dc` | toggle breakpoint / continue | old config |
| `<leader>oh` | toggle inlay hints (moved from `<leader>th`) | moved |
| `<leader>u` | `:Undotree` | old config |
| `<leader>m` | arrow | new |
| `]t` / `[t` | next/previous TODO | old config |
| `<C-h/j/k/l>` | vim-tmux-navigator | old config |

### Dropped from the old config

| Old key | Replaced by |
|---|---|
| `gi`, `gt` | built-in `gri`, `grt`, so `gi` and `gt` keep their normal meanings |
| `<leader>rn`, `<leader>vca` | built-in `grn`, `gra` |
| `<leader>d` (delete without copying) and `<leader>d` (line diagnostics) | debug group; `<C-w>d` for line diagnostics |
| `<leader>f` (format) | `<leader>cf` |
| `<leader>t` (`git push`) | nothing; push from tmux |
| insert `<C-h>` (signature help) | built-in `<C-s>` |
| `<C-f>` (tmux-sessionizer) | nothing (assumed not wanted, since it's not in the new `keymaps.lua`) |
| `<leader>s`, `<leader>x`, `<leader>Y`, `x`, `Q`, `J`, insert `<C-c>`, `<leader>w/` `w-` `wx` `se` `sm` | nothing (assumed not wanted, since they're not in the new `keymaps.lua`) |

### Not yet assigned (picked when coding, inside the groups above)
- The other fzf-lua pickers (5.1), under `<leader>f`.
- codediff, under `<leader>g`.
- vim-test, under `<leader>t`.
- dadbod-ui, under `<leader>q`.
- claudecode, under `<leader>a`.
- Format-on-save toggle (4.4.2), under `<leader>o`.
- The remaining nvim-dap actions, under `<leader>d`.

## 14. Versions (D7)

| Plugin | Version |
|---|---|
| blink.cmp | `1.*` |
| nvim-dap-view | `1.*` |
| rustaceanvim | `9.*` |
| gitsigns | `2.*` |
| conform | `9.*` |
| which-key | `3.*` |
| nvim-lspconfig | `2.*` |
| mason | `2.*` |
| mason-lspconfig | `2.*` |
| silkcircuit | `2.*` |
| vim-test | `3.*` |
| vimux | `1.*` |
| codediff | `4.*` |
| crates.nvim | `0.*` |
| mini.nvim | `0.18.*`, raised by hand (0.x releases may break things (P)) |
| nvim-treesitter | `main` |
| fzf-lua, arrow, claudecode, mason-tool-installer, vim-dadbod, vim-dadbod-ui, vim-dadbod-completion, vim-dotenv | default branch (no usable tags (C)) |
| nvim-dap, todo-comments, nvim-ts-autotag, vim-tmux-navigator, render-markdown | default branch. Their tags weren't checked (?), so check them while coding |

## 15. Dependencies between items

| # | Coupling | Order or owner |
|---|---|---|
| C1 | 2.2 → every plugin item | 2.2 comes first |
| C2 | 4.2 LSP keymaps ↔ 5.1 fzf-lua | 4.2 owns the keymaps, which call fzf-lua |
| C3 | 6.1 → 3.3.2 | the statusline reads gitsigns' branch |
| C4 | 4.3 ↔ 9.1 | 9.1 provides the `dadbod` source; 4.3 registers it |
| C5 | 4.2 ↔ 7.2.1 | rustaceanvim is set up once, in 4.2 |
| C6 | every item's keys → §13 | §13 alone assigns letters |
| C7 | 1.2 → 1.4 | copy first, then link |
| C8 | every item → 2.5 | modules declare their tools; 2.5 collects them |
| C9 | 2.6 → 4.1.3, 4.2.3.2 | the filetype comes first |
| C10 | 9.2 vim-dotenv → the environment of Neovim, its terminals and its language servers (P) | accepted for local development |

## 16. Not yet decided
- **SurrealQL language server install** (4.2.3.2): cargo, a release binary, or `surreal install lsp`. It isn't in Mason.
- **surqlfmt install** (4.4.1): it's on npm (`@surrealdb/surql-fmt`), not in Mason. Global npm, or per project?
- **Whether `tsc` (TypeScript 7) covers everything tsserver did** (D10): falling back to vtsls would be a named problem.
- **Whether dadbod supports SurrealDB:** ?. If not, run queries with the `surreal` CLI in tmux.
