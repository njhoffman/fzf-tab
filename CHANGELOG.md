# Changelog

Changes in the `njhoffman/fzf-tab` fork; upstream's are in
[Aloxaf/fzf-tab](https://github.com/Aloxaf/fzf-tab/commits/master). Format:
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions are upstream's release plus a
fork counter (`1.3.0+nj.N`, see CLAUDE.md).

## [Unreleased]

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
- `use-fzf-default-opts`: pass `$FZF_DEFAULT_OPTS` to fzf (fzf-tab clears it otherwise), in the
  popup too.
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
