# Neovim revamp — research

Researched on 2026-10-19, answering the open questions in [frame.md](frame.md). This file records findings only, not decisions.

**Sources:**
- Neovim's own help docs for the installed 0.12.5 (`/usr/share/nvim/runtime/doc/`).
- Fresh copies of the plugin repos and of `mason-org/mason-registry`.
- Plugin READMEs and GitHub.
- Activity dates are each repo's most recent push, which also counts other branches, so treat them as approximate.

**How sure each finding is:** **C** confirmed · **P** probable · **U** uncertain · **?** unknown

## Findings that affect the frame

1. **Mason and Rust.**
   - rustaceanvim "strongly recommend[s] against" a Mason-installed rust-analyzer, because it can drift from your Rust toolchain's version (C).
   - rustfmt isn't in Mason; it comes from rustup (C).
   - This partly conflicts with the frame's "Mason for external tools" constraint.
2. **Built-in LSP keymaps.** 0.12 ships its own:
   - `grr` references, `gri` implementation, `grn` rename, `gra` code action.
   - `grt` type definition, `grx` run codelens.
   - `gO` document symbols, `K` hover, insert-mode `<C-s>` signature help.
   - `CTRL-]` goes to definition through `tagfunc` (C).
   - `gR` does not collide with any of them (P).
3. **nvim-treesitter has been rewritten.**
   - It needs the `tree-sitter` command-line tool, version 0.26.1+ and not the npm package. Mason has it.
   - It also needs a C compiler, curl and tar, on both machines (C).
   - Syntax highlighting is no longer automatic. It's switched on per filetype with `vim.treesitter.start()` (C).
4. **Plugin update notices.**
   - 0.12.5 has no way to ask whether updates are pending (C).
   - The way to ask is coming in 0.13 (neovim #39285, PR #39820) (C).
5. **The lockfile and dotfiles linking.** `nvim-pack-lock.json` is written to `stdpath('config')`.
   - If the whole folder is one symlink, the lockfile is written into the repo (C).
   - If files are linked one by one and the lockfile doesn't exist yet, it's created outside the repo (C).
6. **SurrealQL** has official tools, but Neovim support has to be wired up by hand (see below).
7. **Two plugins from the old setup.**
   - tailwind-tools.nvim is archived (C).
   - snacks.nvim was last pushed 2026-05-25. That's unusually quiet for its author, and the reason is unknown (C for the date, ? for the reason).

## Must-haves

### LSP

- **Built-in:** `vim.lsp.config` / `vim.lsp.enable` merge `lsp/*.lua` files from the runtimepath (C).
  - 0.12 adds the `:lsp` command, `vim.lsp.is_enabled()` and `vim.lsp.get_configs()`.
  - `enable()` starts and stops clients automatically (C).
- **Neovim ships no server configs.** There is no `runtime/lsp/` folder (C).
- **nvim-lspconfig v2.12.0** is now a data plugin of 421 `lsp/*.lua` configs (C).
  - `require('lspconfig')` is deprecated, and it requires 0.11.3+ (C).
  - `:LspLog` comes from lspconfig (C).
  - https://github.com/neovim/nvim-lspconfig
- **mason-lspconfig v2.3.0** only installs servers and enables them (C).
  - `automatic_enable` can exclude servers; `setup_handlers` is gone (C).
  - It needs mason 2.x and lspconfig 2.x (C).
  - https://github.com/mason-org/mason-lspconfig.nvim
- **rustaceanvim** is active (2026-10-19) and needs no setup call (C).
  - Don't also enable lspconfig's `rust_analyzer` (C). With mason-lspconfig, that means excluding it (P).
  - It says plain `rust_analyzer` "is probably enough" unless you want rust-analyzer-specific extras (C).
  - https://github.com/mrcjkb/rustaceanvim
- **Servers.** Every one below has an lspconfig config and a Mason package (C):

| Language | Servers |
|---|---|
| Rust | `rust_analyzer` (or rustaceanvim) |
| TypeScript/TSX | `tsc`, `vtsls`, `ts_ls` |
| Web | `tailwindcss`, `cssls`, `css_variables`, `cssmodules_ls`, `html`, `superhtml`, `emmet_language_server`, `emmet_ls`, `eslint`, `biome`, `oxlint` |
| Go | `gopls` |
| Python | `basedpyright`, `pyright`, `ty`, `pyrefly`, `ruff` |
| GraphQL | `graphql` |
| SQL | `sqls`, `postgres_lsp`, `sqruff` |
| TOML | `taplo`, `tombi` |
| YAML | `yamlls` |
| Markdown | `marksman`, `markdown_oxide` |
| Lua | `lua_ls`, `emmylua_ls` |

- **TypeScript 7** (the native compiler) has shipped (C).
  - It's in Mason as `tsc` (`typescript@7.0.2`), and its lspconfig config needs TS 7+.
  - `tsgo` is deprecated in both lspconfig and Mason.
- **typescript-tools.nvim** was last pushed 2025-11-18 (C).

### Completion

- **Built-in:** `vim.lsp.completion.enable(true, client.id, buf, {autotrigger=true})` (C).
  - Automatic popups open only on the server's trigger characters (C).
  - Accepting with `<C-y>` applies snippets, extra edits (such as auto-imports) and commands (C).
  - 0.12 adds sorting across multiple servers, a documentation preview popup, and LSP inline completion (C).
- **The new `'autocomplete'` option** shows the popup while typing, using the `'complete'` sources (C).
  - New `'complete'` flags: `o` (omnifunc, which includes LSP), `F{func}`, and a per-source limit `^N`.
  - New `'completeopt'` value `nearest` and new option `'pummaxwidth'`.
- **Other built-ins** (C):
  - Snippets: `vim.snippet`.
  - Signature help: manual, insert-mode `<C-s>`.
  - Colors: LSP document colors (Tailwind, CSS) are on by default.
- **blink.cmp** (2026-10-18):
  - The latest stable release is v1.10.2. The `main` branch is v2, which requires 0.12, adds a dependency on `saghen/blink.lib`, and uses a new build step `require('blink.cmp').build():pwait()` (C).
  - The README says to pin `1.*` for stability (C).
  - Prebuilt Rust matcher binaries download only on a release tag. A Lua matcher is the fallback (C).
  - Its docs for placing the binary by hand only cover lazy.nvim's folder (C).
  - It supports `vim.snippet`, friendly-snippets, LuaSnip and mini.snippets. Signature help is experimental and off by default. It draws its own color swatches for Tailwind and CSS (C).
  - https://github.com/Saghen/blink.cmp
- **nvim-cmp** was last pushed 2026-07-10 (C).

### Treesitter

- **What 0.12 ships** (C):
  - Bundled parsers: c, lua, markdown, markdown_inline, query, vim, vimdoc.
  - Markdown highlighting is on by default.
  - Selecting by syntax node is built in: `an`/`in`/`]n`/`[n`, falling back to the LSP's selection ranges.
- **nvim-treesitter** defaults to the `main` branch, is active (2026-10-19), and requires 0.12 (C).
  - `install{...}` runs in the background; scripts must call `:wait()`.
  - Indentation through `indentexpr` is experimental.
  - The old `master` branch is frozen for 0.11 compatibility.
  - https://github.com/nvim-treesitter/nvim-treesitter
- **nvim-treesitter-textobjects** has a `main` branch with a new module API (2026-09-03) (C).

### Fuzzy finder

| Option | Status | Needs | Notes |
|---|---|---|---|
| telescope.nvim | v0.2.2, few commits lately (C) | 0.11.7+, `rg` (C) | LSP pickers (P) |
| fzf-lua | very active, 2026-10-16 (C) | `fzf` > 0.36, `rg` (C) | README documents installing with vim.pack. LSP and grep pickers (C). Fastest (P, not benchmarked) |
| mini.pick | active, 2026-10-13 (C) | nothing (uses `rg` if present) (C) | LSP pickers come from mini.extra (P) |
| snacks.picker | last push 2026-05-25 (C) | — | LSP and grep pickers (P) |

### Formatting and linting

- **Built-in formatting:** `'formatexpr'` is set to `vim.lsp.formatexpr()`, so `gq` formats through the LSP. `vim.lsp.buf.format()` exists, and on-type formatting is supported (C).
  - There is no built-in format-on-save and no runner for external formatters (C).
- **conform.nvim** is active (2026-08-11) and can fall back to the LSP per filetype, e.g. `lsp_format = "fallback"` (C).
- **In Mason:** prettierd, prettier, biome, stylua, gofumpt and goimports. **Not in Mason:** rustfmt (C).
- **nvim-lint** is active (2026-10-07) and runs on `BufWritePost` / `try_lint()` (C).
- **Linters that run as language servers:** eslint, ruff, oxlint, biome (C).
  - Mason also has golangci-lint, eslint_d, sqlfluff and markdownlint-cli2 (C).
  - Clippy can run through rust-analyzer's `check.command = "clippy"` (P).

### Other 0.12 built-ins

All confirmed (C) from the installed `news.txt` and help pages:
- **vim.pack:** labelled "experimental, yet should be stable enough for daily use".
  - The lockfile belongs under version control.
  - Build steps hook into `PackChangedPre` / `PackChanged`. Register the autocmd before `vim.pack.add()` to catch installs.
- **Commenting:** `gc` / `gcc`.
- **Diagnostics:** `virtual_lines` display.
- **Default statusline:** diagnostics, LSP progress, a busy indicator, and terminal exit codes.
- **Restart:** `:restart` / `ZR` restart and restore the session; `:restart!` skips the session.
- **ui2:** an experimental message and command-line UI.
- **Built-in plugins:**
  - `:Undotree` (`:packadd nvim.undotree`).
  - `:DiffTool` (`:packadd nvim.difftool`), which can be wired in as `git difftool -d`.
- **LSP extras:** renaming a tag's pair together, document colors, code lenses (reimplemented), inline completion.
- **Diff and other defaults:**
  - `diffopt` gains `inline:char` and `indent-heuristic`.
  - `'exrc'` also loads from parent folders.

## Optional plugin options

Each entry gives the last push date. "Compared with tmux" notes what a tmux pane can't do.

### Git
- **gitsigns** (2026-10-13), no dependencies (C).
  - Compared with tmux: change markers on each line while you edit, and staging single chunks from the buffer (P).
- **vim-fugitive** (2026-03-07): stable. It's driven by commands, so there's more to remember (C/P).
- **neogit** (2026-10-14): a Magit-style status buffer whose menus list the available keys (C). Needs plenary.
  - Overlaps with lazygit in a tmux pane (P).
- **diffview:**
  - The original was abandoned in 2024-08 (C).
  - `dlyongemallo/diffview-plus.nvim` is a maintained fork (C).
  - Compared with tmux: reviewing every changed file in tabs, plus file history (P).
- **codediff.nvim** (2026-09-15): VS Code-style diffs, a merge-conflict tool, and reviewing PRs without checking out the branch (C).
  - It downloads a prebuilt C library, `libvscode-diff` (C).
- **mini.diff / mini.git:** part of mini.nvim (now `nvim-mini/mini.nvim`), active (C).
- **snacks lazygit / gitbrowse:** lazygit in a floating window, and opening the current file or commit in the browser (C). See finding 7.
- **Built-in `:DiffTool`:** diffs only; no staging, blame or history (C).

### Debugging
- **nvim-dap** (2026-09-11) (C). UI options:
  - **nvim-dap-ui** (2026-07-14), needs nvim-nio (C).
  - **nvim-dap-view** (2026-10-16), lighter, requires 0.11+ (C).
- **Debug adapters in Mason** (C): codelldb, js-debug-adapter, delve, go-debug-adapter, debugpy.
- **Per-language helpers:**
  - rustaceanvim configures Rust debugging for you (P).
  - nvim-dap-go (2025-07) and nvim-dap-python (2025-12) (C).
- **Compared with tmux:** a pane can't set breakpoints from the source file or show variable values inline. For TS/React, a debug adapter is the only terminal option (P).

### Tests
- **neotest** (2026-08-16), needs nvim-nio and plenary (C).
  - Adapters: vitest (2026-10), jest (2026-04), golang (2026-10), python (2026-07) (C).
  - Rust: through rustaceanvim (P).
- **vim-test** (2026-10-06) can send the test command to a **tmux pane** (vimux/tslime) (P).
- **Compared with tmux:** neotest shows pass/fail next to each test in the code. vim-test keeps your existing panes (P).

### Terminal and tasks
- **overseer.nvim** (2026-05-24): task templates for make, npm, cargo and VS Code's `tasks.json` (C).
  - Turns build errors into a clickable error list, and can run a task before debugging (C).
- **toggleterm** was last pushed 2025-03 (C).
- **snacks.terminal:** see finding 7.
- The built-in terminal improved in 0.12 (C).
- **Compared with tmux:** panes survive a Neovim restart. Only overseer adds something a pane doesn't (P).

### File navigation
- **harpoon2** (2025-10-31) (C).
- **arrow.nvim** (2025-11-28), with labels shown on screen (C/P).
- **grapple.nvim** (2024-09) (C).
- **Built-in file marks** plus the new `MarkSet` event (C).
- **File explorers:** mini.files (active), oil.nvim (2026-10-12), neo-tree (2026-10-17), snacks.explorer (C).

### Keymap reminders
- **which-key.nvim** (2025-10-28): stable, shows the descriptions you give keymaps (C).
- **mini.clue:** you list the trigger keys yourself (C/P).
- **Searching keymaps** from a picker (P).

### Other
- **Diagnostics and TODOs:** trouble.nvim (2025-10-31) and todo-comments (2025-11-10) (C).
- **Motion:** flash.nvim (2026-08-22). leap.nvim moved to Codeberg, and GitHub is now read-only (C).
- **Text editing:** mini.ai and mini.surround (C).
- **Undo tree:** the built-in `:Undotree` makes mbbill/undotree and jiaoshijie/undotree optional (C).
- **Dependency versions:** crates.nvim (2026-09-12) for `Cargo.toml`, package-info.nvim (2026-09-02) for `package.json` (C).
- **Markdown rendering:** render-markdown (2026-10-10) and markview (2026-10-18) (C).
- **Tags:** nvim-ts-autotag (2026-10-03) (C).
- **Color previews:** nvim-colorizer.lua (catgoose fork, 2026-07-14) and nvim-highlight-colors (2026-05-05) (C).
- **AI tools:**
  - copilot.lua and codecompanion (both 2026-10) (C).
  - claudecode.nvim (2026-10-17) links to Claude Code running in a tmux pane (C/P).
  - sidekick.nvim (2026-09) (P).
  - avante.nvim needs a build and changes fast (C).
- **Sessions:** `:restart` (C). auto-session (2026-09-22) and persistence.nvim (2025-10-28) (C). tmux-resurrect (P).
- **REST clients:**
  - kulala.nvim's core "went private and closed-source" and needs a license token (C, per README).
  - rest.nvim was last pushed 2025-12-27 (C).
- **Databases:**
  - vim-dadbod (2026-01) and vim-dadbod-ui (2026-06) (C).
  - nvim-dbee was last pushed 2025-07 (C).
  - In Mason: sqls, sqlfluff, postgres-language-server, graphql-language-service-cli (C).

## silkcircuit

- **Install:** the theme is at the root of the main repo, so vim.pack can install it directly: `colors/silkcircuit.{lua,vim}`, `lua/silkcircuit/`, `lua/lualine/themes/` (C).
  - https://github.com/hyperb1iss/silkcircuit
- **Variants:** neon, vibrant, soft, glow and dawn (light) (C).
  - Set with `setup({variant=...})`, or switch with `:SilkCircuit {variant}`.
  - The choice is saved in `stdpath("data")/silkcircuit_preferences.json`.
- **Plugin support:** 39 plugins are themed, all on by default; turn one off with `integrations.<name>=false` (C). They include:
  - telescope, fzf_lua, snacks, cmp, blink_cmp
  - treesitter, native_lsp (semantic highlighting)
  - gitsigns, which_key, neogit, mini, oil, flash, harpoon
  - dap, neotest, trouble, render-markdown, mason, lualine
- **Other apps:** `extras/` has themes for tmux, alacritty, lazygit, fzf, bat and more, in every variant (C).
- **Maintenance:** active; v2.2.0 came out 2026-09-15 and releases go through release-please (C).

## SurrealQL

- **Syntax parser:** the official one is `surrealdb/surrealql-tree-sitter` (2026-09-13) (C).
  - It targets SurrealDB v3+ and passes 353/355 tests (C).
  - It's unclear whether to follow the default branch or `tree-sitter-parity` (U).
  - The original `Ce11an/tree-sitter-surrealql` is archived (C).
- **nvim-treesitter** doesn't include SurrealQL, so the parser and its queries must be registered by hand (C).
- **Language server:** the official one is `surrealdb/surrealql-language-server` v0.6.3 (2026-10-15) (C).
  - It offers errors, hover, completion, go to definition and references, rename, code actions and symbols (C).
  - No formatting (P).
  - Install with cargo, a release binary, or `surreal install lsp`, then run `surreal lsp stdio` (C).
  - It is **not** in Mason or lspconfig, so it needs a hand-written `vim.lsp.config` (C).
- **Formatter:** `surqlfmt` (npm `@surrealdb/surql-fmt`); conform has no entry for it (C).
- **Neovim plugin:** `DariusCorvus/surrealdb.nvim`, last updated 2022 (C).

## Dotfiles linking

- **GNU stow:** Arch `extra` has 2.4.1. Ubuntu noble and jammy have 2.3.1, which has a bug with `--dotfiles` folders that was fixed in 2.4.0 (C).
  - Each top-level folder is a "package", linked into the parent of the stow folder (C).
  - The layout must mirror the home folder: `~/dotfiles/nvim/.config/nvim/...`, then `stow nvim` (C).
  - If the target folder doesn't exist, stow makes one symlink for the whole folder. If it exists, it links file by file (C).
  - If a real file is in the way, stow stops and changes nothing. `-n -v` does a dry run, `-R` relinks, and `--adopt` pulls existing files into the repo (C).
  - https://www.gnu.org/software/stow/manual/stow.html
- **A plain `install.sh`** works with either layout using `ln -sfn` (C).
  - It needs no package. Backups and conflicts are up to the script (C).
- **Other tools:**
  - chezmoi copies files and has templates per machine (C).
  - yadm treats your home folder as a git repo (C).
  - dotbot links according to a YAML file (C).

## Plugin update notices

- **0.12.5 can't report pending updates.**
  - `vim.pack.get()` has no "pending" field.
  - `vim.pack.update(nil, {offline=true})` still opens the confirmation buffer (C).
- **0.13** adds `vim.pack.get()` with `offline` and a target revision (neovim #39285 → PR #39820) (C).
- **rafi/packcount.nvim** puts an update count in the statusline, but requires 0.13+ (C).
- **swaits/tiny-packupdate.nvim** works on 0.12+.
  - It adds `:PackUpdate` with changelogs and scheduled updates. It doesn't show a pending count.
  - It's early: 8 commits (C).
- **Do it yourself on 0.12:** run `git fetch` in each `vim.pack.get()` path and compare against the spec's version (P). Exactly which git refs to compare is uncertain (U).
- **Lazy-loading add-ons for vim.pack** exist: zpack.nvim, leanpack.nvim, lz.n, lze. How mature they are is unknown (?).

## Still unknown

- Where blink.cmp's binary goes under vim.pack, and whether pinning `1.*` gets the prebuilt binary (?/P).
- Whether blink's color swatches clash with Neovim's built-in document colors (?).
- Why snacks.nvim has been quiet since 2026-05 (?).
- Which branch of the SurrealQL parser to follow, and what filetype name to use (U).
- How mature ty, pyrefly and emmylua_ls are, and whether sqls is maintained (?).
- How fast the pickers are relative to each other (no benchmark).
- Whether vim-dadbod supports SurrealDB (?).
- Whether copilot-language-server works with 0.12's built-in inline completion (?).
- Exact release dates; the GitHub API rate limit ran out.
