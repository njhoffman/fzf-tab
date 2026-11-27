# TODO

Open work on the `njhoffman/fzf-tab` fork. Reviewed: 2026-11-26

Categories: bug feature refactor docs test chore perf

Scanned 2026-11-22: upstream's 88 open issues and 27 open PRs (the fork has issues off and no PRs).
"Merges cleanly" means `git merge-tree` of the PR against master had no conflicts that day.

## Upstream overlap

- [ ] **Check upstream for new issues, PRs and commits.** (p3) [chore] Recurring, every week or
  two. Last checked 2026-11-26: 88 open issues, 27 open PRs (one new since 2026-11-22: PR #605,
  item below), upstream/master at 24105b1 (all merged). `git fetch upstream; git log master..upstream/master`; `gh issue list -R
  Aloxaf/fzf-tab --search "updated:>DATE"` and the same for `gh pr list`. Add an item for each one
  that affects this setup, merge new commits as CLAUDE.md says, then update the date here. Never
  comment, open PRs or file issues upstream.

- [ ] **Take upstream PR #605's unclosed-quote tests.** (p3) [test] #605 (open, stacked on #603)
  fixes Tab doing nothing in an unclosed quote (`tst "foo bar<Tab>` with matches `foo bar1`, `foo
  bar2`). The fork already passes both of its cases (checked 2026-11-26: #597's guard in
  `-ftb-unambiguous-safe` covers them, as the PR says), but has no test for them. Add the two
  ztst cases ("unambiguous prefix in unclosed quote string", with and without a suffix after the
  cursor); its one-line change to the fast-path check (compare with and without the closing quote)
  can wait for the merge.

- [ ] **Upstream PRs duplicate the fork's popup features.** (p3) [chore] #543 (`popup-max-height`,
  `popup-max-width`: the fork's names), #523 (`popup-smart-tab-bindings`: same name) and #542 (the
  `--style` height adjustment the fork has) are open upstream by other authors. If they merge,
  take upstream's versions in the next sync and drop the fork's copies. #582 adds `reverse` to
  `active-group-style` next to the fork's `italic`/`bold,italic`: align the token lists.

## Robustness

- [x] **Focus events type I or O on a tmux pane switch.** (p2) [bug] `ftb-fzf` runs
  `$commands[fzf]`, past fzx's `fzf` function that turned focus reporting off, so `\e[I`/`\e[O`
  reached fzf (or, with the popup, the command line). `-ftb-fzf` now turns it off around fzf;
  `focus-reporting restore` turns it on after (1.3.0+nj.17).

- [ ] **Sourcing fzf-tab again with the C module loaded asks to rebuild it.** (p2) [bug]
  `fzf-tab.zsh:586` unsets `FZF_TAB_MODULE_VERSION` unconditionally, right above upstream's #559
  guard that keeps it when the module is already loaded (the nj.6 re-merge kept both). A second
  `source` (a `source ~/.zshrc`, a plugin reload) then finds the version empty, prints
  "parameter `FZF_TAB_MODULE_VERSION' already deleted" from `zmodload -u`, prompts "fzftab module
  needs to be rebuild" (`read -q`) and sources zsh-ls-colors too. Reproduced 2026-11-26 with the
  module built here. Drop line 586; test: source twice, the version stays `0.2.2`, no prompt.
- [ ] **The temporary directory is trusted without checking who owns it.** (p2) [bug]
  `lib/-ftb-fzf:11` uses `${TMPPREFIX:-/tmp/zsh}-fzf-tab-$USER` if it exists (`[[ -d ]]`),
  else `mkdir` with the umask (775 here); `lib/ftb-tmux-popup:53` the same. Files in it are
  sourced: `ftb_preview_init.$$` by every preview and binding, `fzf-$$` by the popup. On a
  multi-user host another user can create that predictable path first and swap those files
  (code runs as you). Upstream has the same code. `mkdir -p -m 700`, then require `-O` and not a
  symlink (else stop with a message, or fall back to `$XDG_RUNTIME_DIR`); `-p` also covers a
  `TMPPREFIX` whose parent does not exist yet.
- [ ] **The tmux popup ignores a one-line status bar at the top.** (p3) [bug]
  `lib/ftb-tmux-popup:43-49` adds `#{status}` to the cursor row when `status-position` is `top`,
  but tmux reports `on` (not 1) for a one-line status; in arithmetic `on` is an unset parameter, so
  the offset is 0 and the popup's row and height bound are one line off (upstream #270 assumed a
  number). This tmux has `status on`, `status-position top`; not visible now since `~/.shell`
  uses `fzf-command fzf`. Map `on`→1, `off`→0, numbers as they are; test with
  `POPUP_SCREEN='... on top'` (all popup tests use `on bottom`).
- [ ] **`fzf-tmux-width-factor` is 0 when `ftb-tmux-popup` runs on its own.** (p3) [bug] The
  popup reads `fzf_tmux_width_factor` from `-ftb-fzf`'s scope (`lib/-ftb-fzf:55`), so
  `ls | ftb-tmux-popup` gets 0, not the documented default 5. Read the zstyle in
  `ftb-tmux-popup` itself, as it does for the other popup options.
- [ ] **`disable-fzf-tab` leaves fzf-tab bound in other keymaps.** (p3) [bug] Enabling binds `^I`
  and `^X.` in both `emacs` and `viins`; disabling rebinds `^I` only in the current main keymap and
  leaves `^X.` on `fzf-tab-debug`, so the other keymap's Tab calls `fzf-tab-complete` with
  `_ftb_orig_widget` unset. `fzf-tab.zsh:428` also unsets `_ftb_orig_list_groupded` (typo, the
  variable stays). Upstream's code; restore both keymaps and fix the name.
- [ ] **No fzf installed gives "command not found: --ansi".** (p3) [bug] `lib/ftb-fzf` runs
  `$commands[fzf] $@`, and `lib/ftb-tmux-popup:121` writes `$commands[fzf]` into the popup's
  command: with no fzf on `PATH` both are empty and the first fzf option becomes the command. Print
  a clear message (and return non-zero) when `$+commands[fzf]` is 0. Fold into the separate
  ftb-fzf rework if that changes how fzf is found.

## Docs

- [ ] **README.md misdescribes or omits some fork behavior.** (p3) [docs] "Fork additions" calls
  `popup-max-height`/`popup-max-width` "upper bounds for the popup, in cells", but the height bounds
  the list rows (the popup gets 4 more: max-height 3 gives `-h 7` in the tests). It does not say
  that `use-fzf-default-opts` also governs `FZF_DEFAULT_OPTS_FILE`, or that `--no-history` (and
  `--no-preview` without an `fzf-preview`) are always passed. The badges and Install section point
  at Aloxaf's repository and CI, not the fork's; decide whether the fork's README says so.

## Tests and upkeep

- [ ] **The local suite only exercises the C module.** (p3) [test] With
  `modules/Src/aloxaf/fzftab.so` built (charon, since `~/.shell` 0.131.0), `fzf-tab.zsh` loads it
  in the tests too, so local runs never cover the pure-zsh `-ftb-compadd` loop and zsh-ls-colors;
  only CI's first step does, after a push (nj.16's bug was the reverse case). Add a switch (an
  environment variable the init checks, or a runner option that hides the `.so`) and run both
  locally.
- [ ] **Workflows use `actions/checkout@v1`.** (p3) [chore] All three workflows pin v1 (a
  deprecated Node runtime); move to `actions/checkout@v4`. The macOS workflow still runs no tests
  (upstream's FIXME, the test steps commented out); try enabling them now that CI runs on the fork.
- [ ] **`modules/Src/fzftab.c` is reformatted against upstream.** (p3) [refactor] Commit 8a8d275
  ("misc fixes", 2025-10) reflowed the whole file (811 lines changed, 99 with `-w`, apparently
  formatting only), so any upstream change to the module will conflict on merge. Restore
  upstream's formatting (`git checkout upstream/master -- modules/Src/fzftab.c`, after confirming
  no functional difference), as with the blank lines added to `fzf-tab.plugin.zsh` and
  `lib/-ftb-generate-header`.
- [ ] **`~/.shell`'s fzf-tab config has dead entries.** (p3) [chore] In
  `~/.shell/zsh/plugin-configs/fzf-tab.zsh`: `FTB_POPUP_DEV` points at
  `~/.zinit/plugins/Aloxaf/fzf-tab/ftb-tmux-popup` (no such plugin; the script is in `lib/` and
  must be called by name), `FZF_BIN=${}` is unused, and `zstyle ':fzf-tab:*' multi-group` is read
  by neither the fork nor upstream. The change belongs in `~/.shell`.

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

### Upstream fixes for this setup (completed 2026-11-22)
- [x] **Tab inside a word does nothing with `complete_in_word` (upstream #603).** (p2) [bug]
  `ls ab|x` with two matches never opens fzf, and Tab again repeats the no-op. `~/.shell` sets
  `COMPLETE_IN_WORD`. Conflicts with master in `fzf-tab.zsh`.
  Done 2026-11-22 (1.3.0+nj.8): #603's comparison and its test.
- [x] **Case-insensitive matches insert one case-twin (upstream #589, PR #600).** (p2) [bug] With
  `m:{a-z}={A-Z}` (in `~/.shell`'s `matcher-list`), `Foo` and `foo` both matching makes zsh report
  one as unambiguous and fzf-tab inserts it without the picker. Conflicts in `fzf-tab.zsh`.
  Done 2026-11-22 (1.3.0+nj.7): `-ftb-unambiguous-safe` combines #597, #576 and #600, with their tests.
- [x] **Subsequence matchers bias toward one candidate (upstream #560, PR #576).** (p2) [bug]
  `~/.shell`'s last `matcher-list` entries (`r:[[:ascii:]]||[[:ascii:]]=**`) produce a
  `compstate[unambiguous]` that is not a substring of every candidate; fzf-tab inserts it instead
  of showing the picker. Conflicts in `fzf-tab.zsh`; take it with #597 below, same code.
  Done 2026-11-22 (1.3.0+nj.7): `-ftb-unambiguous-safe` combines #597, #576 and #600, with their tests.
- [x] **The unambiguous fast path can rewrite the word destructively (upstream PR #597).** (p2)
  [bug] Two guards on the fast path in `-ftb-complete` (unambiguous shorter than the word, or not
  a prefix of it). Same block as #576 and #600: merge the three together.
  Done 2026-11-22 (1.3.0+nj.7): `-ftb-unambiguous-safe` combines #597, #576 and #600, with their tests.
- [x] **Carapace's pre-quoted words get a literal double backslash (upstream #503, PR #584).**
  (p2) [bug] `path\\ file` lands on the command line for completions that come through carapace
  (`~/.shell`'s zsh-complete caches carapace gap adapters). Merges cleanly. Related: #601, a
  carapace file completion inside a directory starts with query `dir/` and shows 0/N (no PR).
  Done 2026-11-22 (1.3.0+nj.5): #584 cherry-picked, plus a test (`-Q` words with a doubled
  backslash). `~/.shell`'s carapace adapter ran its completer in a subshell and completed nothing
  until 0.126.2, which is why this never showed here.
- [x] **Carapace's common prefix still gets a double backslash.** (p2) [bug] With a partial
  unquoted word (`dockerd --config-file my<Tab>`, files `my file.json` and `my other.json`), zsh
  itself reports `compstate[unambiguous]` as `my\\ ` (carapace's doubly quoted words), and
  fzf-tab's fast path inserts it; plain zsh inserts `my\ `. #584 only fixes the words fzf-tab
  stores. Compare how plain zsh arrives at one backslash, then either fix the fast path's
  unambiguous string the same way or skip the fast path for `-Q` words with `\\`. An empty word
  works (both give `my\ `).
  Done 2026-11-22 (1.3.0+nj.7): #597's check (the string must start a candidate) covers it, since
  #584 stores the words with one backslash; test "carapace's doubly quoted words".
- [x] **fzf reads `FZF_DEFAULT_OPTS_FILE` inside fzf-tab (upstream PR #505).** (p2) [bug] fzf-tab
  clears `FZF_DEFAULT_OPTS` but fzf still reads the file, and `~/.config/fzf/fzfrc` sets
  `--preview="fzf-preview {}"` (fzf-tab's `{}` is its NUL-separated line, not a path) and
  `--history=...` (completion queries end up in fzf's search history). Ignore the file unless
  `use-fzf-default-opts` is yes, as #505 does, and decide whether `~/.shell` should keep
  `use-fzf-default-opts yes` or pass only the bindings it wants through `fzf-flags`. Conflicts in
  `lib/-ftb-fzf` and `lib/ftb-tmux-popup`.
  Done 2026-11-22 (1.3.0+nj.9): the file follows `use-fzf-default-opts`; with it, `--no-history`
  and `--no-preview` (where no fzf-preview) on the command line. `~/.shell` keeps
  `use-fzf-default-opts yes`, so fzfrc's colors and bindings stay.

### Upstream fixes, other (completed 2026-11-22)
- [x] **`autoload ... --` registers a function named `--` (upstream #593, PR #598).** (p3) [bug]
  `fzf-tab.zsh:440`. Not visible in this shell (no `--` function after loading), but the line is
  wrong as written. Merges cleanly.
  Done 2026-11-22 (1.3.0+nj.10): #598 cherry-picked.
- [x] **`compadd -x` inserts the message as a match (upstream PR #592).** (p3) [bug] `zparseopts`
  keeps `-x` in `$_mesg`, so `builtin compadd -x $_mesg` passes the option twice. Conflicts in
  `lib/ftb-tmux-popup`.
  Done 2026-11-22 (1.3.0+nj.11): quoted as `${_mesg[-x]}`; the PR's `$_mesg[2]` drops the message
  (the existing WARN case caught it).
- [x] **Messages from `_message` and `compadd -x` disappear (upstream #604).** (p3) [bug] When the
  widget returns 0 without candidates, zsh's message is wiped. No PR yet.
  Done 2026-11-22 (1.3.0+nj.14): the issue's fix; no test of its own (it needs Tab bound to a
  wrapper before fzf-tab loads, and this file loads fzf-tab once for all cases).
- [x] **Group switching with identical group colors (upstream #581, PR #585).** (p3) [bug] The
  switch filters by color, so two groups with the same color switch together. Conflicts in
  `test/fzftab.ztst` only.
  Done 2026-11-22 (1.3.0+nj.11): cherry-picked with its tests.
- [x] **`$realpath` empty in execute bindings (upstream #575, PR #577).** (p3) [bug] Bindings like
  `ctrl-e:become(nvim $realpath)` get nothing. Merges cleanly.
  Done 2026-11-22 (1.3.0+nj.10): #577 cherry-picked.
- [x] **External `sort -u` only with GNU sort (upstream #602, PR #595).** (p3) [bug] BSD sort
  drops CJK-only differences; harmless on Linux, but the fix is small. Merges cleanly.
  Done 2026-11-22 (1.3.0+nj.10): #595 cherry-picked.
- [x] **`builtin cd` in the module build (upstream PR #594).** (p3) [bug] A `cd` function
  (zoxide) breaks `build-fzf-tab-module`. Merges cleanly.
  Done 2026-11-22 (1.3.0+nj.10): #594 cherry-picked.
- [x] **Nested popup with `--tmux`/`--popup` in fzf's options (upstream #587, PR #588).** (p3)
  [bug] Not in `fzfrc` today; matters once the popup is used with `use-fzf-default-opts`.
  Conflicts in `.gitignore` and `lib/ftb-tmux-popup`.
  Done 2026-11-22 (1.3.0+nj.11): `--no-tmux` when the defaults (variable or file) have one.
- [x] **Extra space before the completion with a right prompt (upstream #535).** (p3) [bug] Seen
  with starship's left and right prompts; check with p10k's right prompt here before anything else.
  Not reproduced 2026-11-22: the report needs oh-my-zsh and starship's right prompt; dozens of
  completions in tmux captures with p10k's right prompt today left the line in place.
- [x] **Continuous trigger on `pass` entries (upstream #367).** (p3) [test] `pass` paths are not
  real directories (no realdir), so `/` is query input and space accepts; confirm that is what
  `pass <Tab>` should do now that space continues.
  Checked 2026-11-22: `_pass` completes entries with `_values` (no realdir), so `/` stays query
  input (narrow with `email/`) and space accepts the entry, which is what #367 asks for.

- [x] **Temporary files left when a shell dies mid-completion.** (p3) [bug] `lib/-ftb-fzf`
  removes `$tmp_dir/*.$$` after fzf returns, so a shell killed while fzf is open (a closed
  terminal, a killed tmux server) leaves its `compcap`/`completions`/`groups`/`ftb_preview_init`
  files in `${TMPPREFIX:-/tmp/zsh}-fzf-tab-$USER` (4 from 2026-11-14 there). Remove files of
  PIDs that no longer exist when the directory is next used.
  Done 2026-11-22 (1.3.0+nj.14): removed when the directory is next used; test.

### CI and build (completed 2026-11-25)
- [x] **CI has never run on the fork.** (p2) [test] Actions is enabled for `njhoffman/fzf-tab`,
  but no workflow run exists: GitHub holds workflows on forks until they are enabled in the
  repository's Actions tab (a one-time click; needs the web UI). The workflows run the suite on
  Ubuntu and Arch, with and without the binary module.
  2026-11-22: enabled in the Actions tab (Linux, macOS and Zsh workflows active); tick after the
  first run on a push to master.
  Done 2026-11-25: the fork consent in the Actions tab; first runs on 1.3.0+nj.16 (f1c1950):
  Linux, Zsh and macOS all passed, with and without the C module.
- [x] **Build the binary module on the hosts.** (p3) [perf] `FZF_TAB_MODULE_VERSION` is unset
  here, so list-colors go through the pure-zsh zsh-ls-colors. `build-fzf-tab-module` builds
  0.2.2 from the fork's (reformatted) source and the suite passes with it (checked 2026-11-22 in a
  scratch worktree). Have zinit build it (`atclone`/`atpull'build-fzf-tab-module'` on the plugin
  in `~/.shell`'s `widgets.zsh`), so new hosts get it too; it clones zsh's source (network).
  Done 2026-11-25: `~/.shell` 0.131.0 builds it on zinit clone and update (`atclone`/`atpull`);
  built on charon by hand (its plugin directory is this checkout). Building it found the gap
  fixed in 1.3.0+nj.16.

### Cleanup (completed 2026-11-25)
- [x] **A custom `fzf-command` is ignored.** (p3) [bug] `lib/-ftb-fzf` replaces any
  `fzf-command` other than `ftb-tmux-popup` with `ftb-fzf` (`$commands[fzf]`), so upstream's
  `zstyle ':fzf-tab:*' fzf-command sk` (or an fzf with flags) no longer works. Run the configured
  command, and fall back to `ftb-fzf` only for the default.
  Done 2026-11-22 (1.3.0+nj.12): only `fzf` becomes `ftb-fzf`; test with a stub command.
- [x] **Debug log path.** (p3) [bug] `__LOGDIR='/tmp/fzf-tab/'` makes the trace file
  `/tmp/fzf-tab/-PID-fzf-tab-N.log` (a leading dash, a directory that may not exist); upstream used
  `${TMPPREFIX:-/tmp/zsh}-PID-fzf-tab-N.log`. Pick one and create the directory.
  Done 2026-11-22 (1.3.0+nj.4): `${TMPPREFIX:-/tmp/zsh}-fzf-tab-$USER/debug-PID-N.log`, the
  directory created with mode 700.
- [x] **Unfinished stubs and TODO comments.** (p3) [refactor] `fzf-tab-complete-popup() { }` is an
  empty widget ("if TMUX available force popup"); `__util_log` is half commented out; the
  `# __log_*` call sites in `lib/ftb-tmux-popup` and `fzf-tab.zsh` do nothing. Finish or remove.
  Done 2026-11-22 (1.3.0+nj.15): removed (`util.zsh`, the stub widget, the dead log calls);
  upstream's own TODO comments stay.
- [x] **Generated `README` man page.** (p3) [docs] zinit's z-a-man writes `README` (ronn output,
  September 2023) next to `README.md`; it is stale. Stop committing it (`.gitignore`) or
  regenerate it with each release.
  Done 2026-11-22 (1.3.0+nj.4): untracked and ignored; z-a-man still writes it locally.
- [x] **Document the fork's zstyles in README.md.** (p3) [docs] The popup options,
  `use-fzf-default-opts`, `fzf-tmux-width-factor` and the multi-key `continuous-trigger` are only
  in the code and CHANGELOG.md.
  Done 2026-11-22 (1.3.0+nj.4): README.md "Fork additions".
