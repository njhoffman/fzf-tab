# CLAUDE.md

Guidance for Claude Code in this repository: `njhoffman/fzf-tab`, a fork of
[Aloxaf/fzf-tab](https://github.com/Aloxaf/fzf-tab) (zsh completion through fzf).

## Where it runs

- The checkout is `~/ghq/github.com/njhoffman/fzf-tab`; `~/git/fzf-tab` and zinit's
  `~/.zinit/plugins/njhoffman---fzf-tab` are links to it, so the working tree is what every new
  shell loads. Check the branch before editing (`git status -sb`): zinit loads whatever is checked
  out.
- `~/.shell` loads it in `zsh/plugins/widgets.zsh` (zinit `wait"0c"`, `njhoffman/fzf-tab`), with its
  zstyles in `~/.shell/zsh/plugin-configs/fzf-tab.zsh`. A change to a zstyle's meaning here needs
  the matching change there.
- Try a change in a fresh `zsh -il`; the running shell keeps the old functions.

## Commands

- `cd test && zsh -f ./runtests.zsh fzftab.ztst`: the test suite (zpty-driven completion tests;
  fzf is replaced by `test/select`, or `test/select-once` for one round of an expect key; tmux by
  `test/popup-tmux`, which logs `display-popup`'s arguments).
- `zsh -n fzf-tab.zsh lib/<file>`: syntax check.

## Layout

- `fzf-tab.zsh`: the widget (`fzf-tab-complete`), completion capture (`-ftb-complete`), apply.
- `lib/-ftb-fzf`: builds the fzf command line (bindings, `--expect` keys, preview from
  `lib/-ftb-preview.tpl`); `lib/ftb-fzf`: the fork's fzf wrapper; `lib/ftb-tmux-popup`: the tmux
  popup command; `lib/ftb-switch-group`: group switching (`active-group-style`).
- `modules/`: the optional C module (`build-fzf-tab-module`); `util.zsh`: the fork's logging helpers.
- `README` (not tracked, `.gitignore`): the man page zinit's z-a-man annex generates from
  `README.md`. The fork's zstyles are documented in README.md's "Fork additions".
- `ftb-fzf` and `ftb-tmux-popup` are autoloaded functions: call them by name, never by path, or
  they run as a separate zsh without the completing shell's zstyles.

## Upstream

- Remotes: `origin` (this fork), `upstream` (Aloxaf). `master` is the fork's branch; the local
  `upstream` branch tracks `upstream/master`.
- Sync by merging `upstream/master` into `master` (never rebase: `origin/master` is published).
  Resolve conflicts keeping the fork's features and upstream's fixes, and list each resolution in
  the merge commit.

## Versioning

- `VERSION` is upstream's release plus a fork counter as semver build metadata: `1.3.0+nj.N`.
  Every finished change bumps N, with an annotated tag `vX.Y.Z+nj.N` (upstream's `vX.Y.Z` tags are
  in the repository too; `lib/-ftb-version` reports `git describe --tags`). Merging a new upstream
  release moves the base and restarts N at 1.
- `CHANGELOG.md` (Keep a Changelog) records the fork's changes, not upstream's; `TODO.md` holds
  the fork's open work.
- Commit each finished change with its bump and tag; push only when asked.
