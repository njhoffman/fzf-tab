# Changelog

Changes in the `njhoffman/fzf-tab` fork; upstream's are in
[Aloxaf/fzf-tab](https://github.com/Aloxaf/fzf-tab/commits/master). Format:
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions are upstream's release plus a
fork counter (`1.3.0+nj.N`, see CLAUDE.md).

## [Unreleased]

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

- Synced with upstream master (24105b1): the preview setup comes from upstream's
  `lib/-ftb-preview.tpl`, which still exports `word` as completion inserts it (quoted), as the fork
  did; group switching uses upstream's `active-group-style`; the `dd` query workaround is gone, as
  upstream removed it.
- The C module's source is reformatted.
- Debug traces go to `/tmp/fzf-tab/` (`__LOGDIR`).
