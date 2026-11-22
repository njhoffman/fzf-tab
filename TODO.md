# TODO

Open work on the `njhoffman/fzf-tab` fork. Reviewed: 2026-11-22

Categories: bug feature refactor docs test chore perf

## Cleanup

- [ ] **A custom `fzf-command` is ignored.** (p3) [bug] `lib/-ftb-fzf` replaces any
  `fzf-command` other than `ftb-tmux-popup` with `ftb-fzf` (`$commands[fzf]`), so upstream's
  `zstyle ':fzf-tab:*' fzf-command sk` (or an fzf with flags) no longer works. Run the configured
  command, and fall back to `ftb-fzf` only for the default.
- [x] **Debug log path.** (p3) [bug] `__LOGDIR='/tmp/fzf-tab/'` makes the trace file
  `/tmp/fzf-tab/-PID-fzf-tab-N.log` (a leading dash, a directory that may not exist); upstream used
  `${TMPPREFIX:-/tmp/zsh}-PID-fzf-tab-N.log`. Pick one and create the directory.
  Done 2026-11-22 (1.3.0+nj.4): `${TMPPREFIX:-/tmp/zsh}-fzf-tab-$USER/debug-PID-N.log`, the
  directory created with mode 700.
- [ ] **Unfinished stubs and TODO comments.** (p3) [refactor] `fzf-tab-complete-popup() { }` is an
  empty widget ("if TMUX available force popup"); `__util_log` is half commented out; the
  `# __log_*` call sites in `lib/ftb-tmux-popup` and `fzf-tab.zsh` do nothing. Finish or remove.
- [x] **Generated `README` man page.** (p3) [docs] zinit's z-a-man writes `README` (ronn output,
  September 2023) next to `README.md`; it is stale. Stop committing it (`.gitignore`) or
  regenerate it with each release.
  Done 2026-11-22 (1.3.0+nj.4): untracked and ignored; z-a-man still writes it locally.
- [x] **Document the fork's zstyles in README.md.** (p3) [docs] The popup options,
  `use-fzf-default-opts`, `fzf-tmux-width-factor` and the multi-key `continuous-trigger` are only
  in the code and CHANGELOG.md.
  Done 2026-11-22 (1.3.0+nj.4): README.md "Fork additions".

## Completed

### Loading (completed 2026-11-22)

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

### Performance (completed 2026-11-22)

- [x] **util.zsh forks `date` at every shell start.** (p2) [perf] `__START_TIME=$(date +%s)` runs
  when fzf-tab.plugin.zsh sources util.zsh; use `$EPOCHSECONDS` (zsh/datetime) or drop it. The
  `date` calls inside `__util_log` fork per log line too.
  Done 2026-11-22 (1.3.0+nj.3): `$EPOCHSECONDS` and `strftime`; it was also re-sourced by
  `lib/-ftb-fzf` at every completion, which no longer happens. Test: "util.zsh ... runs no date".
- [x] **ftb-tmux-popup sources util.zsh on every popup.** (p3) [perf] Only for logging helpers
  that are commented out at their call sites.
  Done 2026-11-22 (1.3.0+nj.3): no longer sourced there; its logging calls stay commented out.

### Tests (completed 2026-11-22)

- [x] **No tests for the fork's popup options.** (p3) [test] `test/fzftab.ztst` covers
  completion, not `lib/ftb-tmux-popup` (it needs tmux); a test with a stub `tmux` that records the
  `display-popup` arguments would cover the size and border options.
  Done 2026-11-22 (1.3.0+nj.4): `test/popup-tmux` plus three cases. The end-to-end one found
  that the popup ran by path in a separate zsh and ignored every popup zstyle (fixed).
