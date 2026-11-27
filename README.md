# fzf-tab

[![Zsh compability](https://github.com/njhoffman/fzf-tab/actions/workflows/zsh.yaml/badge.svg)](https://github.com/njhoffman/fzf-tab/actions/workflows/zsh.yaml)
[![GitHub license](https://img.shields.io/github/license/njhoffman/fzf-tab)](https://github.com/njhoffman/fzf-tab/blob/master/LICENSE)

> [!NOTE]
>
> This is [njhoffman/fzf-tab](https://github.com/njhoffman/fzf-tab), a fork of
> [Aloxaf/fzf-tab](https://github.com/Aloxaf/fzf-tab) that follows upstream and adds the zstyles in
> [Fork additions](#fork-additions); [CHANGELOG.md](CHANGELOG.md) lists the fork's changes. The
> install instructions below are upstream's: use `njhoffman/fzf-tab` in place of `Aloxaf/fzf-tab`
> for the fork.

Replace zsh's default completion selection menu with fzf!

[![asciicast](https://asciinema.org/a/293849.svg)](https://asciinema.org/a/293849)

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->

**Table of Contents**

- [fzf-tab](#fzf-tab)
- [Install](#install)
  - [Manual](#manual)
  - [Antigen](#antigen)
  - [Zinit](#zinit)
  - [Oh-My-Zsh](#oh-my-zsh)
  - [Prezto](#prezto)
- [Usage](#usage)
  - [Configure](#configure)
  - [Tmux](#tmux)
  - [Binary module](#binary-module)
- [Difference from other plugins](#difference-from-other-plugins)
- [Compatibility with other plugins](#compatibility-with-other-plugins)
- [Related projects](#related-projects)

<!-- markdown-toc end -->

# Install

> [!IMPORTANT]
>
> 1. make sure [fzf](https://github.com/junegunn/fzf) is installed
> 2. fzf-tab needs to be loaded after `compinit`, but before plugins which will wrap widgets, such as [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) or [fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting)
> 3. Completions should be configured before `compinit`, as stated in the [zsh-completions manual installation guide](https://github.com/zsh-users/zsh-completions#manual-installation).

### Manual

First, clone this repository.

```zsh
git clone https://github.com/Aloxaf/fzf-tab ~/somewhere
```

Then add the following line to your `~/.zshrc`.

```zsh
autoload -U compinit; compinit
source ~/somewhere/fzf-tab.plugin.zsh
```

### Antigen

```zsh
antigen bundle Aloxaf/fzf-tab
```

### Zinit

```zsh
zinit light Aloxaf/fzf-tab
```

### Oh-My-Zsh

Clone this repository to your custom directory and then add `fzf-tab` to your plugin list.

```zsh
git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab
```

### Prezto

Clone this repository to your contrib directory and then add `fzf-tab` to your module list in `.zpreztorc`.

```zsh
git clone https://github.com/Aloxaf/fzf-tab $ZPREZTODIR/contrib/fzf-tab
```

# Usage

Just press <kbd>Tab</kbd> as usual~

Available keybindings:

- <kbd>Ctrl</kdb>+<kdb>Space</kbd>: select multiple results, can be configured by `fzf-bindings` tag

- <kbd>F1</kbd>/<kbd>F2</kbd>: switch between groups, can be configured by `switch-group` tag

- <kbd>/</kbd>: trigger continuous completion (useful when completing a deep path), can be configured by `continuous-trigger` tag (one key or several; a space accepts the selection as an argument and completes the next one)

Available commands:

- `disable-fzf-tab`: disable fzf-tab and fallback to compsys

- `enable-fzf-tab`: enable fzf-tab

- `toggle-fzf-tab`: toggle the state of fzf-tab. This is also a zle widget.

## Configure

A common configuration is:

```zsh
# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
# NOTE: don't use escape sequences (like '%F{red}%d%f') here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# custom fzf flags
# NOTE: fzf-tab does not follow FZF_DEFAULT_OPTS by default
zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept
# To make fzf-tab follow FZF_DEFAULT_OPTS, and the file FZF_DEFAULT_OPTS_FILE names
# (without it, both are cleared for fzf-tab's fzf).
# NOTE: This may lead to unexpected behavior since some flags break this plugin. See Aloxaf/fzf-tab#455.
# Two of their options are always turned off (fzf-flags can turn them on again): --history
# (completion queries would fill fzf's search history) and --preview, unless fzf-preview gives
# one (fzf-tab's rows are not paths).
zstyle ':fzf-tab:*' use-fzf-default-opts yes
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'
```

## Tmux

If you're using tmux >= 3.2, we provide a script `ftb-tmux-popup` to make full use of it's "popup" feature.

```zsh
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
```

BTW, you can also use this script outside the fzf-tab.

```zsh
ls | ftb-tmux-popup
```

[![asciicast](https://asciinema.org/a/367471.svg)](https://asciinema.org/a/367471)

For more information, please see [Wiki#Configuration](https://github.com/Aloxaf/fzf-tab/wiki/Configuration).

## Fork additions

This fork (`njhoffman/fzf-tab`) adds these zstyles to upstream's; see CHANGELOG.md for when.

Continuous completion:

```zsh
# several keys: / goes on into a directory, a space accepts the selection as an argument
# and completes the next one (after a directory it adds the space; a lone next candidate
# is not inserted). One key, as upstream, still works. Default: /
zstyle ':fzf-tab:*' continuous-trigger / ' '
```

Group headers:

```zsh
# the selected group's header: bold (default), underline, bold,underline, none, and here
# also italic and bold,italic
zstyle ':fzf-tab:*' active-group-style bold,italic
```

Focus reporting:

```zsh
# fzf-tab turns the terminal's focus reporting (\e[?1004h) off while fzf runs, so a tmux pane
# switch puts no \e[I / \e[O (an I or O) in the query or on the command line. With restore it
# turns it on again after fzf, for a shell that keeps it on at the prompt (fzf-tab cannot ask
# the terminal whether it was on). Default: off (left off after fzf)
zstyle ':fzf-tab:*' focus-reporting restore
```

tmux popup (`fzf-command ftb-tmux-popup`), next to upstream's `popup-pad`, `popup-min-size` and
`popup-smart-tab`:

```zsh
# the popup's border, as tmux display-popup -b and -S take them
zstyle ':fzf-tab:*' popup-border-style rounded      # default rounded
zstyle ':fzf-tab:*' popup-border-color fg=black     # default fg=black
# upper bounds (default: the window's size): the list's rows, to which the popup adds 4 for its
# border and fzf's own lines (max-height 3 gives a popup 7 high), and the popup's width in cells
zstyle ':fzf-tab:*' popup-max-height 20
zstyle ':fzf-tab:*' popup-max-width 100
# added to the widest candidate to size the popup (default 5)
zstyle ':fzf-tab:*' fzf-tmux-width-factor 25
# the bindings popup-smart-tab adds when the popup opens above the cursor, where the list
# is upside down (default tab:up btab:down)
zstyle ':fzf-tab:*' popup-smart-tab-bindings 'tab:toggle+up' 'btab:toggle+down'
# use-fzf-default-opts (upstream's) also applies to the popup
zstyle ':fzf-tab:*' use-fzf-default-opts yes
```

## Binary module

By default, fzf-tab uses [zsh-ls-colors](https://github.com/xPMo/zsh-ls-colors) to parse and apply ZLS_COLORS if you have set the `list-colors` tag.

However, it is a pure zsh script and is slow if you have too many files to colorize.
fzf-tab is shipped with a binary module to speed up this process. You can build it with `build-fzf-tab-module`, then it will be enabled automatically.

In this fork, `FZF_TAB_NO_MODULE=1` (set before fzf-tab loads) keeps the built module unloaded, for the pure zsh path; the test runner uses it to run the suite both ways.

# Difference from other plugins

fzf-tab doesn't do "complete", it just shows you the results of the default completion system.

So it works EVERYWHERE (variables, function names, directory stack, in-word completion, etc.).
And most of your configuration for default completion system is still valid.

# Compatibility with other plugins

Some plugins may also bind "^I" to their custom widget, like [fzf/shell/completion.zsh](https://github.com/junegunn/fzf/blob/master/shell/completion.zsh) or [ohmyzsh/lib/completion.zsh](https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/completion.zsh#L61-L73).

By default, fzf-tab will call the widget previously bound to "^I" to get the completion list. So there is no problem in most cases, unless fzf-tab is initialized before a plugin which doesn't handle the previous binding properly.

So if you find your fzf-tab doesn't work properly, **please make sure it is the last plugin to bind "^I"** (If you don't know what I mean, just put it to the end of your plugin list).

# Related projects

- https://github.com/lincheney/fzf-tab-completion (fzf tab completion for zsh, bash and GNU readline apps)
