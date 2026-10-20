# Neovim revamp — frame

Settled on 2026-09-24. This file records the problem definition, not the solution.

## Situation

- Neovim 0.12.5 has `vim.pack` built in, plus native LSP and completion.
- The new config in `~/.config/nvim` has only `options.lua` and `keymaps.lua`, and no plugins.
- The old lazy.nvim config (about 70 plugins) is in the dotfiles repo at `~/dotfiles/nvim/`.
  - Knowingly used: telescope, mini.files, vim-tmux-navigator, autopairs, todo-comments.
  - Others were probably used without knowing which plugin was behind them.
  - Fugitive, gitsigns, nvim-dap and harpoon were installed but never used.
- There are two machines: Arch, and WSL Ubuntu on a Windows work laptop.
- The dotfiles repo (nvim, tmux, alacritty, zsh, and more) is copied onto each machine by hand, not linked.
- Day-to-day work happens in tmux.
  - Builds, tests and git run in panes and windows.
  - Each project gets its own tmux window.
  - Code is navigated with a fuzzy finder, a file tree, and LSP jumps.

## Complication

- Earlier setups were copied from tutorials and videos, so plugins piled up without being chosen.
- Plugins went unused because their keymaps were forgotten, not just because they weren't needed.
  - So the documentation must record **how to use** each plugin, not only why it's there.
- Behaviors that were relied on can't be traced to plugin names.
  - The new setup carries over behaviors, not plugins.
  - Expect a short "what's missing?" period after the switch.
- There are two kinds of additions:
  - **(a) Named problems:** a friction you've hit. If a good fix exists, add it.
  - **(b) Speculative:** might be useful, including things not yet known about.
- Trialing (b) items one at a time never ends, and turns into working on the setup instead of on projects.
  - So (b) gets one round of research and a single decision, with no trials.
  - The choice therefore rests entirely on the research.
- `vim.pack` has no built-in notice for pending updates, which Lazy used to show in the statusline.

## Question

- Which set of built-ins and plugins covers the must-haves across the languages below?
- Which experimental batch, picked from a researched menu with pros and cons, sits on top?
- How is it linked through dotfiles and documented so it can stay frozen for about a year?

## Constraints

- Neovim 0.12+, with `vim.pack` as the package manager.
- Mason installs external tools (language servers, formatters, linters).
  - Except the Rust toolchain: rust-analyzer, rustfmt and clippy come from rustup. Amended on 2026-10-20; see [design.md](design.md) D4.
- Plugins load eagerly. Optimize only if startup gets painful.
- Keymaps already in muscle memory stay, including:
  - `gd` (go to definition) and `gR` (references).
  - The fuzzy-find-files, fuzzy-grep and file-tree keymaps.
  - Everything in `lua/keymaps.lua`.
- The colorscheme is `silkcircuit` (https://github.com/hyperb1iss/silkcircuit).
- Files are split into modules, never all in `init.lua`.
  - One file per plugin vs. grouped by topic is decided once the design is clearer.
- **Freeze:** after the build, no speculative additions for about a year.
  - Named problems (a) can still be fixed during the year, with a new entry in the document.
  - Plugin updates happen now and then, and occasional breakage is acceptable.
- **Documentation:** one document, `dotfiles/nvim/README.md`, records why each plugin is there and how to use it (keymaps).
- **Dotfiles wiring:**
  - The config lives in the dotfiles repo and is symlinked into place.
  - A fresh clone should work on both machines.
  - Installation is opt-in per tool:
    - `./install.sh` installs everything.
    - `./install.sh --tools nvim tmux …` installs only the listed tools.
  - The linking is done first, so all work happens in the repo and changes show up live.

## Needs

**Must have:** LSP, completion, treesitter, a fuzzy finder, formatting, linting.

**Explore:** git and debugging inside Neovim, plus ideas from research.

**Languages:**

| Tier | Languages |
|---|---|
| 1 | Rust, TypeScript/React, HTML, CSS, Tailwind |
| 2 | Go, Python |
| Also used | GraphQL, SQL, SurrealQL (support unknown), Markdown, YAML, TOML, Lua (config only) |

## Selection criteria

- The best tool for each job, whether it's built in, your own code, or a plugin.
- Covers a gap in one of the languages above.
- If tmux can already do the job, the tool must clearly do it better.
- How much configuration it needs doesn't matter. Configuration happens now, once.
- Default keymap clashes don't matter, because they can be remapped.
- Otherwise it's a subjective call.
- There's no hard limit on the number of plugins, but the total should be clearly smaller than the old setup.

## Non-goals

- Copying or auditing the old setup plugin by plugin.
- Trialing plugins one at a time.
- Lazy-loading.
- Switching between projects inside one Neovim session.
- A hard limit on the number of plugins.

## Open for research

- Does silkcircuit ship a Neovim colorscheme?
- SurrealQL support (treesitter, LSP).
- For each must-have: is a 0.12 built-in enough, or is a plugin needed?
- A menu of experimental candidates: git, debugging, terminal and test runners inside Neovim, harpoon, and unknown ideas.
- stow vs. an install script.
- Update notifications with `vim.pack`.

## Known issues in the current files

- `options.lua`: `vim.expandtab`, `vim.autoindent` and `vim.smartindent` set nothing. They need `vim.opt.`.
- `options.lua`: `undodir` is set, but `undofile` isn't enabled.
