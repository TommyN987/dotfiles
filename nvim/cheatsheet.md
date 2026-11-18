# Neovim keymap cheat sheet

Leader is `Space`. Press it and wait: which-key lists what follows. `<leader>fk` searches every keymap.

## Editing basics

| Key | Action |
|---|---|
| `p` (visual) | Paste over selection, keep the yanked text |
| `J` / `K` (visual) | Move selected lines down / up |
| `<` / `>` (visual) | Indent, keep the selection |
| `<C-d>` / `<C-u>` | Half-page down / up, centered |
| `n` / `N` | Next / previous match, centered |
| `<C-c>` | Clear search highlight |
| `gcc` / `gc` (visual) | Toggle comment |
| `<leader>cf` | Format buffer or selection |
| `<leader>of` | Toggle format on save |
| `<leader>u` | Undo tree |

## Windows and tmux

| Key | Action |
|---|---|
| `<leader>w/` / `<leader>w-` | Split vertically / horizontally |
| `<leader>wx` | Close window |
| `<C-h/j/k/l>` | Move between splits and tmux panes |

## Code (LSP)

| Key | Action |
|---|---|
| `gd` / `gD` | Definition / declaration |
| `gR` or `grr` | References |
| `gri` / `grt` | Implementation / type definition |
| `grn` | Rename |
| `gra` | Code action |
| `K` | Hover docs |
| `<C-s>` (insert) | Signature help |
| `gO` | Symbols in file |
| `grx` | Run code lens |
| `<C-w>d` | Diagnostics on this line |
| `]d` / `[d` | Next / previous diagnostic |
| `<leader>oh` | Toggle inlay hints |

## Completion (insert mode)

| Key | Action |
|---|---|
| `<C-y>` | Accept |
| `<C-n>` / `<C-p>` | Next / previous item |
| `<C-e>` | Close menu |
| `<C-space>` | Open menu / docs |
| `<C-b>` / `<C-f>` | Scroll docs |

## Find (fzf-lua)

| Key | Action |
|---|---|
| `<leader>ff` / `fg` / `fr` | Files / grep / recent files |
| `<leader>fb` / `fh` / `fk` | Buffers / help / keymaps |
| `<leader>fd` / `fD` | Diagnostics: file / open files |
| `<leader>ft` | TODO comments |
| In a picker: `<CR>` | Open |
| `<C-s>` / `<C-v>` / `<C-t>` | Open in split / vsplit / tab |
| `<Tab>` / `<A-a>` | Select one / all |
| `<A-q>` | Send selection to quickfix |

## Files

| Key | Action |
|---|---|
| `<leader>ee` / `<leader>ef` | Explorer at cwd / current file |
| In the explorer: `<CR>` / `-` | Enter / go up |
| `L` / `H` | Open file and close / go up and trim |
| edit text, then `=` | Create, rename, delete files |
| `q` / `g?` | Close / help |
| `<leader>m` | Arrow bookmarks menu |
| In arrow: `s` | Add / remove current file |
| `1`–`9` | Open bookmark |
| `v` / `-` / `e` / `q` | Vsplit / split / edit list / quit |

## Git

| Key | Action |
|---|---|
| `<leader>gs` / `gr` | Stage / reset change (visual: lines) |
| `<leader>gS` / `gR` | Stage / reset buffer |
| `<leader>gu` | Undo last stage |
| `<leader>gp` | Preview change |
| `<leader>gb` / `gB` | Blame line / toggle line blame |
| `<leader>gd` / `gD` | Diff vs index / last commit |
| `<leader>gc` | codediff: review all changes |
| In codediff: `<leader>gs` / `gu` / `gr` | Stage / unstage / discard change |
| `-` | Stage / unstage file |
| `]c` / `[c`, `]f` / `[f` | Next / previous change, file |
| `<leader>ge` | Focus file list |
| `q` / `g?` | Close / help |

## Debug

| Key | Action |
|---|---|
| `<leader>db` / `dB` | Breakpoint / conditional breakpoint |
| `<leader>dc` | Start / continue |
| `<leader>dn` / `di` / `do` | Step over / into / out |
| `<leader>dt` | Stop |
| `<leader>dv` | Toggle debug view (`g?` inside) |
| `:RustLsp debug` | Debug Rust binary / test at cursor |

## Tests (tmux pane)

| Key | Action |
|---|---|
| `<leader>tn` / `tf` | Nearest test / file |
| `<leader>ts` / `tl` | All tests / rerun last |

## Database

| Key | Action |
|---|---|
| `<leader>qq` | Toggle database UI |
| In the UI: `o` / `?` | Open / help |
| `<leader>S` (query buffer) | Run query (visual: selection) |
| `<leader>W` / `<leader>E` | Save query / edit bind params |

## Text objects and surround

| Key | Action |
|---|---|
| `ci(`, `da"`, `yaa` | Inside / around brackets, quotes, `a`rgument, `f` call, `t`ag |
| `cin(`, `cal"` | Same, for the next / last one |
| `sa{motion}{char}` | Add surround: `saiw"` |
| `ds{char}` / `sr{old}{new}` | Delete / replace surround |
| `sf` / `sF` / `sh` | Find right / left / highlight surround |

## TODOs and AI

| Key | Action |
|---|---|
| `]t` / `[t` | Next / previous TODO |
| `<leader>ab` | Add file to Claude's context |
| `<leader>as` (visual) | Send selection to Claude |
| `<leader>aa` / `ad` | Accept / reject Claude's diff |

## Commands

| Command | Does |
|---|---|
| `:checkhealth config` | Check every tool this config needs |
| `:lua vim.pack.update()` | Update plugins (`:w` to apply) |
| `:MasonToolsUpdate` | Update Mason tools |
| `:restart` / `ZR` | Restart Neovim, keep the session |
| `:CodeDiff main` / `pr 12` / `history` | Diff vs branch / PR / file history |
