# TODO

Open work on the `njhoffman/fzf-tab` fork. Reviewed: 2026-11-22

Categories: bug feature refactor docs test chore perf

Scanned 2026-11-22: upstream's 88 open issues and 27 open PRs (the fork has issues off and no PRs).
"Merges cleanly" means `git merge-tree` of the PR against master had no conflicts that day.

## Upstream fixes for this setup

Bugs with an open upstream PR that the options in `~/.shell` hit (`COMPLETE_IN_WORD`, the
case-insensitive and subsequence `matcher-list`, `_match`/`_approximate`, carapace adapters).
Take each as a cherry-pick with its test, run the suite, note the PR in CHANGELOG.md.

- [ ] **Tab inside a word does nothing with `complete_in_word` (upstream #603).** (p2) [bug]
  `ls ab|x` with two matches never opens fzf, and Tab again repeats the no-op. `~/.shell` sets
  `COMPLETE_IN_WORD`. Conflicts with master in `fzf-tab.zsh`.
- [ ] **Case-insensitive matches insert one case-twin (upstream #589, PR #600).** (p2) [bug] With
  `m:{a-z}={A-Z}` (in `~/.shell`'s `matcher-list`), `Foo` and `foo` both matching makes zsh report
  one as unambiguous and fzf-tab inserts it without the picker. Conflicts in `fzf-tab.zsh`.
- [ ] **Subsequence matchers bias toward one candidate (upstream #560, PR #576).** (p2) [bug]
  `~/.shell`'s last `matcher-list` entries (`r:[[:ascii:]]||[[:ascii:]]=**`) produce a
  `compstate[unambiguous]` that is not a substring of every candidate; fzf-tab inserts it instead
  of showing the picker. Conflicts in `fzf-tab.zsh`; take it with #597 below, same code.
- [ ] **The unambiguous fast path can rewrite the word destructively (upstream PR #597).** (p2)
  [bug] Two guards on the fast path in `-ftb-complete` (unambiguous shorter than the word, or not
  a prefix of it). Same block as #576 and #600: merge the three together.
- [x] **Carapace's pre-quoted words get a literal double backslash (upstream #503, PR #584).**
  (p2) [bug] `path\\ file` lands on the command line for completions that come through carapace
  (`~/.shell`'s zsh-complete caches carapace gap adapters). Merges cleanly. Related: #601, a
  carapace file completion inside a directory starts with query `dir/` and shows 0/N (no PR).
  Done 2026-11-22 (1.3.0+nj.5): #584 cherry-picked, plus a test (`-Q` words with a doubled
  backslash). `~/.shell`'s carapace adapter ran its completer in a subshell and completed nothing
  until 0.126.2, which is why this never showed here.
- [ ] **Carapace's common prefix still gets a double backslash.** (p2) [bug] With a partial
  unquoted word (`dockerd --config-file my<Tab>`, files `my file.json` and `my other.json`), zsh
  itself reports `compstate[unambiguous]` as `my\\ ` (carapace's doubly quoted words), and
  fzf-tab's fast path inserts it; plain zsh inserts `my\ `. #584 only fixes the words fzf-tab
  stores. Compare how plain zsh arrives at one backslash, then either fix the fast path's
  unambiguous string the same way or skip the fast path for `-Q` words with `\\`. An empty word
  works (both give `my\ `).
- [ ] **fzf reads `FZF_DEFAULT_OPTS_FILE` inside fzf-tab (upstream PR #505).** (p2) [bug] fzf-tab
  clears `FZF_DEFAULT_OPTS` but fzf still reads the file, and `~/.config/fzf/fzfrc` sets
  `--preview="fzf-preview {}"` (fzf-tab's `{}` is its NUL-separated line, not a path) and
  `--history=...` (completion queries end up in fzf's search history). Ignore the file unless
  `use-fzf-default-opts` is yes, as #505 does, and decide whether `~/.shell` should keep
  `use-fzf-default-opts yes` or pass only the bindings it wants through `fzf-flags`. Conflicts in
  `lib/-ftb-fzf` and `lib/ftb-tmux-popup`.

## Upstream fixes, other

- [ ] **`autoload ... --` registers a function named `--` (upstream #593, PR #598).** (p3) [bug]
  `fzf-tab.zsh:440`. Not visible in this shell (no `--` function after loading), but the line is
  wrong as written. Merges cleanly.
- [ ] **`compadd -x` inserts the message as a match (upstream PR #592).** (p3) [bug] `zparseopts`
  keeps `-x` in `$_mesg`, so `builtin compadd -x $_mesg` passes the option twice. Conflicts in
  `lib/ftb-tmux-popup`.
- [ ] **Messages from `_message` and `compadd -x` disappear (upstream #604).** (p3) [bug] When the
  widget returns 0 without candidates, zsh's message is wiped. No PR yet.
- [ ] **Group switching with identical group colors (upstream #581, PR #585).** (p3) [bug] The
  switch filters by color, so two groups with the same color switch together. Conflicts in
  `test/fzftab.ztst` only.
- [ ] **`$realpath` empty in execute bindings (upstream #575, PR #577).** (p3) [bug] Bindings like
  `ctrl-e:become(nvim $realpath)` get nothing. Merges cleanly.
- [ ] **External `sort -u` only with GNU sort (upstream #602, PR #595).** (p3) [bug] BSD sort
  drops CJK-only differences; harmless on Linux, but the fix is small. Merges cleanly.
- [ ] **`builtin cd` in the module build (upstream PR #594).** (p3) [bug] A `cd` function
  (zoxide) breaks `build-fzf-tab-module`. Merges cleanly.
- [ ] **Nested popup with `--tmux`/`--popup` in fzf's options (upstream #587, PR #588).** (p3)
  [bug] Not in `fzfrc` today; matters once the popup is used with `use-fzf-default-opts`.
  Conflicts in `.gitignore` and `lib/ftb-tmux-popup`.
- [ ] **Extra space before the completion with a right prompt (upstream #535).** (p3) [bug] Seen
  with starship's left and right prompts; check with p10k's right prompt here before anything else.
- [ ] **Continuous trigger on `pass` entries (upstream #367).** (p3) [test] `pass` paths are not
  real directories (no realdir), so `/` is query input and space accepts; confirm that is what
  `pass <Tab>` should do now that space continues.

## Upstream overlap

- [ ] **Upstream PRs duplicate the fork's popup features.** (p3) [chore] #543 (`popup-max-height`,
  `popup-max-width`: the fork's names), #523 (`popup-smart-tab-bindings`: same name) and #542 (the
  `--style` height adjustment the fork has) are open upstream by other authors. If they merge,
  take upstream's versions in the next sync and drop the fork's copies. #582 adds `reverse` to
  `active-group-style` next to the fork's `italic`/`bold,italic`: align the token lists.
- [ ] **Offer the fork's own changes upstream.** (p3) [chore] The multi-key `continuous-trigger`
  (space for the next argument) and the `italic` header styles have no upstream equivalent; small
  PRs would shrink the fork's diff. #304 (continuous completion without auto-entering single-child
  directories) is the request closest to the space trigger.

## CI and build

- [ ] **CI has never run on the fork.** (p2) [test] Actions is enabled for `njhoffman/fzf-tab`,
  but no workflow run exists: GitHub holds workflows on forks until they are enabled in the
  repository's Actions tab (a one-time click; needs the web UI). The workflows run the suite on
  Ubuntu and Arch, with and without the binary module.
- [ ] **Build the binary module on the hosts.** (p3) [perf] `FZF_TAB_MODULE_VERSION` is unset
  here, so list-colors go through the pure-zsh zsh-ls-colors. `build-fzf-tab-module` builds
  0.2.2 from the fork's (reformatted) source and the suite passes with it (checked 2026-11-22 in a
  scratch worktree). Have zinit build it (`atclone`/`atpull'build-fzf-tab-module'` on the plugin
  in `~/.shell`'s `widgets.zsh`), so new hosts get it too; it clones zsh's source (network).

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
