# Changelog

Changes in the `njhoffman/fzf-tab` fork; upstream's are in
[Aloxaf/fzf-tab](https://github.com/Aloxaf/fzf-tab/commits/master). Format:
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions are upstream's release plus a
fork counter (`1.3.0+nj.N`, see CLAUDE.md).

## [Unreleased]

## [1.3.0+nj.23] - 2026-11-27

### Added

- `group-header-style` gives every name in the header line attributes of its own (`bold`, `dim`,
  `italic`, `underline`, `reverse`), without touching the candidate rows that share
  `group-colors`; `dim` sets the other names off from the active one.

### Changed

- The active group's name drops dim (SGR 22 before its `active-group-style`), so a dim group color
  or `group-header-style dim` no longer dims it too.
- `group-header-layout compact` puts one space on each side of each name: two between names.

## [1.3.0+nj.22] - 2026-11-27

### Added

- `group-header-layout compact` puts one space after each group name in the header line instead
  of columns as wide as the longest name (default `columns`; `group-header-align` applies to
  columns only).

## [1.3.0+nj.21] - 2026-11-27

### Added

- `group-header-align center` centers each group name in its column of the header line (default
  `left`, as before).

### Fixed

- The active group's header gets its `active-group-style` decoration. A comma-separated value
  (`bold,italic`, as this README showed) was dropped whole, which left no style at all; both
  `bold,italic` and upstream's `bold italic` work now.
- The decoration also applies to group names with brackets or other pattern characters, such as a
  `'[%d]'` descriptions format gives (`[alias]`); they never matched.

## [1.3.0+nj.20] - 2026-11-27

### Added

- `active-group-style` takes any comma-separated combination of `bold`, `italic`, `underline` and
  `reverse` (`reverse,italic`, `bold,underline,reverse`, ...), with `none` overriding the rest;
  before, only a fixed list of pairs worked. Upstream PR #582's code, with the fork's `italic`.

### Changed

- More tests for the unambiguous fast path: case twins that differ before the last path segment
  (`A/xaaa`, `a/xaaa`), and upstream PR #605's two unclosed-quote cases. The twins tests now run
  with zsh about to insert, as in the upstream report, so the fast path's checks really run.

## [1.3.0+nj.19] - 2026-11-26

### Added

- `FZF_TAB_NO_MODULE=1`, set before fzf-tab loads, keeps a built C module unloaded (the pure zsh
  path). The test runner runs each test file without and then with the module when it is built.

### Changed

- `modules/Src/fzftab.c` is upstream's file again: the fork had only reformatted it, which made
  every upstream change to the module a merge conflict. No change in behavior.
- CI uses `actions/checkout@v5` and runs the tests on macOS too.
- README.md says it is the fork (badges point at the fork's CI), describes `popup-max-height` as
  bounding the list's rows (the popup adds 4), and says what `use-fzf-default-opts` covers
  (`FZF_DEFAULT_OPTS_FILE` too) and that `--history` and `--preview` are always turned off.

## [1.3.0+nj.18] - 2026-11-26

### Fixed

- Sourcing fzf-tab a second time (`source ~/.zshrc`, a plugin reload) with the C module loaded no
  longer reports the module out of date and asks to rebuild it.
- fzf-tab's temporary directory (`${TMPPREFIX:-/tmp/zsh}-fzf-tab-$USER`), whose files previews,
  bindings and the popup source, must be your own, mode 700 and not a symlink. One that someone
  else owns (created first on a shared host) or a symlink is not used: fzf-tab moves to
  `$XDG_RUNTIME_DIR/fzf-tab` with a notice, or stops with a message when that is unset. Your own
  directory made with the umask by earlier versions is made 700. `fzf-tab-debug`'s logs go there
  too.
- The tmux popup is placed correctly below a one-line status bar at the top (tmux reports it as
  `on`, which counted as 0 lines).
- `ftb-tmux-popup` on its own (`ls | ftb-tmux-popup`) reads `fzf-tmux-width-factor`, with its
  default of 5; it used 0.
- `disable-fzf-tab` puts Tab and `^X.` back in both the emacs and viins keymaps, as it found them,
  and forgets the saved `list-grouped` setting (a misspelled name kept it).
- Without fzf on `PATH`, Tab is zsh's own completion menu, with a one-time notice, instead of
  failing with "command not found: --ansi". `ftb-fzf` and `ftb-tmux-popup` say "fzf not found on
  PATH" and return 127.

## [1.3.0+nj.17] - 2026-11-26

### Fixed

- Switching tmux panes with the completion list open no longer types an I or O (focus events)
  into fzf's query or, with the popup, onto the command line: fzf-tab turns the terminal's focus
  reporting off while fzf runs. Since 1.3.0+nj.9 fzf-tab runs the fzf binary directly, past the
  `fzf` shell function that used to do this.

### Added

- `focus-reporting restore` turns focus reporting on again after fzf, for a shell that keeps it
  on at the prompt (the default, `off`, leaves it off).

## [1.3.0+nj.16] - 2026-11-25

### Fixed

- With the C module loaded, carapace's doubly quoted words are inserted with one backslash too:
  1.3.0+nj.5's fix (upstream PR #584) ran in the zsh loop that the module's
  `fzf-tab-compcap-generate` replaces, so it never applied there. The words are cleaned before
  either path stores them; the suite passes with and without the module.

## [1.3.0+nj.15] - 2026-11-22

### Removed

- `util.zsh` (logging helpers nothing called; `fzf-tab-debug` keeps its per-user log directory
  itself), the empty `fzf-tab-complete-popup` widget, and the commented-out log calls and
  leftover lines in `lib/-ftb-fzf` and `lib/ftb-tmux-popup`.

## [1.3.0+nj.14] - 2026-11-22

### Fixed

- Messages from `_message` and `compadd -x` stay visible when completion finds nothing and the
  Tab widget still returns 0 (a wrapper that ends in `zle redisplay`): fzf-tab's apply step
  cleared zsh's list that holds them (upstream #604, its suggested fix; the warnings test now
  clears the list before its `clear-screen`, which redrew it into the log a second time).
- Temporary files of shells that died while fzf was open are removed the next time fzf-tab uses
  its directory: files whose PID suffix is no running process of yours.

## [1.3.0+nj.13] - 2026-11-22

### Fixed

- Completions with an `fzf-preview` work again: since 1.3.0+nj.9 the preview command was also
  passed to fzf as an argument of its own (`${fzf_preview:---no-preview}` is the preview when
  there is one), and fzf stopped with `unknown option: ...`. `--no-preview` is added only when
  there is no preview; the preview test checks fzf's arguments for it.

## [1.3.0+nj.12] - 2026-11-22

### Fixed

- `fzf-command` other than `fzf` and `ftb-tmux-popup` (`sk`, an fzf with flags) runs as
  configured again; since 2025-08 the fork replaced every one with `ftb-fzf`, which runs
  `$commands[fzf]`. The default `fzf` still goes through `ftb-fzf`.

## [1.3.0+nj.11] - 2026-11-22

### Fixed

- Switching groups works when two groups share a color: the list keeps a hidden group number
  for the filter and the header style (upstream #581, PR #585, cherry-picked with its tests).
- A `compadd -x` message with spaces is passed as one argument; unquoted, the words after the
  first became matches. Upstream PR #592's version (`$_mesg[2]`) drops the message: `_mesg` is
  an associative array keyed `-x`, so this uses `${_mesg[-x]}`.
- fzf inside the tmux popup no longer opens a popup of its own when fzf's defaults carry
  `--tmux`/`--popup` (upstream #587): `--no-tmux` is added then, also for a defaults file, where
  upstream PR #588 only edits the variable.

## [1.3.0+nj.10] - 2026-11-22

### Fixed

Upstream fixes, cherry-picked:

- `$realpath` and `$word` reach execute bindings, and fzf-tab's own `lib/` comes first in `fpath`,
  so another fzf-tab copy's helpers are never autoloaded instead (PR #577).
- Loading no longer registers an autoload stub named `--` (#593, PR #598).
- The external `sort -u` fast path is used only with GNU sort; BSD sort dropped candidates that
  differ only in CJK characters (#602, PR #595).
- `build-fzf-tab-module` uses `builtin cd`, so a `cd` function (zoxide) cannot break it (PR #594).

### Added

- A test that runs a preview as fzf does (`{f}` a file of the row) and checks `$word` and
  `$realpath`; the tmux stub now keeps the rows and fzf-tab's temporary files for it.

## [1.3.0+nj.9] - 2026-11-22

### Fixed

- fzf's defaults file (`$FZF_DEFAULT_OPTS_FILE`) follows `use-fzf-default-opts` like
  `$FZF_DEFAULT_OPTS`: without it fzf-tab ignores the file too (upstream PR #505 cleared only
  the variable, as fzf-tab did). With it, two options that cannot work on fzf-tab's rows are
  turned off on the command line, where `fzf-flags` can turn them on again: `--history` (completion
  queries filled fzf's search history) and `--preview` where no `fzf-preview` applies (a
  `--preview` from the defaults got fzf-tab's NUL-separated row for `{}`, not a path). In the tmux
  popup as well.

## [1.3.0+nj.8] - 2026-11-22

### Fixed

- With `complete_in_word`, Tab inside a word with several matches (`ls ab|x`) opens the picker:
  the fast path compared zsh's common string with the part of the word before the cursor only,
  so it took the whole word for something new to insert, did nothing, and did it again on the
  next Tab (upstream #603). The comparison includes the part after the cursor now; 1.3.0+nj.7's
  check already sent this case to the picker, and the test covers both.

## [1.3.0+nj.7] - 2026-11-22

### Fixed

- Tab no longer inserts a common string that no candidate has. fzf-tab's unambiguous fast path
  took zsh's `compstate[unambiguous]` as it came, but with matchers it can be a string no
  candidate starts with or contains; it now opens the picker in those cases instead:
  - the typed word is already longer than the common string (`dir/` became `dir`), or the string
    starts no candidate (substring matchers fabricated `fforgejo-actions`; carapace's doubly
    quoted words gave `my\\ ` for `my\ file.json`) (upstream PR #597);
  - subsequence matchers produced a string not found in every candidate (upstream #560, PR #576);
  - case-insensitive matchers with candidates that differ only by case (`xaaa`, `Xaaa`) inserted
    one of them (upstream #589, PR #600).

  The three upstream PRs patch the same lines; their checks are combined in
  `-ftb-unambiguous-safe`, with their tests.

## [1.3.0+nj.6] - 2026-11-22

### Fixed

- Upstream's changes to `fzf-tab.zsh` are back. The 1.3.0+nj.1 merge took the fork's whole file
  where only a blank line conflicted, dropping what upstream had changed in it since 2023: the
  `_approximate` fixes (#554, #568: corrections showed zsh's own menu), the SIGCHLD workaround
  for zsh's non-reentrant pattern buffer, cygwin's `//` trigger (#531), the subshell-free
  `-ftb-compadd` (#514) and the rest. Merged again three-way; only the fork's own changes differ
  from upstream now.

## [1.3.0+nj.5] - 2026-11-22

### Fixed

- A file picked from a carapace completion is inserted with one backslash before a space
  (`my\ file.json`), not two: carapace hands `compadd -Q` words quoted twice, and fzf-tab put
  them on the line as they were. Upstream PR #584, with a test.

## [1.3.0+nj.4] - 2026-11-22

### Fixed

- The tmux popup's zstyles apply again: since 2025-08-02 `lib/-ftb-fzf` ran `ftb-tmux-popup` (and
  `ftb-fzf`) by path, as a separate zsh that sees none of the completing shell's zstyles, so
  `popup-border-style`, `popup-border-color`, `popup-max-height`, `popup-max-width`,
  `popup-smart-tab-bindings`, `use-fzf-default-opts` and `fzf-tmux-width-factor` all fell back to
  their defaults. They are autoloaded functions and are called by name again, as upstream does.
- `fzf-tab-debug` writes its trace to `${TMPPREFIX:-/tmp/zsh}-fzf-tab-$USER/debug-PID-N.log` (the
  per-user directory fzf-tab already uses, created with mode 700), not
  `/tmp/fzf-tab/-PID-fzf-tab-N.log` in a directory that might not exist.

### Added

- README.md documents the fork's zstyles (continuous-trigger keys, active-group-style values, the
  popup options).
- Tests for the popup options (a stub tmux records `display-popup`'s arguments), including one
  through a real completion.

### Removed

- `README`, the man page zinit's z-a-man generates from README.md, is no longer committed
  (`.gitignore`); z-a-man still writes it locally.

## [1.3.0+nj.3] - 2026-11-22

### Fixed

- `util.zsh` no longer forks `date`: it ran `$(date +%s)` whenever it was sourced, which was at
  every shell start and, since `lib/-ftb-fzf` sourced it again, at every completion. Times come
  from `$EPOCHSECONDS` and the `strftime` builtin. `lib/-ftb-fzf` no longer re-sources it (the
  plugin loads it once in the same shell), and `lib/ftb-tmux-popup` no longer sources it on every
  popup (its logging calls are commented out).

## [1.3.0+nj.2] - 2026-11-22

### Added

- `continuous-trigger` takes several keys (`zstyle ':fzf-tab:*' continuous-trigger / ' '`): fzf
  expects them all, and any one accepts the selection and completes again. A space accepts it as
  an argument and completes the next one: after a directory (`dir/`) it adds the space instead of
  going into the directory, which `/` still does. After a space, a next argument with a single
  candidate is not inserted: completion stops with the cursor after the space.

## [1.3.0+nj.1] - 2026-11-22

The fork's first versioned release: its changes since it branched (upstream 6aced3f, 2023),
merged with upstream's master at 24105b1 (v1.3.0 and 3 commits).

### Added

- tmux popup options: `popup-border-style`, `popup-border-color`, `popup-max-height`,
  `popup-max-width`, `popup-smart-tab-bindings` (the tab/btab bindings when the popup opens above
  the cursor), `fzf-tmux-width-factor` (added to the candidates' width).
- `use-fzf-default-opts` (upstream's) applies to the tmux popup too.
- `lib/ftb-fzf`, the fzf wrapper the non-popup path runs; `util.zsh` logging helpers.
- `active-group-style` accepts `italic` and `bold,italic` (the fork drew the active group header
  bold italic before upstream's option existed).

### Changed

- Synced with upstream master (24105b1), except `fzf-tab.zsh`, whose upstream changes were lost
  in the merge (restored in 1.3.0+nj.6): the preview setup comes from upstream's
  `lib/-ftb-preview.tpl`, which still exports `word` as completion inserts it (quoted), as the fork
  did; group switching uses upstream's `active-group-style`; the `dd` query workaround is gone, as
  upstream removed it.
- The C module's source is reformatted.
- Debug traces go to `/tmp/fzf-tab/` (`__LOGDIR`).
