# TODO

Open work on the `njhoffman/fzf-tab` fork. Reviewed: 2026-11-22

Categories: bug feature refactor docs test chore perf

## Loading

- [x] **zinit loads the local `upstream` branch, not `master`.** (p1) [chore] The checkout was
  switched to `upstream` (upstream's code, 24105b1) on 2026-10-22, so none of the fork's features
  (popup options, `use-fzf-default-opts`, the space continuous trigger) run in new shells, and
  `~/.shell`'s zstyles for them do nothing. `master` now has upstream's code merged in. Switch the
  checkout to `master` (`git switch master`), then open a few shells and try completions (paths,
  git, a tmux popup) before relying on it. With `master` loaded, set
  `zstyle ':fzf-tab:*' active-group-style bold,italic` in `~/.shell` to keep the old header look.
  Done 2026-11-22: the checkout is on `master` (1.3.0+nj.2), `~/.shell` 0.125.1 sets
  `active-group-style bold,italic` and the two-key `continuous-trigger`; paths, git and systemctl
  completions checked in fresh shells under tmux.

## Performance

- [ ] **util.zsh forks `date` at every shell start.** (p2) [perf] `__START_TIME=$(date +%s)` runs
  when fzf-tab.plugin.zsh sources util.zsh; use `$EPOCHSECONDS` (zsh/datetime) or drop it. The
  `date` calls inside `__util_log` fork per log line too.
- [ ] **ftb-tmux-popup sources util.zsh on every popup.** (p3) [perf] Only for logging helpers
  that are commented out at their call sites.

## Cleanup

- [ ] **Debug log path.** (p3) [bug] `__LOGDIR='/tmp/fzf-tab/'` makes the trace file
  `/tmp/fzf-tab/-PID-fzf-tab-N.log` (a leading dash, a directory that may not exist); upstream used
  `${TMPPREFIX:-/tmp/zsh}-PID-fzf-tab-N.log`. Pick one and create the directory.
- [ ] **Unfinished stubs and TODO comments.** (p3) [refactor] `fzf-tab-complete-popup() { }` is an
  empty widget ("if TMUX available force popup"); `__util_log` is half commented out; the
  `# __log_*` call sites in `lib/ftb-tmux-popup` and `fzf-tab.zsh` do nothing. Finish or remove.
- [ ] **Generated `README` man page.** (p3) [docs] zinit's z-a-man writes `README` (ronn output,
  September 2023) next to `README.md`; it is stale. Stop committing it (`.gitignore`) or
  regenerate it with each release.
- [ ] **Document the fork's zstyles in README.md.** (p3) [docs] The popup options,
  `use-fzf-default-opts`, `fzf-tmux-width-factor` and the multi-key `continuous-trigger` are only
  in the code and CHANGELOG.md.

## Tests

- [ ] **No tests for the fork's popup options.** (p3) [test] `test/fzftab.ztst` covers
  completion, not `lib/ftb-tmux-popup` (it needs tmux); a test with a stub `tmux` that records the
  `display-popup` arguments would cover the size and border options.
